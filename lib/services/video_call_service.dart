import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../message_sync_service.dart';
import '../push_queue.dart';

enum CallPhase { starting, ringing, connecting, connected, ended }

enum CallEnd { none, ended, declined, missed }

// One video call. The caller uses startCall(), the receiver uses acceptCall().
class VideoCallService {
  VideoCallService({
    required this.myUid,
    required this.otherUid,
    this.video = true,
  });

  // how long the phone rings before the caller gives up
  static const int ringSeconds = 45;

  final String myUid;
  final String otherUid;
  bool video;

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // the call screen watches these
  final ValueNotifier<CallPhase> phase = ValueNotifier(CallPhase.starting);
  final ValueNotifier<MediaStream?> localStream = ValueNotifier(null);
  final ValueNotifier<MediaStream?> remoteStream = ValueNotifier(null);

  CallEnd endReason = CallEnd.none;
  bool endedByMe = false;

  RTCPeerConnection? _pc;
  DatabaseReference? _callRef;
  StreamSubscription<DatabaseEvent>? _callSub;
  StreamSubscription<DatabaseEvent>? _callerCandSub;
  StreamSubscription<DatabaseEvent>? _calleeCandSub;
  Timer? _ringTimer;

  String? _callId;
  bool _isCaller = false;
  bool _callCreated = false;
  bool _answerApplied = false;
  bool _finished = false;
  bool _closed = false;
  String _lastStatus = '';
  DateTime? _connectedAt;
  final List<RTCIceCandidate> _pendingCandidates = [];

  // the chat board of the two people (same rule as the chat screen)
  String get chatId => ([myUid, otherUid]..sort()).join('_');

  // WebRTC uses these servers to help the phones find each other.
  // A production app should also add a TURN server.
  static const Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ],
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  // ---------- MEDIA + PEER CONNECTION ----------
  Future<void> _initMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': video
          ? {
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
      }
          : false,
    });
    localStream.value = stream;
  }

  Future<void> _createPeer() async {
    final stream = localStream.value;
    if (stream == null) {
      throw StateError('Camera and microphone are not ready.');
    }

    final pc = await createPeerConnection(_configuration);
    _pc = pc;

    for (final track in stream.getTracks()) {
      await pc.addTrack(track, stream);
    }

    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) remoteStream.value = event.streams.first;
    };

    pc.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _markConnected();
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        unawaited(hangUp());
      }
    };

    pc.onIceConnectionState = (RTCIceConnectionState state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _markConnected();
      }
    };
  }

  void _markConnected() {
    if (_finished || phase.value == CallPhase.connected) return;
    _connectedAt = DateTime.now();
    _ringTimer?.cancel();
    _setPhase(CallPhase.connected);
  }

  void _setPhase(CallPhase next) {
    if (phase.value == CallPhase.ended) return; // nothing after the end
    phase.value = next;
  }

  void _pushCandidate(String node, RTCIceCandidate c) {
    _callRef?.child(node).push().set({
      'candidate': c.candidate,
      'sdpMid': c.sdpMid ?? '',
      'sdpMLineIndex': c.sdpMLineIndex ?? 0,
    }).catchError((Object e) {
      debugPrint('Candidate not saved: $e');
    });
  }

  Future<void> _onRemoteCandidate(DatabaseEvent event) async {
    final data = event.snapshot.value;
    if (data is! Map || _finished) return;
    try {
      await _pc?.addCandidate(
        RTCIceCandidate(
          data['candidate']?.toString(),
          data['sdpMid']?.toString(),
          (data['sdpMLineIndex'] as num?)?.toInt(),
        ),
      );
    } catch (e) {
      debugPrint('Could not add the candidate: $e');
    }
  }

  // ---------- CALLER ----------
  Future<String> startCall() async {
    if (myUid.isEmpty || otherUid.isEmpty || myUid == otherUid) {
      throw ArgumentError('Invalid caller or receiver.');
    }
    if (MessageSyncService.connection.value != ConnState.online) {
      throw StateError('You are offline. Connect to the internet and try again.');
    }

    _isCaller = true;
    await _initMedia();
    await _createPeer();

    final ref = _db.ref('calls').push();
    final id = ref.key;
    if (id == null) throw StateError('Could not create the call.');
    _callId = id;
    _callRef = ref;

    // candidates wait until the call exists in Firebase (the rules need that)
    _pc!.onIceCandidate = (RTCIceCandidate c) {
      if (c.candidate == null || _finished) return;
      if (!_callCreated) {
        _pendingCandidates.add(c);
        return;
      }
      _pushCandidate('callerCandidates', c);
    };

    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);

    await ref.set({
      'callerUid': myUid,
      'calleeUid': otherUid,
      'status': 'ringing',
      'createdAt': ServerValue.timestamp,
      'video': video,
      'offer': {'type': offer.type, 'sdp': offer.sdp},
    }).timeout(const Duration(seconds: 12));

    _callCreated = true;
    for (final c in _pendingCandidates) {
      _pushCandidate('callerCandidates', c);
    }
    _pendingCandidates.clear();

    // this makes the other phone ring
    await _db.ref('users/$otherUid/incomingCalls/$id').set({
      'callerUid': myUid,
      'video': video,
      'createdAt': ServerValue.timestamp,
    }).timeout(const Duration(seconds: 12));

    // a normal push for when the other app is closed
    unawaited(
      PushQueue.add(
        chatId: chatId,
        messageId: id,
        data: {
          'type': 'call',
          'text': video ? '📹 Incoming video call' : '📞 Incoming call',
        },
      ),
    );

    _lastStatus = 'ringing';
    _setPhase(CallPhase.ringing);
    _watchCall(ref);

    _ringTimer = Timer(const Duration(seconds: ringSeconds), () {
      if (!_finished && _lastStatus != 'accepted') unawaited(hangUp());
    });

    return id;
  }

  // ---------- RECEIVER ----------
  Future<void> acceptCall(String callId) async {
    _isCaller = false;
    _callId = callId;
    final ref = _db.ref('calls/$callId');
    _callRef = ref;

    final snap = await ref.get().timeout(const Duration(seconds: 12));
    final v = snap.value;
    if (v is! Map ||
        v['calleeUid'] != myUid ||
        (v['status'] ?? '') != 'ringing') {
      throw StateError('This call is no longer available.');
    }
    final offer = v['offer'];
    if (offer is! Map) throw StateError('The call offer is missing.');

    video = v['video'] != false;

    await _initMedia();
    await _createPeer();

    _pc!.onIceCandidate = (RTCIceCandidate c) {
      if (c.candidate == null || _finished) return;
      _pushCandidate('calleeCandidates', c);
    };

    await _pc!.setRemoteDescription(
      RTCSessionDescription(
        offer['sdp']?.toString(),
        offer['type']?.toString(),
      ),
    );

    _callerCandSub = ref
        .child('callerCandidates')
        .onChildAdded
        .listen(_onRemoteCandidate);

    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);

    await ref.update({
      'answer': {'type': answer.type, 'sdp': answer.sdp},
      'status': 'accepted',
      'answeredAt': ServerValue.timestamp,
    }).timeout(const Duration(seconds: 12));

    _lastStatus = 'accepted';
    _setPhase(CallPhase.connecting);
    _watchCall(ref);
  }

  // used by the incoming call screen when I press Decline
  static Future<void> rejectCall({
    required String callId,
    required String myUid,
  }) async {
    final db = FirebaseDatabase.instance;
    try {
      await db
          .ref('calls/$callId')
          .update({'status': 'rejected'}).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Could not reject the call: $e');
    }
    try {
      await db.ref('users/$myUid/incomingCalls/$callId').remove();
    } catch (e) {
      debugPrint('Could not clear the incoming call: $e');
    }
  }

  // ---------- WATCH THE CALL ----------
  void _watchCall(DatabaseReference ref) {
    _callSub = ref.onValue.listen((event) async {
      if (_finished) return;
      final v = event.snapshot.value;
      if (v is! Map) return;

      final status = (v['status'] ?? '').toString();
      _lastStatus = status;

      if (status == 'rejected') {
        _finish(CallEnd.declined);
      } else if (status == 'cancelled') {
        _finish(CallEnd.missed);
      } else if (status == 'ended') {
        _finish(CallEnd.ended);
      } else if (status == 'accepted') {
        _ringTimer?.cancel();
        if (phase.value == CallPhase.ringing ||
            phase.value == CallPhase.starting) {
          _setPhase(CallPhase.connecting);
        }
        if (_isCaller) await _applyAnswer(v['answer']);
      }
    }, onError: (Object e) => debugPrint('Call listener error: $e'));
  }

  Future<void> _applyAnswer(Object? answer) async {
    if (_answerApplied || answer is! Map || _pc == null) return;
    _answerApplied = true;
    try {
      await _pc!.setRemoteDescription(
        RTCSessionDescription(
          answer['sdp']?.toString(),
          answer['type']?.toString(),
        ),
      );
      _calleeCandSub = _callRef!
          .child('calleeCandidates')
          .onChildAdded
          .listen(_onRemoteCandidate);
    } catch (e) {
      debugPrint('Could not apply the answer: $e');
    }
  }

  // ---------- END ----------
  // I press End (or the caller gives up / the screen closes)
  Future<void> hangUp() async {
    if (_finished) return;
    endedByMe = true;

    final accepted = _lastStatus == 'accepted';
    final newStatus = (_isCaller && !accepted) ? 'cancelled' : 'ended';
    final ref = _callRef;

    if (ref != null && (_callCreated || !_isCaller)) {
      unawaited(
        ref.update({'status': newStatus}).catchError((Object e) {
          debugPrint('Could not end the call: $e');
        }),
      );
    }
    _finish(newStatus == 'cancelled' ? CallEnd.missed : CallEnd.ended);
  }

  void _finish(CallEnd reason) {
    if (_finished) return;
    _finished = true;
    endReason = reason;
    _ringTimer?.cancel();

    final callId = _callId;
    if (_isCaller && _callCreated && callId != null) {
      unawaited(_writeCallLog(reason));
      unawaited(
        _db
            .ref('users/$otherUid/incomingCalls/$callId')
            .remove()
            .catchError((Object e) {
          debugPrint('Could not clear the incoming call: $e');
        }),
      );
    }

    _setPhase(CallPhase.ended);
    unawaited(close());
  }

  int get durationSeconds {
    final at = _connectedAt;
    return at == null ? 0 : DateTime.now().difference(at).inSeconds;
  }

  // ONLY the caller writes the call message, so it is saved once.
  // The call id is the message id, so it can never appear twice.
  Future<void> _writeCallLog(CallEnd reason) async {
    final id = _callId;
    if (id == null) return;

    final connected = _connectedAt != null;
    final kind = video ? 'Video call' : 'Voice call';

    String callStatus;
    String text;
    int status; // 2 = already read, 0 = unread (a missed call)

    if (connected) {
      callStatus = 'ended';
      text = kind;
      status = 2;
    } else if (reason == CallEnd.declined) {
      callStatus = 'declined';
      text = '$kind declined';
      status = 2;
    } else {
      callStatus = 'missed';
      text = 'Missed ${kind.toLowerCase()}';
      status = 0;
    }

    try {
      await _db.ref('chats/$chatId/messages/$id').set({
        'text': text,
        'type': 'call',
        'senderId': myUid,
        'timeMs': ServerValue.timestamp,
        'status': status,
        'callStatus': callStatus,
        'callVideo': video,
        'callDurationSec': connected ? durationSeconds : 0,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      // offline: Firebase keeps the write and sends it later
      debugPrint('Call message not confirmed yet: $e');
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    await _callSub?.cancel();
    await _callerCandSub?.cancel();
    await _calleeCandSub?.cancel();

    // detach the pictures first, then stop the camera
    final local = localStream.value;
    localStream.value = null;
    remoteStream.value = null;

    try {
      await _pc?.close();
      await _pc?.dispose();
    } catch (e) {
      debugPrint('Peer close failed: $e');
    }
    _pc = null;

    try {
      for (final track in local?.getTracks() ?? <MediaStreamTrack>[]) {
        await track.stop();
      }
      await local?.dispose();
    } catch (e) {
      debugPrint('Camera release failed: $e');
    }

    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
  }
}