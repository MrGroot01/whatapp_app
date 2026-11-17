import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../services/group_service.dart';
import '../services/message_sync_service.dart';
import '../models/chat_row.dart';
import '../models/contact.dart';
import '../models/last_message.dart';


class ChatListProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Map<String, StreamSubscription<DatabaseEvent>> _lastSubs = {};
  final Map<String, LastMessage> _last = {};

  final Map<String, int> _clearedAt = {};
  StreamSubscription<DatabaseEvent>? _clearedSub;

  Timer? _clockTimer;
  bool _started = false;
  bool _disposed = false;

  String get _me => FirebaseAuth.instance.currentUser?.uid ?? '';

  void start() {
    if (_started) return;
    _started = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _listenCleared(uid);

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) => _notify());
  }

  String chatIdWith(String contactId) {
    return ([_me, contactId]..sort()).join('_');
  }

  void watchChat(String chatId) {
    if (_disposed || chatId.isEmpty || _lastSubs.containsKey(chatId)) return;

    _lastSubs[chatId] = _database
        .ref('chats/$chatId/messages')
        .limitToLast(1)
        .onValue
        .listen(
          (event) {
        if (_disposed) return;

        LastMessage? newest;
        final v = event.snapshot.value;
        if (v is Map) {
          for (final entry in v.entries) {
            final d = entry.value;
            if (d is Map) {
              newest = LastMessage.fromMap(Map<dynamic, dynamic>.from(d));
            }
          }
        }

        if (newest == null) {
          _last.remove(chatId);
        } else {
          _last[chatId] = newest;
        }
        notifyListeners();
      },
      onError: (Object e) {
        // for example: no permission for this chat
        debugPrint('[ChatListProvider] Last message error ($chatId): $e');
      },
    );
  }

  void forgetChat(String chatId) {
    _lastSubs.remove(chatId)?.cancel();
    _last.remove(chatId);
  }

  LastMessage? visibleLast(String chatId) {
    final m = _last[chatId];
    if (m == null) return null;
    if (m.expireAtMs > 0 && m.expireAtMs <= MessageSyncService.nowMs()) {
      return null;
    }
    final clearedAt = _clearedAt[chatId];
    if (clearedAt != null && m.timeMs <= clearedAt) return null;
    return m;
  }

  bool isHidden(String chatId) {
    return _clearedAt.containsKey(chatId) && visibleLast(chatId) == null;
  }

  List<ChatRow> buildRows({
    required List<Contact> contacts,
    required List<GroupItem> groups,
    required String query,
  }) {
    final q = query.toLowerCase();
    final searching = q.isNotEmpty;

    final rows = <ChatRow>[];

    for (final g in groups) {
      if (!g.name.toLowerCase().contains(q)) continue;
      if (!searching && isHidden(g.id)) continue;
      rows.add(ChatRow(group: g, timeMs: visibleLast(g.id)?.timeMs ?? 0));
    }

    for (final c in contacts) {
      // search finds a contact by name or phone number
      final matches = c.name.toLowerCase().contains(q) || c.phone.contains(q);
      if (!matches) continue;
      final chatId = chatIdWith(c.id);
      if (!searching && isHidden(chatId)) continue;
      rows.add(ChatRow(contact: c, timeMs: visibleLast(chatId)?.timeMs ?? 0));
    }

    rows.sort((a, b) {
      if (a.timeMs != b.timeMs) return b.timeMs.compareTo(a.timeMs);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return rows;
  }

  void _listenCleared(String uid) {
    _clearedSub = _database.ref('users/$uid/clearedChats').onValue.listen(
          (event) {
        if (_disposed) return;
        final map = <String, int>{};
        final v = event.snapshot.value;
        if (v is Map) {
          v.forEach((key, t) {
            if (t is num) map[key.toString()] = t.toInt();
          });
        }
        _clearedAt
          ..clear()
          ..addAll(map);
        notifyListeners();
      },
      onError: (Object e) =>
          debugPrint('[ChatListProvider] Cleared chats error: $e'),
    );
  }

  Future<void> deleteChatsForMe(Set<String> chatIds) async {
    final me = _me;
    if (me.isEmpty || chatIds.isEmpty) return;

    final updates = <String, Object?>{
      for (final id in chatIds)
        'users/$me/clearedChats/$id': ServerValue.timestamp,
    };
    await _database.ref().update(updates).timeout(
      const Duration(seconds: 15),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _clockTimer?.cancel();
    _clockTimer = null;
    _clearedSub?.cancel();
    _clearedSub = null;
    for (final s in _lastSubs.values) {
      s.cancel();
    }
    _lastSubs.clear();
    _last.clear();
    super.dispose();
  }
}