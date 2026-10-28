import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'chat_media.dart';
import 'chat_media_screen.dart';
import 'group_member_picker.dart';
import 'group_service.dart';

// WhatsApp-style "Group info": name, members, admin tools, exit group.
class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late final DatabaseReference _groupRef = FirebaseDatabase.instance.ref(
    'groups/${widget.groupId}',
  );
  late final DatabaseReference _disappearRef = FirebaseDatabase.instance.ref(
    'chats/${widget.groupId}/settings/disappearAfterMs',
  );
  late final Stream<DatabaseEvent> _disappearStream = _disappearRef.onValue;
  late final Stream<List<MediaEntry>> _mediaStream = mediaStream(
    widget.groupId,
  );

  static const List<List<Object>> _disappearOptions = [
    ['Off', 0],
    ['5 minutes', 300000],
    ['1 day', 86400000],
    ['7 days', 604800000],
  ];

  StreamSubscription<DatabaseEvent>? _sub;
  GroupItem? _group;
  final Map<String, MemberInfo> _infos = {};
  final Set<String> _resolving = {};
  bool _leaving = false;
  bool _busy = false;

  String get _me => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isAdmin => _group?.admins.contains(_me) ?? false;

  @override
  void initState() {
    super.initState();
    _sub = _groupRef.onValue.listen(
          (event) {
        final v = event.snapshot.value;
        if (v is! Map) {
          _closeIfNeeded();
          return;
        }
        final g = GroupItem.fromMap(
          widget.groupId,
          Map<dynamic, dynamic>.from(v),
        );
        if (!mounted) return;
        setState(() => _group = g);
        _resolve(g.members);
      },
      onError: (Object e) {
        debugPrint('Group info listener error: $e');
        _closeIfNeeded();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // the group was deleted, or I was removed from it
  void _closeIfNeeded() {
    if (_leaving || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _resolve(Iterable<String> ids) async {
    final todo = ids
        .where(
          (id) =>
      id != _me && !_infos.containsKey(id) && !_resolving.contains(id),
    )
        .toList();
    if (todo.isEmpty) return;

    _resolving.addAll(todo);
    final found = await GroupService.resolveMembers(todo);
    _resolving.removeAll(todo);

    if (!mounted) return;
    setState(() => _infos.addAll(found));
  }

  String _nameOf(String uid) =>
      uid == _me ? 'You' : (_infos[uid]?.name ?? 'Member');

  // me first, then the others A-Z
  List<String> _orderedMembers(GroupItem g) {
    final others = g.members.where((m) => m != _me).toList()
      ..sort(
            (a, b) => _nameOf(a).toLowerCase().compareTo(_nameOf(b).toLowerCase()),
      );
    return [if (g.members.contains(_me)) _me, ...others];
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // runs one action and shows a message if it fails
  Future<void> _run(
      Future<void> Function() action,
      String failMessage,
      ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      debugPrint('Group action failed: $e');
      final text = e.toString().replaceFirst('Exception: ', '');
      _snack(text.startsWith('You are offline') ? text : failMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm(String title, String message, String action) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: AppColors.textSoft, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              action,
              style: GoogleFonts.poppins(
                color: const Color(0xFFD94B4B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ADMIN ACTIONS ----------
  Future<void> _rename() async {
    final g = _group;
    if (g == null) return;

    final controller = TextEditingController(text: g.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Group name',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          cursorColor: AppColors.emerald,
          style: GoogleFonts.poppins(color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: AppColors.emerald,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == g.name) return;
    await _run(
          () => GroupService.renameGroup(widget.groupId, newName),
      'Could not rename the group',
    );
  }

  Future<void> _addMembers() async {
    final g = _group;
    if (g == null) return;

    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => GroupMemberPickerScreen(
          addMode: true,
          excludeIds: g.members.toSet(),
        ),
      ),
    );

    if (!mounted || result is! List<PickedContact> || result.isEmpty) return;
    final ids = result.map((c) => c.id).toList();

    await _run(
          () => GroupService.addMembers(widget.groupId, ids),
      'Could not add the members',
    );
  }

  Future<void> _removeMember(String uid) async {
    final ok = await _confirm(
      'Remove ${_nameOf(uid)}?',
      'They will not receive new messages from this group.',
      'Remove',
    );
    if (ok != true) return;

    await _run(
          () => GroupService.removeMember(widget.groupId, uid),
      'Could not remove this member',
    );
  }

  Future<void> _exitGroup() async {
    final g = _group;
    if (g == null) return;

    final ok = await _confirm(
      'Exit group?',
      'You will no longer receive messages from this group.',
      'Exit',
    );
    if (ok != true) return;

    _leaving = true;
    if (mounted) setState(() => _busy = true);

    try {
      await GroupService.leaveGroup(g);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _leaving = false;
      debugPrint('Exit group failed: $e');
      final text = e.toString().replaceFirst('Exception: ', '');
      _snack(
        text.startsWith('You are offline') ? text : 'Could not exit the group',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---------- DISAPPEARING MESSAGES ----------
  String _disappearLabel(int ms) {
    for (final o in _disappearOptions) {
      if (o[1] == ms) return o[0] as String;
    }
    return 'Off';
  }

  Future<void> _setDisappear(int ms) async {
    try {
      if (ms == 0) {
        await _disappearRef.remove();
      } else {
        await _disappearRef.set(ms);
      }
    } catch (e) {
      _snack('Could not change the setting. Check your internet.');
    }
  }

  void _showDisappearSheet(int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Disappearing messages',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'New messages in this group will disappear after the time you choose.',
                style: GoogleFonts.poppins(
                  color: AppColors.textSoft,
                  fontSize: 13,
                ),
              ),
            ),
            for (final o in _disappearOptions)
              ListTile(
                title: Text(
                  o[0] as String,
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                ),
                trailing: current == o[1]
                    ? const Icon(Icons.check_circle, color: AppColors.emerald)
                    : const Icon(
                  Icons.circle_outlined,
                  color: AppColors.textSoft,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setDisappear(o[1] as int);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------- UI PIECES ----------
  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textSoft, size: 25),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: color ?? AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: AppColors.textSoft,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _memberTile(GroupItem g, String uid) {
    final isMe = uid == _me;
    final info = _infos[uid];
    final name = _nameOf(uid);

    return Material(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: GroupService.colorFor(uid),
          child: Text(
            name.replaceAll('~', '').trim().isNotEmpty
                ? name.replaceAll('~', '').trim()[0].toUpperCase()
                : '?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isMe || info == null || info.phone.isEmpty
            ? null
            : Text(
          info.phone,
          style: GoogleFonts.poppins(
            color: AppColors.textSoft,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (g.admins.contains(uid))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.emerald),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Group admin',
                  style: GoogleFonts.poppins(
                    color: AppColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            if (_isAdmin && !isMe)
              IconButton(
                tooltip: 'Remove from group',
                icon: const Icon(
                  Icons.person_remove_outlined,
                  color: Color(0xFFD94B4B),
                ),
                onPressed: _busy ? null : () => _removeMember(uid),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = _group;
    final name = g?.name ?? widget.groupName;
    final members = g == null ? <String>[] : _orderedMembers(g);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: Text(
          'Group info',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: GroupService.colorFor(widget.groupId),
                      child: const Icon(
                        Icons.group,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isAdmin)
                          IconButton(
                            tooltip: 'Change group name',
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.emerald,
                              size: 20,
                            ),
                            onPressed: _busy ? null : _rename,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group · ${members.length} members',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<MediaEntry>>(
                stream: _mediaStream,
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _tile(
                    icon: Icons.photo_library_outlined,
                    title: 'Media, links, and docs',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (count > 0)
                          Text(
                            '$count',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSoft,
                              fontSize: 14,
                            ),
                          ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSoft,
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatMediaScreen(
                          chatId: widget.groupId,
                          name: name,
                        ),
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<DatabaseEvent>(
                stream: _disappearStream,
                builder: (context, snap) {
                  final v = snap.data?.snapshot.value;
                  final ms = v is num ? v.toInt() : 0;
                  return _tile(
                    icon: Icons.timer_outlined,
                    title: 'Disappearing messages',
                    subtitle: _disappearLabel(ms),
                    onTap: () => _showDisappearSheet(ms),
                  );
                },
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Text(
                  '${members.length} members',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSoft,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isAdmin)
                Material(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.emerald,
                      child: Icon(Icons.person_add, color: Colors.white),
                    ),
                    title: Text(
                      'Add members',
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _busy ? null : _addMembers,
                  ),
                ),
              if (g != null)
                for (final uid in members) _memberTile(g, uid),
              const SizedBox(height: 8),
              _tile(
                icon: Icons.exit_to_app,
                title: 'Exit group',
                color: const Color(0xFFD94B4B),
                onTap: _busy ? () {} : _exitGroup,
              ),
              const SizedBox(height: 24),
            ],
          ),
          if (_busy)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(color: AppColors.emerald),
            ),
        ],
      ),
    );
  }
}