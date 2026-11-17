import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../services/group_service.dart';

class GroupChatProvider extends ChangeNotifier {
  GroupChatProvider({required this.groupId, required this.myUid});

  final String groupId;
  final String myUid;

  // the screen sets this: "I am no longer in this group"
  void Function()? onLeft;

  StreamSubscription<DatabaseEvent>? _subscription;
  String _groupName = '';
  List<String> _memberIds = [];
  Set<String> _adminIds = {};
  final Map<String, String> _memberNames = {}; // account id -> name to show
  final Set<String> _resolving = {};
  bool _left = false;
  bool _disposed = false;

  String get groupName => _groupName;
  List<String> get memberIds => _memberIds;
  bool get isAdmin => _adminIds.contains(myUid);

  String? nameOf(String id) => _memberNames[id];

  String get membersLine {
    final names = <String>[];
    for (final id in _memberIds) {
      names.add(id == myUid ? 'You' : (_memberNames[id] ?? '...'));
    }
    names.sort((a, b) {
      if (a == 'You') return -1;
      if (b == 'You') return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return names.join(', ');
  }

  void start() {
    if (_subscription != null) return;

    _subscription = FirebaseDatabase.instance
        .ref('groups/$groupId')
        .onValue
        .listen(
          (event) {
        final v = event.snapshot.value;
        if (v is! Map) {
          _leave();
          return;
        }
        final g = GroupItem.fromMap(groupId, Map<dynamic, dynamic>.from(v));
        if (!g.members.contains(myUid)) {
          _leave();
          return;
        }
        if (_disposed) return;
        _groupName = g.name;
        _memberIds = g.members;
        _adminIds = g.admins;
        notifyListeners();
        resolveNames(g.members);
      },
      onError: (Object e) {
        debugPrint('Group listener error: $e');
        if (e is FirebaseException && e.code == 'permission-denied') {
          _leave();
        }
      },
    );
  }

  void _leave() {
    if (_left || _disposed) return;
    _left = true;
    onLeft?.call();
  }

  Future<void> resolveNames(Iterable<String> ids) async {
    final todo = ids
        .where(
          (id) =>
      id.isNotEmpty &&
          id != myUid &&
          !_memberNames.containsKey(id) &&
          !_resolving.contains(id),
    )
        .toList();
    if (todo.isEmpty) return;

    _resolving.addAll(todo);
    final found = await GroupService.resolveMembers(todo);
    _resolving.removeAll(todo);

    if (_disposed) return;
    found.forEach((id, info) {
      _memberNames[id] = info.name;
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}