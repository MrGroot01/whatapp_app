import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/media_entry.dart';

final RegExp _linkPattern = RegExp(
  r'(https?://|www\.)[^\s]+',
  caseSensitive: false,
);

// the first web link inside a text, or null
String? firstLinkIn(String text) {
  final match = _linkPattern.firstMatch(text);
  if (match == null) return null;
  var link = match.group(0)!;
  // remove punctuation that is not part of the link
  link = link.replaceAll(RegExp(r'[.,;:!?)\]]+$'), '');
  if (link.toLowerCase().startsWith('www.')) link = 'https://$link';
  return link;
}

// turns the raw Firebase messages into photos / documents / links (newest first)
List<MediaEntry> parseMediaEntries(Object? value, String myUid) {
  final list = <MediaEntry>[];
  if (value is! Map) return list;

  value.forEach((key, data) {
    if (data is! Map) return;

    final id = key.toString();
    final type = (data['type'] ?? 'text').toString();
    final ts = data['timeMs'];
    final time = DateTime.fromMillisecondsSinceEpoch(
      ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
    );
    final isMe = data['senderId'] == myUid;

    if (type == 'image') {
      final b64 = (data['imageBase64'] ?? '').toString();
      final url = (data['url'] ?? '').toString();
      if (b64.isEmpty && url.isEmpty) return;
      list.add(MediaEntry(
        id: id,
        kind: 'image',
        time: time,
        isMe: isMe,
        imageBase64: b64,
        url: url,
      ));
    } else if (type == 'file') {
      final name = (data['fileName'] ?? data['text'] ?? '').toString();
      list.add(MediaEntry(
        id: id,
        kind: 'file',
        time: time,
        isMe: isMe,
        url: (data['url'] ?? '').toString(),
        title: name,
      ));
    } else if (type == 'text') {
      final text = (data['text'] ?? '').toString();
      final link = firstLinkIn(text);
      if (link != null) {
        list.add(MediaEntry(
          id: id,
          kind: 'link',
          time: time,
          isMe: isMe,
          url: link,
          title: text,
        ));
      }
    }
  });

  list.sort((a, b) => b.time.compareTo(a.time));
  return list;
}

// live list of everything shared in one chat
Stream<List<MediaEntry>> mediaStream(String chatId) {
  final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  return FirebaseDatabase.instance
      .ref('chats/$chatId/messages')
      .onValue
      .map((event) => parseMediaEntries(event.snapshot.value, myUid));
}

// ---------- DATES ----------
const List<String> _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> _longMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatDate(DateTime t) =>
    '${t.day} ${_shortMonths[t.month - 1]} ${t.year}';

String monthYear(DateTime t) => '${_longMonths[t.month - 1]} ${t.year}';

String formatClock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour >= 12 ? 'pm' : 'am'}';
}

// ---------- PHOTOS ----------
// decoding a photo takes time, so each one is decoded only once
final Map<String, Uint8List> _decodedImages = {};

Uint8List? decodedImage(MediaEntry e) {
  if (e.imageBase64.isEmpty) return null;
  final cached = _decodedImages[e.id];
  if (cached != null) return cached;
  try {
    final bytes = base64Decode(e.imageBase64);
    _decodedImages[e.id] = bytes;
    return bytes;
  } catch (_) {
    return null;
  }
}