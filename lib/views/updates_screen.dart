import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import 'create_status_screen.dart';
import '../models/status_entry.dart';
import '../providers/updates_provider.dart';
import '../services/status_service.dart';
import 'status_viewer_screen.dart';
import 'widgets/status_widgets.dart';

// The "Updates" tab: My status + recent updates from my contacts.
// It is only a body (no Scaffold), so home_screen.dart can show it under
// its own app bar and bottom bar. The constructor is the same as before,
// so home_screen.dart does not change.
//
// The provider is created here, inside the screen, so it stops when the
// tab is closed and never shows an old account's statuses.
class UpdatesScreen extends StatefulWidget {
  final List<StatusContact> contacts;

  const UpdatesScreen({super.key, required this.contacts});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  late final UpdatesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = UpdatesProvider(contacts: widget.contacts);
  }

  // Home gives a new contact list: the provider decides if anything changed
  @override
  void didUpdateWidget(covariant UpdatesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _provider.setContacts(widget.contacts);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const _UpdatesView(),
    );
  }
}

class _UpdatesView extends StatefulWidget {
  const _UpdatesView();

  @override
  State<_UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<_UpdatesView> {
  final ImagePicker _picker = ImagePicker();

  // ---------- ADD A STATUS ----------
  Future<void> _addText() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateStatusScreen()),
    );
  }

  Future<void> _addPhoto(ImageSource source) async {
    final l = context.l10n;
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 45,
        maxWidth: 1000,
        maxHeight: 1600,
      );
      if (x == null || !mounted) return;
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreateStatusScreen(image: File(x.path)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.couldNotOpenCameraOrGallery)),
      );
    }
  }

  Future<void> _showAddSheet() async {
    final l = context.l10n;
    final p = context.palette;

    Widget option(IconData icon, String label, Color color, VoidCallback go) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: TextStyle(color: p.textDark, fontSize: 17),
        ),
        onTap: () {
          Navigator.pop(context);
          go();
        },
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                l.addStatusTitle,
                style: TextStyle(
                  color: p.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            option(
              AppIcons.addStatusText,
              l.statusText,
              AppColors.emerald,
              _addText,
            ),
            option(
              AppIcons.camera,
              l.attachCamera,
              AppColors.attachCamera,
                  () => _addPhoto(ImageSource.camera),
            ),
            option(
              AppIcons.attachGallery,
              l.attachGallery,
              AppColors.attachGallery,
                  () => _addPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ---------- OPEN THE VIEWER ----------
  Future<void> _openViewer({
    required String uid,
    required String name,
    required Color color,
    required List<StatusItem> items,
    required bool mine,
  }) async {
    final updates = context.read<UpdatesProvider>();

    // my own statuses start at the first one, others at the first unseen
    final start = mine ? 0 : updates.firstUnseenIndex(items);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatusViewerScreen(
          ownerUid: uid,
          ownerName: name,
          color: color,
          items: items,
          isMine: mine,
          startIndex: start,
        ),
      ),
    );

    // the "seen" marks may have changed
    if (mounted) updates.refresh();
  }

  // ---------- UI ----------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        text,
        style: TextStyle(
          color: context.palette.textSoft,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _myStatusTile(List<StatusItem> mine) {
    final l = context.l10n;
    final p = context.palette;
    final me = StatusService.myUid;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          StatusAvatar(
            uid: me,
            name: StatusService.myName,
            color: AppColors.gold,
            count: mine.length,
            seen: 0,
          ),
          if (mine.isEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.background, width: 2),
                ),
                child: const Icon(
                  AppIcons.addEmoji,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        l.myStatus,
        style: TextStyle(
          color: p.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        mine.isEmpty
            ? l.tapToAddStatus
            : l.statusUpdatesLine(
          mine.length,
          StatusService.timeAgo(mine.last.createdAt),
        ),
        style: TextStyle(color: p.textSoft, fontSize: 15),
      ),
      trailing: mine.isEmpty
          ? null
          : IconButton(
        tooltip: l.addStatusTooltip,
        icon: Icon(
          AppIcons.addStatusFab,
          color: p.accent,
        ),
        onPressed: _showAddSheet,
      ),
      onTap: () {
        if (mine.isEmpty) {
          _showAddSheet();
        } else {
          _openViewer(
            uid: me,
            name: l.myStatus,
            color: AppColors.gold,
            items: mine,
            mine: true,
          );
        }
      },
    );
  }

  Widget _entryTile(StatusEntry e) {
    final p = context.palette;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: StatusAvatar(
        uid: e.contact.id,
        name: e.contact.name,
        color: e.contact.color,
        count: e.items.length,
        seen: e.items.length - e.unseen,
      ),
      title: Text(
        e.contact.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: p.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        StatusService.timeAgo(e.latest),
        style: TextStyle(color: p.textSoft, fontSize: 15),
      ),
      onTap: () => _openViewer(
        uid: e.contact.id,
        name: e.contact.name,
        color: e.contact.color,
        items: e.items,
        mine: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    // rebuilds whenever the provider changes (new status, tick, contacts...)
    final updates = context.watch<UpdatesProvider>();

    final mine = updates.mine;
    final recent = updates.recent;
    final viewed = updates.viewed;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 170),
          children: [
            _myStatusTile(mine),
            if (recent.isNotEmpty) ...[
              _sectionTitle(l.recentUpdates),
              for (final e in recent) _entryTile(e),
            ],
            if (viewed.isNotEmpty) ...[
              _sectionTitle(l.viewedUpdates),
              for (final e in viewed) _entryTile(e),
            ],
            if (recent.isEmpty && viewed.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                child: Text(
                  l.noRecentUpdates,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.textSoft,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'status_text_fab',
                backgroundColor: p.card,
                foregroundColor: p.accent,
                tooltip: l.textStatusTooltip,
                onPressed: _addText,
                child: const Icon(AppIcons.addStatusText),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'status_camera_fab',
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                tooltip: l.photoStatusTooltip,
                onPressed: () => _addPhoto(ImageSource.camera),
                child: const Icon(AppIcons.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }
}