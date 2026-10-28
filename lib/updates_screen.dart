import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'app_theme.dart';
import 'create_status_screen.dart';
import 'status_service.dart';
import 'status_viewer_screen.dart';
import 'status_widgets.dart';

class _Entry {
  final StatusContact contact;
  final List<StatusItem> items;

  _Entry(this.contact, this.items);

  int get unseen =>
      items.where((i) => !i.seenBy(StatusService.myUid)).length;

  int get latest => items.last.createdAt;
}

// The "Updates" tab: My status + recent updates from my contacts.
// It is only a body (no Scaffold), so home_screen.dart can show it under
// its own app bar and bottom bar.
class UpdatesScreen extends StatefulWidget {
  final List<StatusContact> contacts;

  const UpdatesScreen({super.key, required this.contacts});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final Map<String, StreamSubscription<List<StatusItem>>> _subs = {};
  final Map<String, List<StatusItem>> _items = {};
  StreamSubscription<List<StatusItem>>? _mineSub;
  List<StatusItem> _mine = [];
  Timer? _tick;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final me = StatusService.myUid;
    if (me.isNotEmpty) {
      _mineSub = StatusService.watch(me).listen((list) {
        if (mounted) setState(() => _mine = list);
      }, onError: (Object e) => debugPrint('My status error: $e'));
    }

    _syncSubscriptions();
    StatusService.cleanupMine();

    // every 20 seconds: hide expired statuses and clean up my old ones
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      setState(() {});
      StatusService.cleanupMine();
    });
  }

  @override
  void didUpdateWidget(covariant UpdatesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSubscriptions();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _mineSub?.cancel();
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    super.dispose();
  }

  // watch the statuses of every contact in my list
  void _syncSubscriptions() {
    final ids = widget.contacts.map((c) => c.id).toSet();

    for (final id in _subs.keys.toList()) {
      if (!ids.contains(id)) {
        _subs.remove(id)?.cancel();
        _items.remove(id);
      }
    }

    for (final id in ids) {
      if (_subs.containsKey(id)) continue;
      _subs[id] = StatusService.watch(id).listen(
            (list) {
          if (mounted) setState(() => _items[id] = list);
        },
        onError: (Object e) => debugPrint('Status of $id: $e'),
      );
    }
  }

  // ---------- ADD A STATUS ----------
  Future<void> _addText() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateStatusScreen()),
    );
  }

  Future<void> _addPhoto(ImageSource source) async {
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
        const SnackBar(content: Text('Could not open the camera or gallery')),
      );
    }
  }

  Future<void> _showAddSheet() async {
    Widget option(IconData icon, String label, Color color, VoidCallback go) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(color: AppColors.textDark, fontSize: 17),
        ),
        onTap: () {
          Navigator.pop(context);
          go();
        },
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Add status',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            option(Icons.edit, 'Text', const Color(0xFF0B6B57), _addText),
            option(
              Icons.camera_alt,
              'Camera',
              const Color(0xFFD3396D),
                  () => _addPhoto(ImageSource.camera),
            ),
            option(
              Icons.photo,
              'Gallery',
              const Color(0xFFAC44CF),
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
    var start = 0;
    if (!mine) {
      final firstUnseen =
      items.indexWhere((i) => !i.seenBy(StatusService.myUid));
      start = firstUnseen < 0 ? 0 : firstUnseen;
    }

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

    if (mounted) setState(() {});
  }

  // ---------- UI ----------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _myStatusTile(List<StatusItem> mine) {
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
      title: const Text(
        'My status',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        mine.isEmpty
            ? 'Tap to add status update'
            : '${mine.length} update${mine.length == 1 ? '' : 's'} · '
            '${StatusService.timeAgo(mine.last.createdAt)}',
        style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
      ),
      trailing: mine.isEmpty
          ? null
          : IconButton(
        tooltip: 'Add status',
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.emerald,
        ),
        onPressed: _showAddSheet,
      ),
      onTap: () {
        if (mine.isEmpty) {
          _showAddSheet();
        } else {
          _openViewer(
            uid: me,
            name: 'My status',
            color: AppColors.gold,
            items: mine,
            mine: true,
          );
        }
      },
    );
  }

  Widget _entryTile(_Entry e) {
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
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        StatusService.timeAgo(e.latest),
        style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
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
    final mine = StatusService.active(_mine);

    final recent = <_Entry>[];
    final viewed = <_Entry>[];
    for (final c in widget.contacts) {
      final list = StatusService.active(_items[c.id] ?? const []);
      if (list.isEmpty) continue;
      final entry = _Entry(c, list);
      (entry.unseen > 0 ? recent : viewed).add(entry);
    }
    recent.sort((a, b) => b.latest.compareTo(a.latest));
    viewed.sort((a, b) => b.latest.compareTo(a.latest));

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 170),
          children: [
            _myStatusTile(mine),
            if (recent.isNotEmpty) ...[
              _sectionTitle('Recent updates'),
              for (final e in recent) _entryTile(e),
            ],
            if (viewed.isNotEmpty) ...[
              _sectionTitle('Viewed updates'),
              for (final e in viewed) _entryTile(e),
            ],
            if (recent.isEmpty && viewed.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 40, 32, 0),
                child: Text(
                  'No recent updates.\nStatuses from your contacts appear here '
                      'and disappear after a short time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
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
                backgroundColor: Colors.white,
                foregroundColor: AppColors.emerald,
                tooltip: 'Text status',
                onPressed: _addText,
                child: const Icon(Icons.edit),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'status_camera_fab',
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                tooltip: 'Photo status',
                onPressed: () => _addPhoto(ImageSource.camera),
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}