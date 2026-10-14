import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'login_screen.dart';

// One row in the settings list
class SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const SettingsItem(this.icon, this.title, this.subtitle);
}

class SettingsScreen extends StatefulWidget {
  final String email;

  const SettingsScreen({super.key, required this.email});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _error = Color(0xFFD94B4B);

  final searchController = TextEditingController();
  String searchText = '';

  // the picture and nickname of this user
  File? profileImage;
  String? nickname;

  final List<SettingsItem> items = const [
    SettingsItem(Icons.vpn_key_outlined, 'Account',
        'Security notifications, account info'),
    SettingsItem(Icons.lock_outline, 'Privacy',
        'Blocked contacts, disappearing messages'),
    SettingsItem(
        Icons.chat_outlined, 'Chats', 'Theme, wallpaper, chat history'),
    SettingsItem(Icons.notifications_none, 'Notifications',
        'Message, group and call tones'),
    SettingsItem(Icons.storage_outlined, 'Storage and data',
        'Network usage, auto-download'),
    SettingsItem(Icons.language, 'App language', 'English'),
    SettingsItem(Icons.help_outline, 'Help and feedback',
        'Help centre, contact us, privacy policy'),
  ];

  @override
  void initState() {
    super.initState();
    loadSavedImage();
    loadNickname();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ---------- READ THE NAME FROM FIREBASE ----------
  Future<void> loadNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? name = user.displayName;
    try {
      final snap = await FirebaseDatabase.instance
          .ref('publicProfiles/${user.uid}/name')
          .get()
          .timeout(const Duration(seconds: 8));
      final value = snap.value;
      if (value is String && value.trim().isNotEmpty) name = value;
    } catch (e) {
      debugPrint('Could not load name: $e');
    }

    if (!mounted) return;
    setState(() => nickname = name);
  }

  // ---------- READ THE SAVED PICTURE ----------
  Future<void> loadSavedImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final savedPath = await DatabaseHelper.getProfileImageForUid(uid);
    if (savedPath == null) return;

    final file = File(savedPath);
    if (!file.existsSync()) return;
    if (!mounted) return;

    setState(() => profileImage = file);
  }

  // ---------- PICK A PICTURE AND SAVE IT ----------
  Future<void> pickImage() async {
    final picker = ImagePicker();

    // open the photo album and wait until the user chooses
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    // the user pressed back without choosing: do nothing
    if (picked == null) return;

    // 1. copy the photo into the app's own drawer
    final folder = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(picked.path).copy('${folder.path}/$fileName');

    // 2. remember the old picture's address, then save the new one
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final oldPath = await DatabaseHelper.getProfileImageForUid(uid);
    await DatabaseHelper.saveProfileImageForUid(uid, savedFile.path);
    debugPrint('Saved picture: ${savedFile.path}');

    // 3. delete the old picture file so the phone does not fill up
    if (oldPath != null) {
      final oldFile = File(oldPath);
      if (oldFile.existsSync()) {
        await oldFile.delete();
      }
    }

    if (!mounted) return;

    // 4. show the new picture
    setState(() => profileImage = savedFile);
  }

  // ---------- LOGOUT ----------
  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColors.textSoft, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSoft, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: _error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // 1. sign out of Firebase
      await FirebaseAuth.instance.signOut();

      // 2. erase the old local "who is logged in" note
      if (!mounted) return;

      // 3. go to the Login page and remove all old pages
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // One white card with rounded corners and a soft shadow
  Widget whiteCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // One settings row: soft green icon box, title, subtitle
  Widget settingsRow(SettingsItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F1ED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: AppColors.emerald, size: 24),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 13.5),
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // the name shown: nickname, or the part of the email before the @
    final emailName = widget.email.split('@')[0];
    final displayName =
    (nickname != null && nickname!.trim().isNotEmpty) ? nickname! : emailName;

    // keep only the rows that match the search text
    final shownItems = items
        .where((i) => i.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---------- GREEN HEADER: back arrow, picture, name, email ----------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emerald, AppColors.emeraldLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // BIG ROUND PICTURE with a white ring and a gold camera button
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.gold,
                          // show the saved picture if there is one
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : null,
                          // otherwise show the first letter of the name
                          child: profileImage == null
                              ? Text(
                            displayName.isEmpty
                                ? '?'
                                : displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.gold,
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // NAME and EMAIL
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ---------- BELOW THE HEADER ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SEARCH BAR
                TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: AppColors.emerald,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search settings',
                    hintStyle: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 16,
                    ),
                    prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSoft),
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE3DED2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE3DED2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppColors.emerald),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // SETTINGS ROWS (inside one white card)
                if (shownItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No settings found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  whiteCard(
                    child: Column(
                      children: [
                        for (int i = 0; i < shownItems.length; i++) ...[
                          settingsRow(shownItems[i]),
                          if (i != shownItems.length - 1)
                            const Divider(
                              height: 1,
                              indent: 76,
                              endIndent: 16,
                              color: Color(0xFFEFEBE0),
                            ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // LOG OUT (always the last card)
                whiteCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEAEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: _error,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Log out',
                      style: TextStyle(
                        color: _error,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: confirmLogout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}