import 'dart:io';

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'chat_screen.dart';
import 'database_helper.dart';
import 'session_helper.dart';
import 'settings_screen.dart';

// One contact = one small card of information
class Contact {
  final String name;
  final String message;
  final String time;
  final Color color;

  const Contact(this.name, this.message, this.time, this.color);
}

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String searchText = '';

  // the picture of the logged-in user (empty until they pick one)
  File? profileImage;

  final List<Contact> contacts = const [
    Contact('Amma', 'Did you eat lunch?', '6:20 pm', Color(0xFFE91E63)),
    Contact('Appa', 'Call me when you are free', '5:50 pm', Color(0xFF3F51B5)),
    Contact('Arjun', 'Bro, the project is done', '4:42 pm', Color(0xFF009688)),
    Contact('Ravi', 'Please send the report', '3:57 pm', Color(0xFFFF9800)),
    Contact('Chaitra', 'Okay, see you tomorrow', '3:51 pm', Color(0xFF9C27B0)),
    Contact('Divya', 'Thanks a lot!', '2:30 pm', Color(0xFF795548)),
    Contact('Kiran', 'Let us play cricket', '1:15 pm', Color(0xFF607D8B)),
    Contact('Meena', 'Happy birthday!', '12:40 pm', Color(0xFFF44336)),
    Contact('Naveen', 'I will send the code', '11:05 am', Color(0xFF4CAF50)),
    Contact('Priya', 'Notes are in the group', '10:22 am', Color(0xFF2196F3)),
    Contact('Rahul', 'Where are you?', 'Yesterday', Color(0xFFFF5722)),
    Contact('Suresh', 'Good morning', 'Yesterday', Color(0xFF00BCD4)),
  ];

  @override
  void initState() {
    super.initState();
    SessionHelper.saveSession(widget.email);
    loadProfileImage();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // read the picture address from SQLite and show it
  Future<void> loadProfileImage() async {
    final savedPath = await DatabaseHelper.getProfileImage(widget.email);

    File? file;
    if (savedPath != null && File(savedPath).existsSync()) {
      file = File(savedPath);
    }

    if (!mounted) return;
    setState(() {
      profileImage = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shownContacts = contacts
        .where((c) => c.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppBrand.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              // wait until the settings page is closed...
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(email: widget.email),
                ),
              );
              // ...then read the picture again, in case it changed
              loadProfileImage();
            },
            // white ring around the picture
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.gold,
                backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? Text(
                  widget.email[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_comment),
      ),
      body: Column(
        children: [
          // GREEN HEADER PART with the search bar (curved at the bottom)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              cursorColor: AppColors.emerald,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle:
                const TextStyle(color: AppColors.textSoft, fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSoft),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // CONTACT LIST
          Expanded(
            child: shownContacts.isEmpty
                ? const Center(
              child: Text(
                'No contacts found',
                style: TextStyle(color: AppColors.textSoft, fontSize: 17),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: shownContacts.length,
              // thin line between rows, starting after the picture
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 88,
                endIndent: 16,
                color: Color(0xFFE9E4D8),
              ),
              itemBuilder: (context, index) {
                final contact = shownContacts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: contact.color,
                    child: Text(
                      contact.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    contact.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Text(
                    contact.time,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          name: contact.name,
                          color: contact.color,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}