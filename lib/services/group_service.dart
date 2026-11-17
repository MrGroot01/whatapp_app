import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'message_sync_service.dart';

// A saved contact chosen for a group
class PickedContact {
  final String id; // the account id
  final String name;
  final String phone;
  final String countryCode;

  const PickedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
  });
}

// What the "create group" flow gives back
class GroupRef {
  final String id;
  final String name;

  const GroupRef(this.id, this.name);
}

// How a member is shown (name + number)
class MemberInfo {
  final String name;
  final String phone;
  final bool saved; // true = this person is in my saved contacts

  const MemberInfo({
    required this.name,
    required this.phone,
    required this.saved,
  });
}

// One group, as stored in Firebase at groups/<groupId>
class GroupItem {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members; // account ids
  final Set<String> admins; // account ids

  const GroupItem({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.admins,
  });

  factory GroupItem.fromMap(String id, Map<dynamic, dynamic> data) {
    final members = <String>[];
    final rawMembers = data['members'];
    if (rawMembers is Map) {
      rawMembers.forEach((key, value) {
        if (value == true) members.add(key.toString());
      });
    }

    final admins = <String>{};
    final rawAdmins = data['admins'];
    if (rawAdmins is Map) {
      rawAdmins.forEach((key, value) {
        if (value == true) admins.add(key.toString());
      });
    }

    return GroupItem(
      id: id,
      name: (data['name'] ?? 'Group').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
      members: members,
      admins: admins,
    );
  }
}

// Everything that creates or changes a group.
//
// Firebase layout:
//   groups/<groupId>                 name, createdBy, createdAt, admins, members
//   users/<uid>/groups/<groupId>     true   (the list shown on each member's home screen)
//   chats/<groupId>/messages         the group messages (same format as 1-to-1 chats)
class GroupService {
  GroupService._();

  static final FirebaseDatabase _db = FirebaseDatabase.instance;
  static const Duration _timeout = Duration(seconds: 15);

  static String get _me => FirebaseAuth.instance.currentUser?.uid ?? '';

  // the same colours the rest of the app uses for avatars
  static Color colorFor(String key) {
    const colors = [
      Color(0xFFE91E63),
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFFF44336),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
    ];
    return colors[key.hashCode.abs() % colors.length];
  }

  static void _needInternet() {
    if (MessageSyncService.connection.value != ConnState.online) {
      throw Exception(
        'You are offline. Connect to the internet and try again.',
      );
    }
  }

  // ---------- CREATE ----------
  static Future<GroupRef> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    final me = _me;
    if (me.isEmpty) throw Exception('Please log in again');
    _needInternet();

    // the id has no "_" so it can never look like a 1-to-1 chat id
    final key = _db.ref('groups').push().key!;
    final id = 'grp${key.replaceAll('_', '-')}';

    final members = <String, bool>{me: true};
    for (final m in memberIds) {
      members[m] = true;
    }

    await _db.ref('groups/$id').set({
      'name': name,
      'createdBy': me,
      'createdAt': ServerValue.timestamp,
      'admins': {me: true},
      'members': members,
    }).timeout(_timeout);

    // put the group on every member's home screen
    await Future.wait(
      members.keys.map(
            (uid) => _db.ref('users/$uid/groups/$id').set(true).timeout(_timeout),
      ),
    );

    return GroupRef(id, name);
  }

  // ---------- CHANGE ----------
  static Future<void> renameGroup(String groupId, String name) async {
    _needInternet();
    await _db.ref('groups/$groupId/name').set(name).timeout(_timeout);
  }

  static Future<void> addMembers(String groupId, List<String> uids) async {
    _needInternet();
    for (final uid in uids) {
      await _db.ref('groups/$groupId/members/$uid').set(true).timeout(_timeout);
      await _db.ref('users/$uid/groups/$groupId').set(true).timeout(_timeout);
    }
  }

  // an admin removes somebody
  static Future<void> removeMember(String groupId, String uid) async {
    _needInternet();
    await _db.ref('groups/$groupId/members/$uid').remove().timeout(_timeout);
    await _db.ref('groups/$groupId/admins/$uid').remove().timeout(_timeout);
    await _db.ref('users/$uid/groups/$groupId').remove().timeout(_timeout);
  }

  // I leave the group
  static Future<void> leaveGroup(GroupItem g) async {
    final me = _me;
    if (me.isEmpty) throw Exception('Please log in again');
    _needInternet();

    final others = g.members.where((m) => m != me).toList();

    // the last person leaves: the group is deleted
    if (others.isEmpty) {
      try {
        await _db.ref('groups/${g.id}').remove().timeout(_timeout);
        await _db.ref('users/$me/groups/${g.id}').remove().timeout(_timeout);
        return;
      } catch (e) {
        debugPrint('Could not delete the empty group: $e');
      }
    } else {
      // I am the only admin: the next member becomes admin before I go
      final otherAdmins = g.admins.where((a) => a != me && others.contains(a));
      if (g.admins.contains(me) && otherAdmins.isEmpty) {
        await _db
            .ref('groups/${g.id}/admins/${others.first}')
            .set(true)
            .timeout(_timeout);
      }
    }

    await _db.ref('groups/${g.id}/admins/$me').remove().timeout(_timeout);
    await _db.ref('groups/${g.id}/members/$me').remove().timeout(_timeout);
    await _db.ref('users/$me/groups/${g.id}').remove().timeout(_timeout);
  }

  // ---------- NAMES ----------
  // account id -> the name and number to show.
  // A saved contact shows the name I saved; anybody else shows "~ their name".
  static Future<Map<String, MemberInfo>> resolveMembers(
      Iterable<String> ids,
      ) async {
    final me = _me;
    final result = <String, MemberInfo>{};

    Map<dynamic, dynamic> saved = {};
    try {
      final snap =
      await _db.ref('users/$me/contacts').get().timeout(_timeout);
      if (snap.value is Map) {
        saved = Map<dynamic, dynamic>.from(snap.value as Map);
      }
    } catch (e) {
      debugPrint('Could not read saved contacts: $e');
    }

    for (final uid in ids) {
      if (uid == me) continue;

      final c = saved[uid];
      if (c is Map) {
        result[uid] = MemberInfo(
          name: (c['name'] ?? 'Contact').toString(),
          phone: '${c['countryCode'] ?? ''} ${c['phone'] ?? ''}'.trim(),
          saved: true,
        );
        continue;
      }

      try {
        final snap =
        await _db.ref('publicProfiles/$uid').get().timeout(_timeout);
        final v = snap.value;
        if (v is Map) {
          final name = (v['name'] ?? '').toString();
          result[uid] = MemberInfo(
            name: name.isEmpty ? 'Member' : '~ $name',
            phone: '${v['countryCode'] ?? ''} ${v['phone'] ?? ''}'.trim(),
            saved: false,
          );
          continue;
        }
      } catch (e) {
        debugPrint('Could not read profile of $uid: $e');
      }

      result[uid] = const MemberInfo(name: 'Member', phone: '', saved: false);
    }

    return result;
  }
}