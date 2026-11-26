import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../services/group_service.dart';

// Step 2 of "New group": type the group name and create it.
// Gives back a GroupRef when the group was created.
class NewGroupScreen extends StatefulWidget {
  final List<PickedContact> members;

  const NewGroupScreen({super.key, required this.members});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final nameController = TextEditingController();
  bool creating = false;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (creating) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      setState(() => error = context.l10n.groupNameRequired);
      return;
    }

    setState(() {
      creating = true;
      error = null;
    });

    try {
      final ref = await GroupService.createGroup(
        name: name,
        memberIds: widget.members.map((m) => m.id).toList(),
      );
      if (!mounted) return;
      Navigator.pop(context, ref);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        creating = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _memberChip(PickedContact c) {
    final p = context.palette;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: GroupService.colorFor(c.id),
            child: Text(
              c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: p.textDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.newGroup,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l.addAName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.onEmeraldSoft,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: creating ? null : _create,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        child: creating
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(AppIcons.confirm),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: p.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.group,
                color: p.accent,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            autofocus: true,
            maxLength: 40,
            enabled: !creating,
            textCapitalization: TextCapitalization.words,
            cursorColor: p.accent,
            style: GoogleFonts.poppins(
              color: p.textDark,
              fontSize: 17,
            ),
            onChanged: (_) {
              if (error != null) setState(() => error = null);
            },
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              hintText: l.groupNameHint,
              hintStyle: GoogleFonts.poppins(
                color: p.textSoft,
                fontSize: 16,
              ),
              filled: true,
              fillColor: p.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: p.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: p.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.errorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error!,
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            l.membersTitle(widget.members.length),
            style: GoogleFonts.poppins(
              color: p.textSoft,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 14,
            children: widget.members.map(_memberChip).toList(),
          ),
        ],
      ),
    );
  }
}