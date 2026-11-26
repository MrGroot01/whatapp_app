import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_media.dart';
import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../models/media_entry.dart';
import 'media_viewer_screen.dart';
import 'widgets/media_widgets.dart';

class ChatMediaScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final int initialTab; // 0 = Media, 1 = Docs, 2 = Links

  const ChatMediaScreen({
    super.key,
    required this.chatId,
    required this.name,
    this.initialTab = 0,
  });

  @override
  State<ChatMediaScreen> createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen> {
  // created ONCE, so the screen does not re-subscribe on every redraw
  late final Stream<List<MediaEntry>> _stream = mediaStream(widget.chatId);

  void _openViewer(List<MediaEntry> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewerScreen(
          images: images,
          initialIndex: index,
          otherName: widget.name,
        ),
      ),
    );
  }

  Color _fileColor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return AppColors.filePdf;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return AppColors.fileDoc;
    }
    if (lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.csv')) {
      return AppColors.fileSheet;
    }
    if (lower.endsWith('.ppt') || lower.endsWith('.pptx')) {
      return AppColors.fileSlide;
    }
    return AppColors.fileOther;
  }

  Widget _empty(IconData icon, String text) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: p.emptyIcon),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: p.textSoft, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ---------- TAB 1: PHOTOS, grouped by month ----------
  Widget _mediaTab(List<MediaEntry> images) {
    final p = context.palette;

    if (images.isEmpty) {
      return _empty(AppIcons.media, context.l10n.noPhotosYet);
    }

    // the list is already newest first, so the months come in order
    final groups = <String, List<MediaEntry>>{};
    for (final e in images) {
      groups.putIfAbsent(monthYear(e.time), () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              group.key,
              style: GoogleFonts.poppins(
                color: p.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: group.value.length,
            itemBuilder: (context, i) {
              final entry = group.value[i];
              return GestureDetector(
                onTap: () => _openViewer(images, images.indexOf(entry)),
                child: MediaImage(
                  entry: entry,
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // ---------- TAB 2: DOCUMENTS ----------
  Widget _docsTab(List<MediaEntry> files) {
    final l = context.l10n;
    final p = context.palette;

    if (files.isEmpty) {
      return _empty(AppIcons.emptyDocs, l.noDocsYet);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 76,
        endIndent: 16,
        color: p.divider,
      ),
      itemBuilder: (context, i) {
        final e = files[i];
        final color = _fileColor(e.title);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(AppIcons.file, color: color, size: 26),
          ),
          title: Text(
            e.title.isEmpty ? l.attachDocument : e.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: p.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l.sharedBy(e.isMe ? l.you : widget.name, formatDate(e.time)),
            style: GoogleFonts.poppins(color: p.textSoft, fontSize: 12.5),
          ),
          onTap: () => openExternal(context, e.url),
        );
      },
    );
  }

  // ---------- TAB 3: LINKS ----------
  Widget _linksTab(List<MediaEntry> links) {
    final l = context.l10n;
    final p = context.palette;

    if (links.isEmpty) {
      return _empty(AppIcons.link, l.noLinksYet);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: links.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 76,
        endIndent: 16,
        color: p.divider,
      ),
      itemBuilder: (context, i) {
        final e = links[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.softGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(AppIcons.link, color: p.accent, size: 26),
          ),
          title: Text(
            e.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.linkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l.linkSubtitle(
              e.title,
              e.isMe ? l.you : widget.name,
              formatDate(e.time),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: p.textSoft, fontSize: 12.5),
          ),
          onTap: () => openExternal(context, e.url),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            widget.name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.onEmeraldHint,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: l.tabMedia),
              Tab(text: l.tabDocs),
              Tab(text: l.tabLinks),
            ],
          ),
        ),
        body: StreamBuilder<List<MediaEntry>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.couldNotLoadMedia,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: p.textSoft),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.emerald),
              );
            }

            final all = snapshot.data!;
            final images = all.where((e) => e.kind == 'image').toList();
            final files = all.where((e) => e.kind == 'file').toList();
            final links = all.where((e) => e.kind == 'link').toList();

            return TabBarView(
              children: [
                _mediaTab(images),
                _docsTab(files),
                _linksTab(links),
              ],
            );
          },
        ),
      ),
    );
  }
}