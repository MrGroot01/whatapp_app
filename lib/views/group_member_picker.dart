import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../services/group_service.dart';
import '../providers/member_picker_provider.dart';
import 'new_group_screen.dart';

class GroupMemberPickerScreen extends StatelessWidget {
  final bool addMode;
  final Set<String> excludeIds; // people who are already in the group

  const GroupMemberPickerScreen({
    super.key,
    this.addMode = false,
    this.excludeIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberPickerProvider(excludeIds: excludeIds),
      child: _PickerView(addMode: addMode),
    );
  }
}

class _PickerView extends StatefulWidget {
  final bool addMode;

  const _PickerView({required this.addMode});

  @override
  State<_PickerView> createState() => _PickerViewState();
}

class _PickerViewState extends State<_PickerView> {
  // only the search box lives here (pure UI state)
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final picked = context.read<MemberPickerProvider>().selected;
    if (picked.isEmpty) return;

    if (widget.addMode) {
      Navigator.pop(context, picked);
      return;
    }

    final created = await Navigator.push<GroupRef>(
      context,
      MaterialPageRoute(builder: (_) => NewGroupScreen(members: picked)),
    );
    if (created != null && mounted) Navigator.pop(context, created);
  }

  Widget _avatar(PickedContact c, {double radius = 22}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: GroupService.colorFor(c.id),
      child: Text(
        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }

  // the people you ticked, shown above the list
  Widget _selectedRow(MemberPickerProvider picker) {
    final p = context.palette;
    final selected = picker.selected;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        itemCount: selected.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final c = selected[index];
          return GestureDetector(
            onTap: () => picker.toggle(c),
            child: SizedBox(
              width: 56,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _avatar(c, radius: 24),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.removeBadge,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AppIcons.close,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: p.textDark,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(MemberPickerProvider picker) {
    final p = context.palette;

    if (picker.loading) {
      return Center(
        child: CircularProgressIndicator(color: p.accent),
      );
    }

    final items = picker.items;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            picker.allCount == 0
                ? AppStrings.noContactsToAdd
                : AppStrings.noContactFound,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: p.textSoft,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // a letter header
        if (item is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                color: p.textSoft,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final c = item as PickedContact;
        final isOn = picker.isSelected(c.id);

        return ListTile(
          leading: _avatar(c),
          title: Text(
            c.name,
            style: GoogleFonts.poppins(
              color: p.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${c.countryCode} ${c.phone}',
            style: GoogleFonts.poppins(
              color: p.textSoft,
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            isOn ? AppIcons.pickerOn : AppIcons.pickerOff,
            color: isOn ? p.accent : p.textSoft,
          ),
          onTap: () => picker.toggle(c),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // rebuilds whenever the provider changes (loaded, ticked, search...)
    final picker = context.watch<MemberPickerProvider>();
    final selectedCount = picker.selectedCount;

    return Scaffold(
      backgroundColor: p.card,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.addMode
                  ? AppStrings.addMembers
                  : AppStrings.addGroupMembers,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AppStrings.selectedOf(selectedCount, picker.allCount),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.onEmeraldSoft,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedCount == 0
          ? null
          : FloatingActionButton(
        onPressed: _next,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        child: Icon(widget.addMode ? AppIcons.confirm : AppIcons.next),
      ),
      body: Column(
        children: [
          if (selectedCount > 0) _selectedRow(picker),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: searchController,
              cursorColor: p.accent,
              onChanged: picker.setQuery,
              style: GoogleFonts.poppins(
                color: p.textDark,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchNameOrNumber,
                hintStyle: GoogleFonts.poppins(
                  color: p.textSoft,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  AppIcons.search,
                  color: p.textSoft,
                ),
                filled: true,
                fillColor: p.searchFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildList(picker)),
        ],
      ),
    );
  }
}