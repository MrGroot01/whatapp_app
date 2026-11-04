import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../group_service.dart';

class GroupsProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Map<String, GroupItem> _groups = {};
  final Map<String, StreamSubscription<DatabaseEvent>> _groupSubs = {};
  StreamSubscription<DatabaseEvent>? _indexSub;
  bool _disposed = false;

  void Function(String groupId)? onGroupAdded;
  void Function(String groupId)? onGroupRemoved;

  List<GroupItem> get groups => _groups.values.toList();
  bool get isEmpty => _groups.isEmpty;

  void start() {
    if (_indexSub != null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _indexSub = _database.ref('users/$uid/groups').onValue.listen(
          (event) {
        if (_disposed) return;

        final ids = <String>{};
        final value = event.snapshot.value;
        if (value is Map) {
          value.forEach((key, v) {
            if (v == true) ids.add(key.toString());
          });
        }

        // stop watching groups I left
        for (final id in _groupSubs.keys.toList()) {
          if (!ids.contains(id)) {
            _groupSubs.remove(id)?.cancel();
            _groups.remove(id);
            onGroupRemoved?.call(id);
          }
        }

        // start watching new groups
        for (final id in ids) {
          if (_groupSubs.containsKey(id)) continue;
          onGroupAdded?.call(id);
          _groupSubs[id] = _database.ref('groups/$id').onValue.listen(
                (e) {
              if (_disposed) return;
              final gv = e.snapshot.value;
              if (gv is Map) {
                _groups[id] = GroupItem.fromMap(
                  id,
                  Map<dynamic, dynamic>.from(gv),
                );
              } else {
                _groups.remove(id);
              }
              notifyListeners();
            },
            onError: (Object err) {
              debugPrint('[GroupsProvider] Group $id error: $err');
              if (_disposed) return;
              _groups.remove(id);
              notifyListeners();
            },
          );
        }

        notifyListeners();
      },
      onError: (Object e) =>
          debugPrint('[GroupsProvider] Group list error: $e'),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _indexSub?.cancel();
    _indexSub = null;
    for (final s in _groupSubs.values) {
      s.cancel();
    }
    _groupSubs.clear();
    onGroupAdded = null;
    onGroupRemoved = null;
    super.dispose();
  }
}