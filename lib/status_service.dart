import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'message_sync_service.dart';

// a contact whose status we want to watch (built in home_screen.dart)
class StatusContact {
  final String id;
  final String name;
  final Color color;

  const StatusContact({
    required this.id,
    required this.name,
    required this.color,
  });
}

// one person who has seen a status
class StatusViewer {
  final String uid;
  final String name;
  final int at;

  const StatusViewer({required this.uid, required this.name, required this.at});
}

// one status update (a text card or a photo)
class StatusItem {
  final String id;
  final String ownerUid;
  final String type; // 'text' or 'image'
  final String text;
  final String caption;
  final int bgColor;
  final int createdAt;
  final int expiresAt;
  final List<StatusViewer> viewers;

  const StatusItem({
    required this.id,
    required this.ownerUid,
    required this.type,
    required this.text,
    required this.caption,
    required this.bgColor,
    required this.createdAt,
    required this.expiresAt,
    required this.viewers,
  });

  bool get isImage => type == 'image';

  bool seenBy(String uid) => viewers.any((v) => v.uid == uid);

  static int _int(Object? v, [int fallback = 0]) =>
      v is num ? v.toInt() : fallback;

  factory StatusItem.fromMap(
      String ownerUid,
      String id,
      Map<dynamic, dynamic> data,
      ) {
    final viewers = <StatusViewer>[];
    final raw = data['viewers'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          viewers.add(
            StatusViewer(
              uid: key.toString(),
              name: (value['name'] ?? 'Someone').toString(),
              at: _int(value['at']),
            ),
          );
        }
      });
    }
    viewers.sort((a, b) => b.at.compareTo(a.at));

    return StatusItem(
      id: id,
      ownerUid: ownerUid,
      type: (data['type'] ?? 'text').toString(),
      text: (data['text'] ?? '').toString(),
      caption: (data['caption'] ?? '').toString(),
      bgColor: _int(data['bgColor'], 0xFF0B6B57),
      createdAt: _int(data['createdAt']),
      expiresAt: _int(data['expiresAt']),
      viewers: viewers,
    );
  }
}

class StatusService {
  StatusService._();


  static const Duration lifetime = Duration(minutes: 5);


  static const int _maxImageChars = 1200000;

  // background colours for text statuses
  static const List<Color> backgrounds = [
    Color(0xFF0B6B57),
    Color(0xFF3F51B5),
    Color(0xFFAC44CF),
    Color(0xFFD3396D),
    Color(0xFFE65100),
    Color(0xFF455A64),
    Color(0xFF1B5E20),
    Color(0xFF6A1B9A),
  ];

  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  static String get myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static String get myName {
    final u = FirebaseAuth.instance.currentUser;
    return (u?.displayName?.isNotEmpty ?? false)
        ? u!.displayName!
        : (u?.email ?? 'Someone');
  }

  // Firebase server time (the phone clock, corrected)
  static int nowMs() => MessageSyncService.nowMs();

  // only the statuses that have not expired yet
  static List<StatusItem> active(List<StatusItem> list) {
    final now = nowMs();
    return list.where((i) => i.expiresAt > now).toList();
  }

  static List<StatusItem> _parse(String ownerUid, Object? value) {
    final list = <StatusItem>[];
    if (value is Map) {
      value.forEach((key, data) {
        if (data is Map) {
          list.add(StatusItem.fromMap(ownerUid, key.toString(), data));
        }
      });
    }
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  // live list of one person's statuses (expired ones are filtered by the UI)
  static Stream<List<StatusItem>> watch(String ownerUid) {
    return _db
        .ref('statuses/$ownerUid')
        .onValue
        .map((event) => _parse(ownerUid, event.snapshot.value));
  }

  // ---------- POST ----------
  static Future<void> postText(String text, int bgColor) async {
    final uid = myUid;
    if (uid.isEmpty) throw Exception('Please log in again');

    final now = nowMs();
    await _db.ref('statuses/$uid').push().set({
      'type': 'text',
      'text': text,
      'bgColor': bgColor,
      'createdAt': now,
      'expiresAt': now + lifetime.inMilliseconds,
    }).timeout(const Duration(seconds: 15));
  }

  static Future<void> postImage(File file, String caption) async {
    final uid = myUid;
    if (uid.isEmpty) throw Exception('Please log in again');

    final bytes = await file.readAsBytes();
    final encoded = base64Encode(bytes);
    if (encoded.length > _maxImageChars) {
      throw Exception('Photo is too large. Please choose a smaller one.');
    }

    final ref = _db.ref('statuses/$uid').push();
    final id = ref.key!;
    final now = nowMs();

    // the photo first, then the status card that points to it,
    // so nobody sees a status whose photo is missing
    await _db
        .ref('statusMedia/$uid/$id')
        .set(encoded)
        .timeout(const Duration(seconds: 30));

    final data = <String, dynamic>{
      'type': 'image',
      'bgColor': 0xFF000000,
      'createdAt': now,
      'expiresAt': now + lifetime.inMilliseconds,
    };
    if (caption.isNotEmpty) data['caption'] = caption;

    await ref.set(data).timeout(const Duration(seconds: 15));
  }

  // ---------- READ A PHOTO ----------
  static Future<String?> loadImage(String ownerUid, String statusId) async {
    try {
      final snap = await _db
          .ref('statusMedia/$ownerUid/$statusId')
          .get()
          .timeout(const Duration(seconds: 20));
      final v = snap.value;
      return v is String ? v : null;
    } catch (e) {
      debugPrint('Status photo failed: $e');
      return null;
    }
  }

  // ---------- SEEN ----------
  static Future<void> markSeen(String ownerUid, String statusId) async {
    final me = myUid;
    if (me.isEmpty || me == ownerUid) return;
    try {
      await _db.ref('statuses/$ownerUid/$statusId/viewers/$me').set({
        'at': ServerValue.timestamp,
        'name': myName,
      });
    } catch (e) {
      // already marked, or the status was just removed: nothing to do
      debugPrint('markSeen: $e');
    }
  }

  // ---------- DELETE / CLEAN UP ----------
  static Future<void> delete(String statusId) async {
    final uid = myUid;
    if (uid.isEmpty) return;
    try {
      await _db.ref('statuses/$uid/$statusId').remove();
      await _db.ref('statusMedia/$uid/$statusId').remove();
    } catch (e) {
      debugPrint('Status delete failed: $e');
    }
  }

  // removes MY statuses that have expired (so the database stays small)
  static Future<void> cleanupMine() async {
    final uid = myUid;
    if (uid.isEmpty) return;
    try {
      final snap = await _db.ref('statuses/$uid').get();
      final all = _parse(uid, snap.value);
      final now = nowMs();
      for (final item in all) {
        if (item.expiresAt <= now) await delete(item.id);
      }
    } catch (e) {
      debugPrint('Status cleanup failed: $e');
    }
  }

  // ---------- TEXT HELPERS ----------
  static String timeAgo(int ms) {
    final minutes = (nowMs() - ms) ~/ 60000;
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return '$minutes min ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours hr ago';
    return 'Yesterday';
  }
}