import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../services/database_helper.dart';
import '../message_sync_service.dart';
import '../models/message.dart';

class MessagesProvider extends ChangeNotifier {
  MessagesProvider({
    required this.chatId,
    required this.myUid,
    required this.isGroup,
  });

  final String chatId;
  final String myUid;
  final bool isGroup;

  void Function(Set<String> senderIds)? onSenderIds;

  late final DatabaseReference _messagesRef =
  FirebaseDatabase.instance.ref('chats/$chatId/messages');
  late final DatabaseReference _disappearRef = FirebaseDatabase.instance.ref(
    'chats/$chatId/settings/disappearAfterMs',
  );
  late final DatabaseReference _clearedRef = FirebaseDatabase.instance.ref(
    'users/$myUid/clearedChats/$chatId',
  );

  StreamSubscription<DatabaseEvent>? _subscription;
  StreamSubscription<DatabaseEvent>? _settingsSub;
  StreamSubscription<DatabaseEvent>? _clearedSub;
  Timer? _expiryTimer;
  Timer? _loadingTimer;

  List<Message> _remote = [];
  List<Message> _pending = [];
  List<Message> _messages = [];

  bool _loading = true;
  bool _loadError = false;
  bool _gotRemote = false; // Firebase answered at least once
  int _disappearMs = 0; // 0 = off
  int _clearedAtMs = 0; // 0 = I never deleted this chat
  bool _clearedReady = false; // the "deleted at" note was read
  final Set<String> _purging = {};
  bool _started = false;
  bool _disposed = false;

  List<Message> get messages => _messages;
  bool get loading => _loading;
  bool get loadError => _loadError;
  int get disappearMs => _disappearMs;

  // called once when the chat screen opens
  void start() {
    if (_started) return;
    _started = true;

    // The "deleted at" note comes first, so old messages never flash.
    if (myUid.isEmpty) {
      _clearedReady = true;
    } else {
      _clearedSub = _clearedRef.onValue.listen(
            (event) {
          if (_disposed) return;
          final v = event.snapshot.value;
          _clearedAtMs = v is num ? v.toInt() : 0;
          _clearedReady = true;
          _rebuildMessages();
        },
        onError: (Object e) {
          debugPrint('[MessagesProvider] Cleared note error: $e');
          if (_disposed) return;
          _clearedReady = true;
          _rebuildMessages();
        },
      );
    }

    _subscription = _messagesRef.onValue.listen(
      _onMessagesChanged,
      onError: (_) {
        if (_disposed) return;
        _loading = false;
        _loadError = true;
        notifyListeners();
      },
    );

    MessageSyncService.version.addListener(_loadPending);
    _loadPending();

    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (_disposed) return;
      _clearedReady = true;
      _loading = false;
      _rebuildMessages();
    });

    _settingsSub = _disappearRef.onValue.listen((event) {
      final v = event.snapshot.value;
      if (_disposed) return;
      _disappearMs = v is num ? v.toInt() : 0;
      notifyListeners();
    });

    // every second: hide + delete messages whose time is over
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _purgeExpired(),
    );
  }

  // ---------- LIVE MESSAGES ----------
  void _onMessagesChanged(DatabaseEvent event) {
    final value = event.snapshot.value;
    final list = <Message>[];

    if (value is Map) {
      value.forEach((key, data) {
        if (data is Map) {
          list.add(Message.fromMap(key.toString(), data, myUid));
        }
      });
    }

    if (_disposed) return;
    _remote = list;
    _gotRemote = true;
    _loadError = false;
    _rebuildMessages();
    _purgeExpired();

    if (isGroup) {
      onSenderIds?.call(list.map((m) => m.senderId).toSet());
    } else {
      _markIncomingAsRead(list);
    }
  }

  bool _isAfterClear(Message m) {
    return _clearedAtMs == 0 || m.time.millisecondsSinceEpoch > _clearedAtMs;
  }
  void _rebuildMessages() {
    if (_disposed) return;
    if (!_clearedReady) return;

    final now = MessageSyncService.nowMs();
    final ids = _remote.map((m) => m.id).toSet();
    final merged = <Message>[
      ..._remote.where((m) => m.expireAtMs == 0 || m.expireAtMs > now),
      ..._pending.where((m) => !ids.contains(m.id)),
    ].where(_isAfterClear).toList()
      ..sort((a, b) {
        final byTime = a.time.compareTo(b.time);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });

    _messages = merged;
    if (_gotRemote || _pending.isNotEmpty) _loading = false;
    notifyListeners();
  }

  Future<void> _loadPending() async {
    if (myUid.isEmpty) return;

    final rows = await DatabaseHelper.outboxForChat(myUid, chatId);
    final list = <Message>[];

    for (final row in rows) {
      try {
        final payload = Map<dynamic, dynamic>.from(
          jsonDecode(row['payload'] as String) as Map,
        );
        payload['status'] = (row['state'] as int) == 1 ? -2 : -1;
        list.add(Message.fromMap(row['id'] as String, payload, myUid));
      } catch (e) {
        debugPrint('Bad outbox row: $e');
      }
    }

    if (_disposed) return;
    _pending = list;
    _rebuildMessages();
  }

  void _purgeExpired() {
    if (_disposed) return;
    final now = MessageSyncService.nowMs();
    final expired = _remote
        .where((m) => m.expireAtMs > 0 && m.expireAtMs <= now)
        .toList();
    if (expired.isEmpty) return;

    for (final m in expired) {
      if (_purging.add(m.id)) {
        _messagesRef.child(m.id).remove().catchError((Object e) {
          debugPrint('Expire delete failed: $e');
          _purging.remove(m.id);
        });
      }
    }
    _remote = _remote.where((m) => !expired.contains(m)).toList();
    _rebuildMessages();
  }

  Future<void> _markIncomingAsRead(List<Message> list) async {
    for (final m in list) {
      if (!m.isMe && m.status != 2) {
        try {
          await _messagesRef.child(m.id).update({'status': 2});
        } catch (e) {
          debugPrint('Read status update failed: $e');
        }
      }
    }
  }

  List<Object> buildItems() {
    final items = <Object>[];
    DateTime? lastDay;
    for (final m in _messages) {
      final day = DateTime(m.time.year, m.time.month, m.time.day);
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(m);
    }
    return items;
  }
  Future<String?> deleteMessage(Message msg) async {
    try {
      if (msg.status < 0) {
        await MessageSyncService.discard(msg.id);
        return null;
      }
      await _messagesRef.child(msg.id).remove();
      return null;
    } catch (e) {
      return 'Could not delete the message';
    }
  }

  Future<String?> clearChat() async {
    try {
      await _messagesRef.remove();
      return null;
    } catch (e) {
      return 'Could not clear the chat';
    }
  }

  Future<String?> reactTo(Message msg, String emoji) async {
    if (msg.status < 0) return 'Wait until the message is sent';
    if (myUid.isEmpty) return 'Please log in again';

    final ref = _messagesRef.child(msg.id).child('reactions').child(myUid);

    try {
      if (msg.reactions[myUid] == emoji) {
        await ref.remove();
      } else {
        await ref.set(emoji);
      }
      return null;
    } catch (e) {
      debugPrint('Reaction failed: $e');
      return 'Could not add the reaction. Check the database rules.';
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadingTimer?.cancel();
    _expiryTimer?.cancel();
    _subscription?.cancel();
    _settingsSub?.cancel();
    _clearedSub?.cancel();
    MessageSyncService.version.removeListener(_loadPending);
    super.dispose();
  }
}