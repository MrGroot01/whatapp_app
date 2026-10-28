import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

import 'message_sync_service.dart';
import 'notification_service.dart';

// Shows a notification on THIS phone when somebody sends me a new message
// (in a 1-to-1 chat or in a group).
class IncomingMessageNotifier {
  IncomingMessageNotifier._();

  // the chat that is open on screen right now ('' = none)
  static String activeChatId = '';
  static bool _appInForeground = true;

  static StreamSubscription<DatabaseEvent>? _contactsSub;
  static StreamSubscription<DatabaseEvent>? _groupIdsSub;
  static AppLifecycleListener? _lifecycle;
  static final Map<String, StreamSubscription<DatabaseEvent>> _chatSubs = {};
  // group id -> [name listener, message listener]
  static final Map<String, List<StreamSubscription<DatabaseEvent>>>
  _groupSubs = {};
  static final Map<String, String> _groupNames = {}; // group id -> group name
  static final Map<String, String> _names = {}; // contact id -> name I saved
  static final Set<String> _notified = {};
  static int _startMs = 0;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // started when the home screen opens
  static void start() {
    if (_contactsSub != null) return;
    final me = _uid;
    if (me == null) return;

    // only messages that arrive AFTER this moment make a notification
    _startMs = MessageSyncService.nowMs();
    _appInForeground = true;

    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _appInForeground = state == AppLifecycleState.resumed;
      },
    );

    // the key of each contact is that person's account id
    _contactsSub = FirebaseDatabase.instance
        .ref('users/$me/contacts')
        .onValue
        .listen(
          (event) {
        final names = <String, String>{};
        final value = event.snapshot.value;
        if (value is Map) {
          value.forEach((key, data) {
            if (data is Map) {
              names[key.toString()] = (data['name'] ?? '').toString();
            }
          });
        }
        _syncChatListeners(me, names);
      },
      onError: (Object e) => debugPrint('Contacts listener error: $e'),
    );

    // the groups I am in
    _groupIdsSub = FirebaseDatabase.instance
        .ref('users/$me/groups')
        .onValue
        .listen(
          (event) {
        final ids = <String>{};
        final value = event.snapshot.value;
        if (value is Map) {
          value.forEach((key, v) {
            if (v == true) ids.add(key.toString());
          });
        }
        _syncGroupListeners(me, ids);
      },
      onError: (Object e) => debugPrint('Groups listener error: $e'),
    );
  }

  // one listener for each contact's chat (also for contacts added later)
  static void _syncChatListeners(String me, Map<String, String> names) {
    _names
      ..clear()
      ..addAll(names);

    // stop listening to contacts that were removed
    for (final uid in _chatSubs.keys.toList()) {
      if (!names.containsKey(uid)) {
        _chatSubs.remove(uid)?.cancel();
      }
    }

    // start listening to new contacts
    for (final uid in names.keys) {
      if (uid == me || _chatSubs.containsKey(uid)) continue;

      final chatId = ([me, uid]..sort()).join('_');
      _chatSubs[uid] = FirebaseDatabase.instance
          .ref('chats/$chatId/messages')
          .limitToLast(20)
          .onChildAdded
          .listen(
            (event) => _onMessage(me, uid, chatId, event),
        onError: (Object e) => debugPrint('Chat listener error: $e'),
      );
    }
  }

  // one listener for each group (also for groups I join later)
  static void _syncGroupListeners(String me, Set<String> ids) {
    // stop listening to groups I left
    for (final id in _groupSubs.keys.toList()) {
      if (!ids.contains(id)) {
        final subs = _groupSubs.remove(id);
        if (subs != null) {
          for (final s in subs) {
            s.cancel();
          }
        }
        _groupNames.remove(id);
      }
    }

    // start listening to new groups
    final db = FirebaseDatabase.instance;
    for (final id in ids) {
      if (_groupSubs.containsKey(id)) continue;

      _groupSubs[id] = [
        db.ref('groups/$id/name').onValue.listen(
              (event) => _groupNames[id] = (event.snapshot.value ?? '').toString(),
          onError: (Object e) => debugPrint('Group name listener error: $e'),
        ),
        db
            .ref('chats/$id/messages')
            .limitToLast(20)
            .onChildAdded
            .listen(
              (event) => _onGroupMessage(me, id, event),
          onError: (Object e) => debugPrint('Group chat listener error: $e'),
        ),
      ];
    }
  }

  static void _onMessage(
      String me,
      String contactUid,
      String chatId,
      DatabaseEvent event,
      ) {
    final data = event.snapshot.value;
    final key = event.snapshot.key ?? '';
    if (data is! Map || key.isEmpty) return;

    // every message is looked at only once
    if (!_notified.add('$chatId/$key')) return;

    // my own message
    if ((data['senderId'] ?? '').toString() == me) return;

    // an old message: it was already there before the app started
    final ts = data['timeMs'];
    final timeMs = ts is num ? ts.toInt() : 0;
    if (timeMs < _startMs) return;

    // already read
    final st = data['status'];
    if (st is num && st.toInt() >= 2) return;

    // I am looking at this chat right now
    if (_appInForeground && activeChatId == chatId) return;

    final name = _names[contactUid] ?? '';
    unawaited(
      NotificationService.showIncomingMessage(
        id: NotificationService.idFor(chatId, key),
        title: name.isEmpty ? 'New message' : name,
        body: _preview(data),
        payload: 'chat|$chatId|0|$contactUid',
      ),
    );
  }

  // a new message in one of my groups: "Group name" / "Asha: hello"
  static void _onGroupMessage(
      String me,
      String groupId,
      DatabaseEvent event,
      ) {
    final data = event.snapshot.value;
    final key = event.snapshot.key ?? '';
    if (data is! Map || key.isEmpty) return;

    if (!_notified.add('$groupId/$key')) return;

    final sender = (data['senderId'] ?? '').toString();
    if (sender == me) return;

    final ts = data['timeMs'];
    final timeMs = ts is num ? ts.toInt() : 0;
    if (timeMs < _startMs) return;

    if (_appInForeground && activeChatId == groupId) return;

    final groupName = _groupNames[groupId] ?? '';
    final who = _names[sender] ?? 'Someone';

    unawaited(
      NotificationService.showIncomingMessage(
        id: NotificationService.idFor(groupId, key),
        title: groupName.isEmpty ? 'New group message' : groupName,
        body: '$who: ${_preview(data)}',
        payload: 'chat|$groupId|1|$sender',
      ),
    );
  }

  // a short text for any kind of message
  static String _preview(Map data) {
    switch ((data['type'] ?? 'text').toString()) {
      case 'image':
        return '📷 Photo';
      case 'file':
        return '📄 ${data['fileName'] ?? 'Document'}';
      case 'contact':
        return '👤 ${data['contactName'] ?? 'Contact'}';
      default:
        final t = (data['text'] ?? '').toString();
        return t.length > 120 ? '${t.substring(0, 120)}…' : t;
    }
  }

  // stopped when the home screen closes (for example on logout)
  static void stop() {
    _contactsSub?.cancel();
    _contactsSub = null;
    _groupIdsSub?.cancel();
    _groupIdsSub = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    for (final s in _chatSubs.values) {
      s.cancel();
    }
    _chatSubs.clear();
    for (final subs in _groupSubs.values) {
      for (final s in subs) {
        s.cancel();
      }
    }
    _groupSubs.clear();
    _groupNames.clear();
    _names.clear();
    _notified.clear();
    activeChatId = '';
  }
}