import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';

// One shared item from a chat: a photo, a document or a link
class MediaEntry {
  final String id;
  final String kind; // 'image', 'file' or 'link'
  final DateTime time;
  final bool isMe;
  final String imageBase64; // photos are stored inside the database
  final String url; // document / old photo address, or the link itself
  final String title; // file name, or the text of the message with the link

  const MediaEntry({
    required this.id,
    required this.kind,
    required this.time,
    required this.isMe,
    this.imageBase64 = '',
    this.url = '',
    this.title = '',
  });
}

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

class MediaImage extends StatelessWidget {
  final MediaEntry entry;
  final BoxFit fit;
  final int? cacheWidth;

  const MediaImage({
    super.key,
    required this.entry,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final broken = Container(
      color: const Color(0xFFE9E4D8),
      child: const Center(
        child: Icon(Icons.broken_image, color: AppColors.textSoft),
      ),
    );

    final bytes = decodedImage(entry);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) => broken,
      );
    }

    if (entry.url.isNotEmpty) {
      return Image.network(
        entry.url,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (context, error, stack) => broken,
      );
    }

    return broken;
  }
}

// open a link or a document in the browser / another app
Future<void> openExternal(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  if (url.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Nothing to open here')),
    );
    return;
  }
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open this')),
      );
    }
  } catch (e) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open this')),
    );
  }
}

// full screen photo viewer: swipe left and right, pinch to zoom
class MediaViewerScreen extends StatefulWidget {
  final List<MediaEntry> images; // newest first
  final int initialIndex;
  final String otherName;

  const MediaViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.otherName,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late final PageController _controller =
  PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.images[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.isMe ? 'You' : widget.otherName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${formatDate(entry.time)}, ${formatClock(entry.time)}',
              style: GoogleFonts.poppins(
                color: const Color(0xB3FFFFFF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          child: Center(
            child: MediaImage(entry: widget.images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}