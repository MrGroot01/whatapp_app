import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/media_entry.dart';
import '../chat_media.dart';
import '../group_service.dart';

// ---------- disappearing messages: the choices ----------
class DisappearOption {
  final String label;
  final int ms; // 0 = off

  const DisappearOption(this.label, this.ms);
}

const List<DisappearOption> disappearOptions = [
  DisappearOption('Off', 0),
  DisappearOption('5 minutes', 300000),
  DisappearOption('1 day', 86400000),
  DisappearOption('7 days', 604800000),
];

String disappearLabel(int ms) {
  for (final o in disappearOptions) {
    if (o.ms == ms) return o.label;
  }
  return 'Off';
}

// The controller for the "Group info" screen.
// It watches the group live (name, members, admins), finds the names of the
// members, watches the disappearing-messages setting and the media count,
// and does the admin actions (rename, add, remove) and "Exit group".
//
// The screen only draws. Actions return:
//   null      = it worked (or nothing to do)
//   a String  = the error text for the snack bar
//
// The provider talks to the screen through two callbacks:
//   onGroupGone = the group was deleted or I was removed (screen closes)
//   onExited    = I left the group (screen closes)
class GroupInfoProvider extends ChangeNotifier {
  GroupInfoProvider({required this.groupId}) {
    _start();
  }

  final String groupId;

  VoidCallback? onGroupGone;
  VoidCallback? onExited;

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  StreamSubscription<DatabaseEvent>? _groupSub;
  StreamSubscription<DatabaseEvent>? _disappearSub;
  StreamSubscription<List<MediaEntry>>? _mediaSub;

  GroupItem? _group;
  final Map<String, MemberInfo> _infos = {};
  final Set<String> _resolving = {};
  int _disappearMs = 0; // 0 = off
  int _mediaCount = 0;
  bool _busy = false;
  bool _leaving = false;
  bool _disposed = false;

  // ---------- WHAT THE SCREEN READS ----------
  String get me => FirebaseAuth.instance.currentUser?.uid ?? '';

  GroupItem? get group => _group;
  bool get busy => _busy;
  int get disappearMs => _disappearMs;
  int get mediaCount => _mediaCount;
  bool get isAdmin => _group?.admins.contains(me) ?? false;

  MemberInfo? infoOf(String uid) => _infos[uid];

  String nameOf(String uid) =>
      uid == me ? 'You' : (_infos[uid]?.name ?? 'Member');

  // me first, then the others A-Z
  List<String> get orderedMembers {
    final g = _group;
    if (g == null) return const [];

    final others = g.members.where((m) => m != me).toList()
      ..sort(
            (a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()),
      );
    return [if (g.members.contains(me)) me, ...others];
  }

  // ---------- START ----------
  void _start() {
    // the group itself (name, members, admins)
    _groupSub = _db.ref('groups/$groupId').onValue.listen(
          (event) {
        final v = event.snapshot.value;
        if (v is! Map) {
          _closeIfNeeded(); // the group was deleted
          return;
        }

        final g = GroupItem.fromMap(groupId, Map<dynamic, dynamic>.from(v));
        _group = g;
        _safeNotify();
        _resolve(g.members);
      },
      onError: (Object e) {
        debugPrint('Group info listener error: $e');
        _closeIfNeeded(); // for example: I was removed from the group
      },
    );

    // the disappearing-messages setting (shared by everybody in the group)
    _disappearSub = _db
        .ref('chats/$groupId/settings/disappearAfterMs')
        .onValue
        .listen(
          (event) {
        final v = event.snapshot.value;
        _disappearMs = v is num ? v.toInt() : 0;
        _safeNotify();
      },
      onError: (Object e) => debugPrint('Disappear setting error: $e'),
    );

    // how many photos, documents and links were shared
    _mediaSub = mediaStream(groupId).listen(
          (list) {
        _mediaCount = list.length;
        _safeNotify();
      },
      onError: (Object e) => debugPrint('Media count error: $e'),
    );
  }

  // the group was deleted, or I was removed from it
  void _closeIfNeeded() {
    if (_leaving || _disposed) return;
    onGroupGone?.call();
  }

  // find the names of the members (saved contact name, or "~ their name")
  Future<void> _resolve(Iterable<String> ids) async {
    final todo = ids
        .where(
          (id) =>
      id != me && !_infos.containsKey(id) && !_resolving.contains(id),
    )
        .toList();
    if (todo.isEmpty) return;

    _resolving.addAll(todo);
    final found = await GroupService.resolveMembers(todo);
    _resolving.removeAll(todo);

    if (_disposed) return;
    _infos.addAll(found);
    _safeNotify();
  }

  // ---------- ADMIN ACTIONS ----------
  Future<String?> rename(String newName) {
    return _run(
          () => GroupService.renameGroup(groupId, newName),
      'Could not rename the group',
    );
  }

  Future<String?> addMembers(List<String> ids) {
    return _run(
          () => GroupService.addMembers(groupId, ids),
      'Could not add the members',
    );
  }

  Future<String?> removeMember(String uid) {
    return _run(
          () => GroupService.removeMember(groupId, uid),
      'Could not remove this member',
    );
  }

  // I leave the group. On success it calls onExited.
  Future<String?> exitGroup() async {
    final g = _group;
    if (g == null) return null;

    _leaving = true; // so the "I was removed" listener does not close twice
    _busy = true;
    _safeNotify();

    try {
      await GroupService.leaveGroup(g);
      onExited?.call();
      return null;
    } catch (e) {
      _leaving = false;
      debugPrint('Exit group failed: $e');
      return _errorText(e, 'Could not exit the group');
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  // ---------- DISAPPEARING MESSAGES ----------
  Future<String?> setDisappear(int ms) async {
    try {
      final ref = _db.ref('chats/$groupId/settings/disappearAfterMs');
      if (ms == 0) {
        await ref.remove();
      } else {
        await ref.set(ms);
      }
      return null;
    } catch (e) {
      debugPrint('Disappear setting failed: $e');
      return 'Could not change the setting. Check your internet.';
    }
  }

  // ---------- HELPERS ----------
  // runs one action with the progress bar, and gives back null or the error
  Future<String?> _run(
      Future<void> Function() action,
      String failMessage,
      ) async {
    if (_busy) return null;

    _busy = true;
    _safeNotify();

    try {
      await action();
      return null;
    } catch (e) {
      debugPrint('Group action failed: $e');
      return _errorText(e, failMessage);
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  // the offline message is shown as it is; anything else gets a short text
  String _errorText(Object e, String failMessage) {
    final text = e.toString().replaceFirst('Exception: ', '');
    return text.startsWith('You are offline') ? text : failMessage;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _groupSub?.cancel();
    _disappearSub?.cancel();
    _mediaSub?.cancel();
    super.dispose();
  }
}