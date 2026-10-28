import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'task_service.dart';
import 'app_theme.dart';
import 'add_contact_screen.dart';
import 'chat_screen.dart';
import 'connection_banner.dart';
import 'database_helper.dart';
import 'group_member_picker.dart';
import 'group_service.dart';
import 'message_sync_service.dart';
import 'session_helper.dart';
import 'settings_screen.dart';
import 'my_tasks_screen.dart';
import 'incoming_message_notifier.dart';
import 'push_service.dart';
import 'status_service.dart'; // NEW: StatusContact
import 'updates_screen.dart'; // NEW: the Updates tab

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

  // NEW: 0 = Chats, 1 = Updates (status)
  int _tab = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  DatabaseReference get _contactsRef =>
      _database.ref('users/${_currentUid ?? ''}/contacts');

  StreamSubscription<DatabaseEvent>? _contactsSubscription;
  DatabaseReference? _syncedRef;
  List<Contact> _contacts = [];
  bool _contactsLoading = true;
  bool _hasRemoteContacts = false;

  // ---------- GROUPS ----------
  // users/<me>/groups lists the group ids; each group is watched separately
  StreamSubscription<DatabaseEvent>? _groupIndexSub;
  final Map<String, StreamSubscription<DatabaseEvent>> _groupSubs = {};
  final Map<String, GroupItem> _groups = {};

  @override
  void initState() {
    super.initState();
    final uid = _currentUid;
    if (uid != null) {
      _syncedRef = _contactsRef;
      _syncedRef!.keepSynced(true);
      _loadLocalContacts();
      _contactsSubscription = _contactsRef.onValue.listen(
        _handleContactsEvent,
        onError: (Object error) {
          debugPrint('[HomeScreen] Firebase contacts error: $error');
          if (mounted && !_hasRemoteContacts) {
            setState(() => _contactsLoading = false);
          }
        },
      );
      _listenGroups(uid);
    } else {
      _contactsLoading = false;
    }
    SessionHelper.saveSession(widget.email);
    IncomingMessageNotifier.start();
    TaskService.startListening();
    MessageSyncService.start(); // watches the internet + sends waiting messages
    loadProfileImage();

    // the app was opened by tapping a message notification: open that chat
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => PushService.openPendingChat(),
    );
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    _groupIndexSub?.cancel();
    for (final s in _groupSubs.values) {
      s.cancel();
    }
    _groupSubs.clear();
    _syncedRef?.keepSynced(false);
    MessageSyncService.stop();
    IncomingMessageNotifier.stop();
    TaskService.stopListening();
    searchController.dispose();
    super.dispose();
  }

  // ---------- GROUP LIST ----------
  void _listenGroups(String uid) {
    _groupIndexSub = _database.ref('users/$uid/groups').onValue.listen(
          (event) {
        if (!mounted) return;

        final ids = <String>{};
        final value = event.snapshot.value;
        if (value is Map) {
          value.forEach((key, v) {
            if (v == true) ids.add(key.toString());
          });
        }

        // stop watching groups I left
        for (final id in _groupSubs.keys.toList()) {
          if (!ids.contains(id)) {
            _groupSubs.remove(id)?.cancel();
            _groups.remove(id);
          }
        }

        // start watching new groups
        for (final id in ids) {
          if (_groupSubs.containsKey(id)) continue;
          _groupSubs[id] = _database.ref('groups/$id').onValue.listen(
                (e) {
              if (!mounted) return;
              final gv = e.snapshot.value;
              setState(() {
                if (gv is Map) {
                  _groups[id] = GroupItem.fromMap(
                    id,
                    Map<dynamic, dynamic>.from(gv),
                  );
                } else {
                  _groups.remove(id);
                }
              });
            },
            onError: (Object err) {
              debugPrint('[HomeScreen] Group $id error: $err');
              if (mounted) setState(() => _groups.remove(id));
            },
          );
        }

        setState(() {});
      },
      onError: (Object e) => debugPrint('[HomeScreen] Group list error: $e'),
    );
  }

  Future<void> _loadLocalContacts() async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      final rows = await DatabaseHelper.getContacts(uid);
      final localContacts = rows.map((row) {
        return Contact.fromMap(row['id'].toString(), {
          'name': row['name'],
          'phone': row['phone'],
          'countryCode': row['country_code'],
          'lastMessage': row['last_message'],
          'time': row['time'],
        });
      }).toList();

      if (!mounted) return;
      setState(() {
        // Use local data immediately; Firebase can refresh it afterward.
        if (!_hasRemoteContacts) _contacts = localContacts;
        _contactsLoading = false;
      });
    } catch (e) {
      debugPrint('[HomeScreen] Failed to load local contacts: $e');
      if (mounted) setState(() => _contactsLoading = false);
    }
  }

  Future<void> _handleContactsEvent(DatabaseEvent event) async {
    final uid = _currentUid;
    if (uid == null) return;

    final remoteContacts = _parseContacts(event.snapshot.value);

    // A null Firebase value can mean the list is empty, but don't wipe a
    // previously cached list because of a transient empty/offline snapshot.
    if (event.snapshot.value == null && _contacts.isNotEmpty) {
      if (mounted) setState(() => _contactsLoading = false);
      return;
    }

    try {
      await DatabaseHelper.saveContacts(
        uid,
        remoteContacts.map((contact) => <String, dynamic>{
          'id': contact.id,
          'name': contact.name,
          'phone': contact.phone,
          'countryCode': contact.countryCode,
          'lastMessage': contact.message,
          'time': contact.time,
        }).toList(),
      );
    } catch (e) {
      debugPrint('[HomeScreen] Failed to cache Firebase contacts: $e');
    }

    if (!mounted) return;
    setState(() {
      _contacts = remoteContacts.isNotEmpty ? remoteContacts : _contacts;
      _hasRemoteContacts = true;
      _contactsLoading = false;
    });
  }

  Future<void> loadProfileImage() async {
    // Settings saves the current user's local image using their Firebase UID.
    final uid = _currentUid;
    if (uid == null) return;

    try {
      final savedPath = await DatabaseHelper.getProfileImageForUid(uid);
      File? file;
      if (savedPath != null && File(savedPath).existsSync()) {
        file = File(savedPath);
      }
      if (!mounted) return;
      setState(() => profileImage = file);
    } catch (e) {
      debugPrint('[HomeScreen] Could not load local profile picture: $e');
    }
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

  // New group: pick members -> type the name -> open the new group chat
  Future<void> openNewGroup() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(builder: (_) => const GroupMemberPickerScreen()),
    );
    if (!mounted || result is! GroupRef) return;

    openGroupChat(result.id, result.name);
  }

  void openGroupChat(String id, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          name: name,
          color: GroupService.colorFor(id),
          chatKey: id,
          isGroup: true,
        ),
      ),
    );
  }

  // the "+" button: New group / New contact (like WhatsApp's "New chat")
  Future<void> _openNewChatSheet() async {
    Widget option(IconData icon, String label, String value, BuildContext c) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.emerald,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => Navigator.pop(c, value),
      );
    }

    final choice = await showModalBottomSheet<String>(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'New chat',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            option(Icons.group_add, 'New group', 'group', sheetContext),
            option(
              Icons.person_add_alt_1,
              'New contact',
              'contact',
              sheetContext,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || choice == null) return;
    if (choice == 'group') {
      openNewGroup();
    } else {
      openAddContact();
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

  // one group row in the list
  Widget _buildGroupTile(GroupItem group) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: GroupService.colorFor(group.id),
        child: const Icon(Icons.group, color: Colors.white, size: 28),
      ),
      title: Text(
        group.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${group.members.length} members',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
      ),
      onTap: () => openGroupChat(group.id, group.name),
    );
  }

  // one contact row in the list
  Widget _buildContactTile(Contact contact) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: StreamBuilder<DatabaseEvent>(
        // This listener receives DP changes from the contact's public profile.
        stream: _database.ref('publicProfiles/${contact.id}/photoBase64').onValue,
        builder: (context, snapshot) {
          final value = snapshot.data?.snapshot.value;
          final encoded = value is String ? value : '';
          final initial =
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';

          MemoryImage? photo;
          if (encoded.isNotEmpty) {
            try {
              photo = MemoryImage(base64Decode(encoded));
            } catch (e) {
              debugPrint('Invalid DP data for ${contact.id}: $e');
            }
          }

          return CircleAvatar(
            radius: 26,
            backgroundColor: contact.color,
            backgroundImage: photo,
            child: photo == null
                ? Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          );
        },
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
        style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
      ),
      trailing: contact.time.isEmpty
          ? null
          : Text(
        contact.time,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
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
  }

  // groups first, then the contacts
  Widget _buildChatList() {
    final query = searchText.toLowerCase();

    final groups = _groups.values
        .where((g) => g.name.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final contacts = _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.phone.contains(query);
    }).toList();

    final total = groups.length + contacts.length;

    if (total == 0) {
      return ValueListenableBuilder<ConnState>(
        valueListenable: MessageSyncService.connection,
        builder: (context, state, _) {
          final message = state == ConnState.offline
              ? 'You are offline. No contacts are saved on this device yet.'
              : 'No chats yet. Tap + to add a contact or create a group.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: total,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 88,
        endIndent: 16,
        color: Color(0xFFE9E4D8),
      ),
      itemBuilder: (context, index) {
        if (index < groups.length) return _buildGroupTile(groups[index]);
        return _buildContactTile(contacts[index - groups.length]);
      },
    );
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
          _tab == 0 ? AppBrand.name : 'Updates', // CHANGED
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
              child: StreamBuilder<DatabaseEvent>(
                // Prefer the shared image; keep the local file as an offline fallback.
                stream: uid == null
                    ? null
                    : _database.ref('publicProfiles/$uid/photoBase64').onValue,
                builder: (context, snapshot) {
                  final value = snapshot.data?.snapshot.value;
                  final encoded = value is String ? value : '';
                  final initial = widget.email.isNotEmpty
                      ? widget.email[0].toUpperCase()
                      : '?';

                  ImageProvider? imageProvider;
                  if (encoded.isNotEmpty) {
                    try {
                      imageProvider = MemoryImage(base64Decode(encoded));
                    } catch (e) {
                      debugPrint('Invalid own DP data: $e');
                    }
                  }
                  imageProvider ??= profileImage != null
                      ? FileImage(profileImage!)
                      : null;

                  return CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.gold,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // CHANGED: only the Chats tab has the "New chat" button
      // (the Updates tab has its own pencil and camera buttons)
      floatingActionButton: _tab != 0
          ? null
          : FloatingActionButton(
        onPressed: _openNewChatSheet,
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        tooltip: 'New chat',
        child: const Icon(Icons.add_comment),
      ),

      // NEW: bottom bar to switch between Chats and Updates
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3F1ED),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppColors.emerald),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_large_outlined),
            selectedIcon: Icon(Icons.donut_large, color: AppColors.emerald),
            label: 'Updates',
          ),
        ],
      ),

      // CHANGED: Updates tab shows the status screen
      body: _tab == 1
          ? UpdatesScreen(
        contacts: _contacts
            .map(
              (c) => StatusContact(
            id: c.id,
            name: c.name,
            color: c.color,
          ),
        )
            .toList(),
      )
          : Column(
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

          // offline / connecting / back online message
          const ConnectionBanner(),

          Expanded(
            child: uid == null
                ? const Center(
              child: Text(
                'Please log in to view your contacts.',
                style: TextStyle(color: AppColors.textSoft, fontSize: 17),
              ),
            )
                : _contactsLoading && _contacts.isEmpty && _groups.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.emerald,
              ),
            )
                : _buildChatList(),
          ),
        ],
      ),
    );
  }
}