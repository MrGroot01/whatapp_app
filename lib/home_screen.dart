import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'task_service.dart';
import 'app_theme.dart';
import 'add_contact_screen.dart';
import 'chat_screen.dart';
import 'database_helper.dart';
import 'session_helper.dart';
import 'settings_screen.dart';
import 'my_tasks_screen.dart';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String message;
  final String time;
  final Color color;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
    this.message = 'Tap to start chatting',
    this.time = '',
    this.color = const Color(0xFF009688),
  });

  factory Contact.fromMap(String id, Map<dynamic, dynamic> map) {
    return Contact(
      id: id,
      name: (map['name'] ?? 'Contact').toString(),
      phone: (map['phone'] ?? '').toString(),
      countryCode: (map['countryCode'] ?? '+91').toString(),
      message: (map['lastMessage'] ?? 'Tap to start chatting').toString(),
      time: (map['time'] ?? '').toString(),
      color: _colorFromId(id),
    );
  }

  static Color _colorFromId(String id) {
    const colors = [
      Color(0xFFE91E63),
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFFF44336),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
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
  File? profileImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  DatabaseReference get _contactsRef =>
      _database.ref('users/${_currentUid ?? ''}/contacts');

  @override
  void initState() {
    super.initState();
    SessionHelper.saveSession(widget.email);
    TaskService.startListening();
    loadProfileImage();
  }

  @override
  void dispose() {
    TaskService.stopListening();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProfileImage() async {
    final savedPath = await DatabaseHelper.getProfileImage(widget.email);
    File? file;

    if (savedPath != null && File(savedPath).existsSync()) {
      file = File(savedPath);
    }

    if (!mounted) return;
    setState(() => profileImage = file);
  }

  Future<void> openAddContact() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddContactScreen()),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved successfully.')),
      );
    }
  }

  List<Contact> _parseContacts(Object? value) {
    if (value is! Map) return [];
    final map = Map<dynamic, dynamic>.from(value);
    final contacts = <Contact>[];

    for (final entry in map.entries) {
      if (entry.value is Map) {
        contacts.add(
          Contact.fromMap(
            entry.key.toString(),
            Map<dynamic, dynamic>.from(entry.value as Map),
          ),
        );
      }
    }

    contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;

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
          IconButton(
            tooltip: 'My Tasks',
            icon: const Icon(Icons.task_alt, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyTasksScreen()),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(email: widget.email),
                ),
              );
              loadProfileImage();
            },
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
                  widget.email.isNotEmpty
                      ? widget.email[0].toUpperCase()
                      : '?',
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
        onPressed: openAddContact,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        tooltip: 'Add contact',
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Column(
        children: [
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
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
              ),
              cursorColor: AppColors.emerald,
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 16,
                ),
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
          Expanded(
            child: uid == null
                ? const Center(
              child: Text(
                'Please log in to view your contacts.',
                style: TextStyle(color: AppColors.textSoft, fontSize: 17),
              ),
            )
                : StreamBuilder<DatabaseEvent>(
              stream: _contactsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Unable to load contacts. Check your Firebase Realtime Database rules.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSoft),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.emerald,
                    ),
                  );
                }

                final contacts =
                _parseContacts(snapshot.data?.snapshot.value)
                    .where((contact) {
                  final query = searchText.toLowerCase();
                  return contact.name.toLowerCase().contains(query) ||
                      contact.phone.contains(query);
                }).toList();

                if (contacts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No contacts yet. Tap + to add a contact.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 17,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: contacts.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 88,
                    endIndent: 16,
                    color: Color(0xFFE9E4D8),
                  ),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: contact.color,
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
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
                        '${contact.countryCode} ${contact.phone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 15,
                        ),
                      ),
                      trailing: contact.time.isEmpty
                          ? null
                          : Text(
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
                            builder: (_) => ChatScreen(
                              name: contact.name,
                              color: contact.color,
                              chatKey: '${_currentUid}_${contact.id}',
                              phone: contact.phone,
                              countryCode: contact.countryCode,
                            ),
                          ),
                        );
                      },
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