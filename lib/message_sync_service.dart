import 'dart:async';
import 'dart:convert';
import 'push_queue.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'database_helper.dart';

// online     = the phone can reach Firebase
// connecting = the phone has a network but Firebase does not answer yet
// offline    = no network at all
enum ConnState { online, connecting, offline }

// Keeps messages safe in SQLite until the internet works, then sends them.
class MessageSyncService {
  MessageSyncService._();

  // ---------- what the screens watch ----------
  static final ValueNotifier<ConnState> connection =
  ValueNotifier<ConnState>(ConnState.online);
  static final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);
  static final ValueNotifier<bool> backOnline = ValueNotifier<bool>(false);

  // goes up by one every time the outbox changes
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static const Duration _timeout = Duration(seconds: 10);

  static StreamSubscription<List<ConnectivityResult>>? _networkSub;
  static StreamSubscription<DatabaseEvent>? _connectedSub;
  static StreamSubscription<DatabaseEvent>? _offsetSub;
  static Timer? _tick;
  static Timer? _downTimer;
  static Timer? _backTimer;

  static bool _started = false;
  static bool _hasNetwork = true;
  static bool _fbConnected = false;
  static bool _fbDownConfirmed = false;
  static bool _wentDown = false;
  static bool _flushing = false;
  static bool _flushAgain = false;
  static int _serverOffsetMs = 0;
  static DateTime _lastKick = DateTime.fromMillisecondsSinceEpoch(0);

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // the time of the Firebase server (the phone clock, corrected)
  static int nowMs() =>
      DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;

  // ---------- START / STOP ----------
  static Future<void> start() async {
    if (_started) return;
    _started = true;
    _wentDown = false;

    // 1) the phone's own network state
    final first = await Connectivity().checkConnectivity();
    if (!_started) return; // stopped while we were waiting
    _hasNetwork = _networkOn(first);
    connection.value = ConnState.online;
    backOnline.value = false;

    _networkSub = Connectivity().onConnectivityChanged.listen((results) {
      final had = _hasNetwork;
      _hasNetwork = _networkOn(results);
      if (_hasNetwork && !had) _networkCameBack();
      _recompute();
    });

    // 2) the real test: can we talk to Firebase?
    final db = FirebaseDatabase.instance;
    _connectedSub = db.ref('.info/connected').onValue.listen((event) {
      _fbConnected = event.snapshot.value == true;
      _downTimer?.cancel();

      if (_fbConnected) {
        _fbDownConfirmed = false;
      } else {
        // "not connected" for 2 seconds in a row = really not connected
        _downTimer = Timer(const Duration(seconds: 2), () {
          _fbDownConfirmed = true;
          _recompute();
        });
      }
      _recompute();
    });

    // 3) the Firebase server clock, so offline messages keep the right order
    _offsetSub = db.ref('.info/serverTimeOffset').onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is num) _serverOffsetMs = v.toInt();
    });

    // 4) every 3 seconds: retry what is still waiting
    _tick = Timer.periodic(const Duration(seconds: 3), (_) => _onTick());

    await _refreshCounts();
    _recompute();
    unawaited(flush());
  }

  static void stop() {
    _started = false;
    _networkSub?.cancel();
    _networkSub = null;
    _connectedSub?.cancel();
    _connectedSub = null;
    _offsetSub?.cancel();
    _offsetSub = null;
    _tick?.cancel();
    _downTimer?.cancel();
    _backTimer?.cancel();
    _fbConnected = false;
    _fbDownConfirmed = false;
    _wentDown = false;
  }

  static bool _networkOn(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  // ---------- CONNECTION STATE ----------
  static void _recompute() {
    final ConnState next;
    if (!_hasNetwork) {
      next = ConnState.offline;
    } else if (_fbConnected) {
      next = ConnState.online;
    } else if (_fbDownConfirmed) {
      next = ConnState.connecting;
    } else {
      // Firebase is still connecting (a second or two): stay calm
      next = ConnState.online;
    }

    if (next == connection.value) return;
    connection.value = next;

    if (next == ConnState.online) {
      _backTimer?.cancel();
      if (_wentDown) {
        _wentDown = false;
        backOnline.value = true;
        _backTimer = Timer(
          const Duration(seconds: 4),
              () => backOnline.value = false,
        );
      }
      // send at once
      unawaited(flush());
    } else {
      _wentDown = true;
      _backTimer?.cancel();
      backOnline.value = false;
    }
  }

  // the network is back: if Firebase is still silent after 1 second, push it
  static void _networkCameBack() {
    Timer(const Duration(seconds: 1), () {
      if (_started && _hasNetwork && !_fbConnected) {
        unawaited(_kickFirebase());
      }
    });
  }

  static Future<void> _kickFirebase() async {
    final now = DateTime.now();
    if (now.difference(_lastKick) < const Duration(seconds: 5)) return;
    _lastKick = now;

    try {
      final db = FirebaseDatabase.instance;
      await db.goOffline();
      await db.goOnline();
    } catch (e) {
      debugPrint('Reconnect failed: $e');
    }
  }

  static void _onTick() {
    if (!_started) return;

    if (_hasNetwork && !_fbConnected && _fbDownConfirmed) {
      unawaited(_kickFirebase());
    }

    // also catches scheduled messages whose time has just come
    if (connection.value == ConnState.online) {
      unawaited(flush());
    }
  }

  // ---------- SAVE A MESSAGE (works without internet) ----------
  // `data` holds the message fields (text, type, reply fields...).
  // sender, time and status are added here.
  // `sendAt` = null: send as soon as there is internet.
  // `sendAt` = a time: keep it on the phone and send when that time comes.
  static Future<void> enqueue({
    required String chatId,
    required Map<String, dynamic> data,
    DateTime? sendAt,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not logged in');

    // push() makes the key on the phone: no internet needed
    final id =
    FirebaseDatabase.instance.ref('chats/$chatId/messages').push().key!;
    final timeMs = nowMs();

    final payload = Map<String, dynamic>.from(data)
      ..['senderId'] = uid
      ..['timeMs'] = timeMs
      ..['status'] = 0;

    await DatabaseHelper.outboxInsert(
      id: id,
      owner: uid,
      chatId: chatId,
      payload: jsonEncode(payload),
      createdMs: timeMs,
      sendAtMs: sendAt?.millisecondsSinceEpoch ?? 0,
    );
    _bump();

    unawaited(flush());
  }

  static Future<void> retry(String id) async {
    await DatabaseHelper.outboxRetry(id);
    _bump();
    unawaited(flush());
  }

  static Future<void> discard(String id) async {
    await DatabaseHelper.outboxDelete(id);
    _bump();
  }

  // ---------- SEND WHAT IS WAITING ----------
  static Future<void> flush() async {
    final uid = _uid;
    if (uid == null) return;

    if (_flushing) {
      _flushAgain = true; // a new message arrived while we were sending
      return;
    }

    _flushing = true;
    try {
      while (connection.value == ConnState.online) {
        final rows = await DatabaseHelper.outboxPending(uid);
        if (rows.isEmpty) break;

        // oldest first, one by one
        final handled = await _sendRow(rows.first);
        if (!handled) break; // try again on the next 3-second tick
      }
    } finally {
      _flushing = false;
      unawaited(_refreshCounts());
      if (_flushAgain) {
        _flushAgain = false;
        unawaited(flush());
      }
    }
  }

  // true  = this message is finished (sent, or refused for good)
  // false = could not send now, try again later
  // true = message is finished; false = retry later
  static Future<bool> _sendRow(Map<String, Object?> row) async {
    final id = row['id'] as String;
    final chatId = row['chat_id'] as String;
    final attempts = (row['attempts'] as int?) ?? 0;

    Map<String, dynamic>? parsed;

    try {
      parsed = Map<String, dynamic>.from(
        jsonDecode(row['payload'] as String) as Map,
      );
    } catch (_) {
      parsed = null;
    }

    if (parsed == null) {
      await DatabaseHelper.outboxMarkFailed(id);
      _bump();
      return true;
    }

    final payload = parsed;
    payload['status'] = 0;

    // For a scheduled message, use the actual sending time.
    final sendAt = (row['send_at'] as int?) ?? 0;
    if (sendAt > 0) {
      payload['timeMs'] = nowMs();
    }

    // Disappearing messages: the timer starts when the message is really sent.
    final after = payload.remove('expireAfterMs');
    if (after is num && after > 0) {
      payload['expireAtMs'] =
          (payload['timeMs'] as num).toInt() + after.toInt();
    }

    final ref =
    FirebaseDatabase.instance.ref('chats/$chatId/messages/$id');

    try {
      // Avoid duplicate messages after a retry.
      if (attempts > 0) {
        final existing = await ref.get().timeout(_timeout);

        if (existing.exists) {
          await DatabaseHelper.outboxDelete(id);
          _bump();
          return true;
        }
      }

      await DatabaseHelper.outboxMarkAttempt(id);

      // Save the message to Firebase.
      await ref.set(payload).timeout(_timeout);

      await DatabaseHelper.outboxDelete(id);
      _bump();

      // Ask the push server to notify the OTHER people in this chat.
      unawaited(
        PushQueue.add(chatId: chatId, messageId: id, data: payload),
      );

      return true;
    } on FirebaseException catch (e) {
      debugPrint('Send failed: ${e.code} ${e.message}');

      if (e.code == 'permission-denied') {
        await DatabaseHelper.outboxMarkFailed(id);
        _bump();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Send failed: $e');
      return false;
    }
  }


  // ---------- COUNTS ----------
  static void _bump() {
    version.value++;
    unawaited(_refreshCounts());
  }

  static Future<void> _refreshCounts() async {
    final uid = _uid;
    pendingCount.value =
    uid == null ? 0 : await DatabaseHelper.outboxPendingCount(uid);
  }
}