// A photo from a chat (stored as Base64, or an old web address).
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/chat_media.dart';
import '../../core/app_icons.dart';
import '../../core/app_localization.dart';
import '../../core/app_theme.dart';
import '../../models/media_entry.dart';

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
    final p = context.palette;

    final broken = Container(
      color: p.divider,
      child: Center(
        child: Icon(AppIcons.brokenImage, color: p.textSoft),
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
  final l = context.l10n; // read before any "await"

  if (url.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l.nothingToOpen)));
    return;
  }
  try {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.couldNotOpenThis)));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l.couldNotOpenThis)));
  }
}