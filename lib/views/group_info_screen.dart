import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../group_service.dart';
import '../providers/group_info_provider.dart';
import 'chat_media_screen.dart';
import 'group_member_picker.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupInfoProvider(groupId: groupId),
      child: _GroupInfoView(groupId: groupId, groupName: groupName),
    );
  }
}

class _GroupInfoView extends StatefulWidget {
  final String groupId;
  final String groupName;

  const _GroupInfoView({required this.groupId, required this.groupName});

  @override
  State<_GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<_GroupInfoView> {
  @override
  void initState() {
    super.initState();

    // the provider tells the screen when it must close
    final provider = context.read<GroupInfoProvider>();
    provider.onGroupGone = _closeIfNeeded;
    provider.onExited = () {
      if (mounted) Navigator.pop(context);
    };
  }

  // the group was deleted, or I was removed from it
  void _closeIfNeeded() {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pop(context);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              AppStrings.cancel,
              style: GoogleFonts.poppins(color: AppColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              action,
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ADMIN ACTIONS ----------
  // each action: ask the user (dialog / picker), then the provider does it
  Future<void> _rename() async {
    final provider = context.read<GroupInfoProvider>();
    final g = provider.group;
    if (g == null) return;

    final controller = TextEditingController(text: g.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.groupNameTitle,
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
              AppStrings.cancel,
              style: GoogleFonts.poppins(color: AppColors.textSoft),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              AppStrings.save,
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

    final error = await provider.rename(newName);
    if (error != null) _snack(error);
  }

  Future<void> _addMembers() async {
    final provider = context.read<GroupInfoProvider>();
    final g = provider.group;
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

    final error = await provider.addMembers(ids);
    if (error != null) _snack(error);
  }

  Future<void> _removeMember(String uid) async {
    final provider = context.read<GroupInfoProvider>();

    final ok = await _confirm(
      AppStrings.removeMemberTitle(provider.nameOf(uid)),
      AppStrings.removeMemberBody,
      AppStrings.removeAction,
    );
    if (ok != true) return;

    final error = await provider.removeMember(uid);
    if (error != null) _snack(error);
  }

  Future<void> _exitGroup() async {
    final provider = context.read<GroupInfoProvider>();
    if (provider.group == null) return;

    final ok = await _confirm(
      AppStrings.exitGroupTitle,
      AppStrings.exitGroupBody,
      AppStrings.exitAction,
    );
    if (ok != true) return;

    // on success the provider calls onExited and the screen closes
    final error = await provider.exitGroup();
    if (error != null) _snack(error);
  }

  // ---------- DISAPPEARING MESSAGES ----------
  Future<void> _setDisappear(int ms) async {
    final error = await context.read<GroupInfoProvider>().setDisappear(ms);
    if (error != null) _snack(error);
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
                AppStrings.disappearingTitle,
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
                AppStrings.disappearingGroupHelp,
                style: GoogleFonts.poppins(
                  color: AppColors.textSoft,
                  fontSize: 13,
                ),
              ),
            ),
            for (final o in disappearOptions)
              ListTile(
                title: Text(
                  o.label,
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                ),
                trailing: current == o.ms
                    ? const Icon(AppIcons.selected, color: AppColors.emerald)
                    : const Icon(
                  AppIcons.notSelected,
                  color: AppColors.textSoft,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setDisappear(o.ms);
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

  Widget _memberTile(GroupInfoProvider info, GroupItem g, String uid) {
    final isMe = uid == info.me;
    final memberInfo = info.infoOf(uid);
    final name = info.nameOf(uid);

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
        subtitle: isMe || memberInfo == null || memberInfo.phone.isEmpty
            ? null
            : Text(
          memberInfo.phone,
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
                  AppStrings.groupAdminBadge,
                  style: GoogleFonts.poppins(
                    color: AppColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            if (info.isAdmin && !isMe)
              IconButton(
                tooltip: AppStrings.removeFromGroup,
                icon: const Icon(
                  AppIcons.removeMember,
                  color: AppColors.error,
                ),
                onPressed: info.busy ? null : () => _removeMember(uid),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the provider changes (group, names, busy...)
    final info = context.watch<GroupInfoProvider>();

    final g = info.group;
    final name = g?.name ?? widget.groupName;
    final members = info.orderedMembers;
    final busy = info.busy;

    return Scaffold(
      backgroundColor: AppColors.plainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.groupInfo,
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
                        AppIcons.group,
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
                        if (info.isAdmin)
                          IconButton(
                            tooltip: AppStrings.changeGroupName,
                            icon: const Icon(
                              AppIcons.editGroupName,
                              color: AppColors.emerald,
                              size: 20,
                            ),
                            onPressed: busy ? null : _rename,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.groupMembersLine(members.length),
                      style: GoogleFonts.poppins(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _tile(
                icon: AppIcons.media,
                title: AppStrings.mediaLinksDocs,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (info.mediaCount > 0)
                      Text(
                        '${info.mediaCount}',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSoft,
                          fontSize: 14,
                        ),
                      ),
                    const Icon(
                      AppIcons.chevronRight,
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
              ),
              _tile(
                icon: AppIcons.disappearing,
                title: AppStrings.disappearingTitle,
                subtitle: disappearLabel(info.disappearMs),
                onTap: () => _showDisappearSheet(info.disappearMs),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Text(
                  AppStrings.membersCount(members.length),
                  style: GoogleFonts.poppins(
                    color: AppColors.textSoft,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (info.isAdmin)
                Material(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.emerald,
                      child: Icon(AppIcons.addMember, color: Colors.white),
                    ),
                    title: Text(
                      AppStrings.addMembers,
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: busy ? null : _addMembers,
                  ),
                ),
              if (g != null)
                for (final uid in members) _memberTile(info, g, uid),
              const SizedBox(height: 8),
              _tile(
                icon: AppIcons.exitGroup,
                title: AppStrings.exitGroup,
                color: AppColors.error,
                onTap: busy ? () {} : _exitGroup,
              ),
              const SizedBox(height: 24),
            ],
          ),
          if (busy)
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