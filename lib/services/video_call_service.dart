
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallService {
  VideoCallService({
    required this.myUid,
    required this.otherUid,
  });

  final String myUid;
  final String otherUid;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  StreamSubscription<DatabaseEvent>? _callSubscription;
  StreamSubscription<DatabaseEvent>? _callerCandidatesSubscription;
  StreamSubscription<DatabaseEvent>? _receiverCandidatesSubscription;

  String? _callId;
  bool _closed = false;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  // WebRTC uses these servers to help devices connect.
  // A production app should also configure a reliable TURN server.
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302'],
      },
    ],
  };

  Future<void> initializeMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
      },
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    final stream = _localStream;
    if (stream == null) {
      throw StateError('Initialize the camera and microphone first.');
    }

    for (final track in stream.getTracks()) {
      await _peerConnection!.addTrack(track, stream);
    }

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      }
    };
  }

  Future<String> startCall() async {
    if (myUid.isEmpty || otherUid.isEmpty || myUid == otherUid) {
      throw ArgumentError('Invalid caller or receiver UID.');
    }

    await initializeMedia();
    await _createPeerConnection();

    final callRef = _database.ref('calls').push();
    _callId = callRef.key;

    if (_callId == null) {
      throw StateError('Could not create a call ID.');
    }

    final callRefWithId = _database.ref('calls/$_callId');

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate == null || _closed) return;

      callRefWithId.child('callerCandidates').push().set({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await callRefWithId.set({
      'callerUid': myUid,
      'receiverUid': otherUid,
      'status': 'ringing',
      'createdAt': ServerValue.timestamp,
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
    });

    _callSubscription = callRefWithId.onValue.listen((event) async {
      if (_closed || _peerConnection == null) return;

      final value = event.snapshot.value;
      if (value is! Map) return;

      if (value['status'] == 'rejected' ||
          value['status'] == 'ended') {
        await close();
        return;
      }

      final answer = value['answer'];
      if (answer is Map &&
          _peerConnection!.signalingState ==
              RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            answer['sdp']?.toString(),
            answer['type']?.toString(),
          ),
        );

        await _receiverCandidatesSubscription?.cancel();
        _receiverCandidatesSubscription = callRefWithId
            .child('receiverCandidates')
            .onChildAdded
            .listen((candidateEvent) async {
          final data = candidateEvent.snapshot.value;
          if (data is! Map || _closed) return;

          await _peerConnection?.addCandidate(
            RTCIceCandidate(
              data['candidate']?.toString(),
              data['sdpMid']?.toString(),
              (data['sdpMLineIndex'] as num?)?.toInt(),
            ),
          );
        });
      }
    });

    return _callId!;
  }

  // The receiver will use this when accepting an incoming call.
  Future<void> acceptCall(String callId) async {
    _callId = callId;

    final callRef = _database.ref('calls/$callId');
    final snapshot = await callRef.get();
    final value = snapshot.value;

    if (value is! Map ||
        value['receiverUid'] != myUid ||
        value['status'] != 'ringing') {
      throw StateError('This call is no longer available.');
    }

    final offerData = value['offer'];
    if (offerData is! Map) {
      throw StateError('The call offer is missing.');
    }

    await initializeMedia();
    await _createPeerConnection();

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate == null || _closed) return;

      callRef.child('receiverCandidates').push().set({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        offerData['sdp']?.toString(),
        offerData['type']?.toString(),
      ),
    );

    _callerCandidatesSubscription = callRef
        .child('callerCandidates')
        .onChildAdded
        .listen((event) async {
      final data = event.snapshot.value;
      if (data is! Map || _closed) return;

      await _peerConnection?.addCandidate(
        RTCIceCandidate(
          data['candidate']?.toString(),
          data['sdpMid']?.toString(),
          (data['sdpMLineIndex'] as num?)?.toInt(),
        ),
      );
    });

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await callRef.update({
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      },
      'status': 'accepted',
    });
  }

  Future<void> rejectCall(String callId) async {
    final ref = _database.ref('calls/$callId');
    final snapshot = await ref.get();
    final value = snapshot.value;

    if (value is Map && value['receiverUid'] == myUid) {
      await ref.update({'status': 'rejected'});
    }
  }

  Future<void> endCall() async {
    final callId = _callId;
    if (callId == null) {
      await close();
      return;
    }

    final ref = _database.ref('calls/$callId');
    final snapshot = await ref.get();
    final value = snapshot.value;

    if (value is Map &&
        (value['callerUid'] == myUid ||
            value['receiverUid'] == myUid)) {
      await ref.update({'status': 'ended'});
    }

    await close();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    await _callSubscription?.cancel();
    await _callerCandidatesSubscription?.cancel();
    await _receiverCandidatesSubscription?.cancel();

    await _peerConnection?.close();
    await _peerConnection?.dispose();

    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }

    await _localStream?.dispose();
    await _remoteStream?.dispose();

    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
  }
}
