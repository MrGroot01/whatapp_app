import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/media_entry.dart';
import '../../chat_media.dart';
import '../app_theme.dart';

// A photo from a chat (stored as Base64, or an old web address).
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