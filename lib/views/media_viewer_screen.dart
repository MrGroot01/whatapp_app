import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/media_entry.dart';
import '../chat_media.dart';
import 'widgets/media_widgets.dart';

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