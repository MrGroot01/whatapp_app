import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'group_service.dart';

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
      setState(() => error = 'Please type a group name');
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
              color: AppColors.textDark,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New group',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Add a name',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xCCFFFFFF),
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
            : const Icon(Icons.check),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F1ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group,
                color: AppColors.emerald,
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
            cursorColor: AppColors.emerald,
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 17,
            ),
            onChanged: (_) {
              if (error != null) setState(() => error = null);
            },
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              hintText: 'Group name (required)',
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textSoft,
                fontSize: 16,
              ),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE3DED2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE3DED2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.emerald,
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
                color: const Color(0xFFFCEAEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error!,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD94B4B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Members: ${widget.members.length}',
            style: GoogleFonts.poppins(
              color: AppColors.textSoft,
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