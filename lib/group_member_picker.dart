import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'database_helper.dart';
import 'group_service.dart';
import 'new_group_screen.dart';

// "Add group members": search + tick your saved contacts.
//
// addMode = false (New group): the green arrow goes on to the name screen and
//                              this screen gives back a GroupRef.
// addMode = true  (add people to an existing group): the green tick gives back
//                 a List<PickedContact>.
class GroupMemberPickerScreen extends StatefulWidget {
  final bool addMode;
  final Set<String> excludeIds; // people who are already in the group

  const GroupMemberPickerScreen({
    super.key,
    this.addMode = false,
    this.excludeIds = const {},
  });

  @override
  State<GroupMemberPickerScreen> createState() =>
      _GroupMemberPickerScreenState();
}

class _GroupMemberPickerScreenState extends State<GroupMemberPickerScreen> {
  final searchController = TextEditingController();
  List<PickedContact> _all = [];
  final Map<String, PickedContact> _selected = {};
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // the saved contacts are kept on the phone too, so this also works offline
  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final list = <PickedContact>[];

    if (uid.isNotEmpty) {
      try {
        final rows = await DatabaseHelper.getContacts(uid);
        for (final r in rows) {
          final id = r['id'].toString();
          if (id == uid || widget.excludeIds.contains(id)) continue;
          list.add(
            PickedContact(
              id: id,
              name: (r['name'] ?? 'Contact').toString(),
              phone: (r['phone'] ?? '').toString(),
              countryCode: (r['country_code'] ?? '+91').toString(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Could not load contacts for the group: $e');
      }
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  void _toggle(PickedContact c) {
    setState(() {
      if (_selected.containsKey(c.id)) {
        _selected.remove(c.id);
      } else {
        _selected[c.id] = c;
      }
    });
  }

  Future<void> _next() async {
    if (_selected.isEmpty) return;
    final picked = _selected.values.toList();

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
  Widget _selectedRow() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        itemCount: _selected.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final c = _selected.values.elementAt(index);
          return GestureDetector(
            onTap: () => _toggle(c),
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
                            color: Color(0xFF8A9A98),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
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
                      color: AppColors.textDark,
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

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    final q = _query.trim().toLowerCase();
    final shown = _all.where((c) {
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          '${c.countryCode}${c.phone}'.contains(q);
    }).toList();

    if (shown.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _all.isEmpty
                ? 'No contacts to add. Save a contact first.'
                : 'No contact found',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSoft,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // contacts with a letter header (A, B, C ...) like WhatsApp
    final items = <Object>[];
    var lastLetter = '';
    for (final c in shown) {
      final letter = c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
      if (letter != lastLetter) {
        items.add(letter);
        lastLetter = letter;
      }
      items.add(c);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                color: AppColors.textSoft,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        final c = item as PickedContact;
        final isOn = _selected.containsKey(c.id);

        return ListTile(
          leading: _avatar(c),
          title: Text(
            c.name,
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${c.countryCode} ${c.phone}',
            style: GoogleFonts.poppins(
              color: AppColors.textSoft,
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            isOn ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isOn ? AppColors.emerald : AppColors.textSoft,
          ),
          onTap: () => _toggle(c),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.addMode ? 'Add members' : 'Add group members',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_selected.length} of ${_all.length} selected',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xCCFFFFFF),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selected.isEmpty
          ? null
          : FloatingActionButton(
        onPressed: _next,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        child: Icon(widget.addMode ? Icons.check : Icons.arrow_forward),
      ),
      body: Column(
        children: [
          if (_selected.isNotEmpty) _selectedRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: searchController,
              cursorColor: AppColors.emerald,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search name or number',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textSoft,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSoft,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F0E8),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }
}