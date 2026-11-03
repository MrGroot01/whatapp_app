import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_service.dart';
import 'app_theme.dart';
import 'add_contact_screen.dart';
import 'chat_screen.dart';
import 'connection_banner.dart';
import 'group_member_picker.dart';
import 'group_service.dart';
import 'message_sync_service.dart';
import 'models/chat_row.dart';
import 'models/contact.dart';
import 'providers/chat_list_provider.dart';
import 'providers/chat_selection_provider.dart';
import 'providers/contacts_provider.dart';
import 'providers/groups_provider.dart';
import 'providers/profile_provider.dart';
import 'search_provider.dart';
import 'session_helper.dart';
import 'settings_screen.dart';
import 'my_tasks_screen.dart';
import 'incoming_message_notifier.dart';
import 'push_service.dart';
import 'status_service.dart'; // StatusContact
import 'updates_screen.dart'; // the Updates tab

// Contact moved to models/contact.dart. This line keeps every file that
// still imports it from home_screen.dart working.
export 'models/contact.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _tickRead = Color(0xFF34A7E0);
  static const Color _tickGrey = Color(0xFF8A9A98);
  static const Color _missedRed = Color(0xFFD94B4B);
  static const Color _selectedTile = Color(0xFFD9F2E7);

  final searchController = TextEditingController();

  // 0 = Chats, 1 = Updates (status)
  int _tab = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  final ChatSelectionProvider _selection = ChatSelectionProvider();
  final ContactsProvider _contactsProvider = ContactsProvider();
  final GroupsProvider _groupsProvider = GroupsProvider();
  final ChatListProvider _chatList = ChatListProvider();
  final ProfileProvider _profile = ProfileProvider();

  @override
  void initState() {
    super.initState();
    context.read<SearchProvider>().reset(); // start with search closed

    _chatList.start();
    _profile.start();

    _contactsProvider.addListener(_watchContactChats);
    _contactsProvider.start();

    _groupsProvider.onGroupAdded = _chatList.watchChat;
    _groupsProvider.onGroupRemoved = (groupId) {
      _chatList.forgetChat(groupId);
      _selection.remove(groupId);
    };
    _groupsProvider.start();

    SessionHelper.saveSession(widget.email);
    IncomingMessageNotifier.start();
    TaskService.startListening();
    MessageSyncService.start(); // watches the internet + sends waiting messages

    WidgetsBinding.instance.addPostFrameCallback(
          (_) => PushService.openPendingChat(),
    );
  }

  @override
  void dispose() {
    MessageSyncService.stop();
    IncomingMessageNotifier.stop();
    TaskService.stopListening();
    searchController.dispose();
    _contactsProvider.removeListener(_watchContactChats);
    _groupsProvider.dispose(); // also stops every group listener
    _contactsProvider.dispose(); // also stops the Firebase listener
    _selection.dispose();
    _chatList.dispose(); // also stops every last-message listener
    _profile.dispose(); // also stops the profile photo listener
    super.dispose();
  }

  void _watchContactChats() {
    for (final c in _contactsProvider.contacts) {
      _chatList.watchChat(_chatList.chatIdWith(c.id));
    }
  }

  String _formatListTime(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;

    if (diff <= 0) {
      final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${t.hour >= 12 ? 'pm' : 'am'}';
    }
    if (diff == 1) return 'Yesterday';
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _buildLastLine(
      String chatId,
      String fallback, {
        bool isGroup = false,
      }) {
    const baseStyle = TextStyle(color: AppColors.textSoft, fontSize: 15);

    final last = _chatList.visibleLast(chatId);
    if (last == null || (last.preview.isEmpty && last.type != 'call')) {
      return Text(
        fallback,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final mine = last.senderId == _currentUid;
    final isCall = last.type == 'call';

    Widget? tick;
    if (mine && !isCall) {
      final status = isGroup && last.status > 0 ? 0 : last.status;
      tick = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          status == 0 ? Icons.done : Icons.done_all,
          size: 17,
          color: status >= 2 ? _tickRead : _tickGrey,
        ),
      );
    }

    String text = last.preview;
    if (isCall) {
      text = mine ? 'Video call · no answer' : 'Missed video call';
    } else if (isGroup && mine) {
      text = 'You: $text';
    }

    return Row(
      children: [
        if (isCall)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              mine ? Icons.videocam : Icons.videocam_off,
              size: 16,
              color: mine ? AppColors.textSoft : _missedRed,
            ),
          ),
        if (tick != null) tick,
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: baseStyle.copyWith(
              color: isCall && !mine ? _missedRed : AppColors.textSoft,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildTimeText(String chatId, {String fallback = ''}) {
    final last = _chatList.visibleLast(chatId);
    final text = last != null ? _formatListTime(last.timeMs) : fallback;
    if (text.isEmpty) return null;
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
    );
  }

  Future<void> _deleteSelected() async {
    final ids = _selection.selectedIds; // a copy of the selected chat ids
    if (_currentUid == null || ids.isEmpty) return;

    final count = ids.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          count == 1 ? 'Delete chat?' : 'Delete $count chats?',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'The chat is removed from your list only. '
              'The other people keep their messages. '
              'A new message brings the chat back.',
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
              'Delete',
              style: TextStyle(
                color: _missedRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      await _chatList.deleteChatsForMe(ids);

      if (!mounted) return;
      _selection.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count == 1 ? 'Chat deleted' : '$count chats deleted'),
        ),
      );
    } catch (e) {
      debugPrint('[HomeScreen] Delete chats failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete. Check your internet and try again.'),
        ),
      );
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

  // one group row in the list
  Widget _buildGroupTile(GroupItem group) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: _selection.isSelected(group.id) ? _selectedTile : null,
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
      // the last message (or the member count when there is none)
      subtitle: _buildLastLine(
        group.id,
        '${group.members.length} members',
        isGroup: true,
      ),
      trailing: _buildTimeText(group.id),
      onLongPress: () => _selection.toggle(group.id),
      onTap: _selection.isSelecting
          ? () => _selection.toggle(group.id)
          : () => openGroupChat(group.id, group.name),
    );
  }

  // one contact row in the list
  Widget _buildContactTile(Contact contact) {
    final chatId = _chatList.chatIdWith(contact.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: _selection.isSelected(chatId) ? _selectedTile : null,
      leading: StreamBuilder<DatabaseEvent>(
        // This listener receives DP changes from the contact's public profile.
        stream:
        _database.ref('publicProfiles/${contact.id}/photoBase64').onValue,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      // the last message (the phone number is no longer shown here)
      subtitle: _buildLastLine(chatId, 'Tap to start chatting'),
      trailing: _buildTimeText(chatId, fallback: contact.time),
      onLongPress: () => _selection.toggle(chatId),
      onTap: () {
        // in delete mode a tap selects / unselects the chat
        if (_selection.isSelecting) {
          _selection.toggle(chatId);
          return;
        }
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

  Widget _buildChatList(String searchText) {
    // the provider decides which rows to show and in which order
    final rows = _chatList.buildRows(
      contacts: _contactsProvider.contacts,
      groups: _groupsProvider.groups,
      query: searchText,
    );

    if (rows.isEmpty) {
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
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 88,
        endIndent: 16,
        color: Color(0xFFE9E4D8),
      ),
      itemBuilder: (context, index) {
        final ChatRow row = rows[index];
        if (row.group != null) return _buildGroupTile(row.group!);
        return _buildContactTile(row.contact!);
      },
    );
  }

  // the round picture in the top right corner (opens Settings)
  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(email: widget.email),
          ),
        );
        // Settings may have saved a new picture
        _profile.reload();
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        // only this small avatar rebuilds when the picture changes
        child: Consumer<ProfileProvider>(
          builder: (_, profile, _) {
            final initial =
            widget.email.isNotEmpty ? widget.email[0].toUpperCase() : '?';
            final image = profile.avatar;

            return CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.gold,
              backgroundImage: image,
              child: image == null
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatSelectionProvider>.value(value: _selection),
        ChangeNotifierProvider<ContactsProvider>.value(
          value: _contactsProvider,
        ),
        ChangeNotifierProvider<GroupsProvider>.value(value: _groupsProvider),
        ChangeNotifierProvider<ChatListProvider>.value(value: _chatList),
        ChangeNotifierProvider<ProfileProvider>.value(value: _profile),
      ],
      child: Consumer4<ChatSelectionProvider, ContactsProvider,
          GroupsProvider, ChatListProvider>(
        builder: (
            context,
            selection,
            contactsState,
            groupsState,
            chatListState,
            _,
            ) =>
            _buildScaffold(selection, contactsState, groupsState),
      ),
    );
  }

  Widget _buildScaffold(
      ChatSelectionProvider selection,
      ContactsProvider contactsState,
      GroupsProvider groupsState,
      ) {
    final uid = _currentUid;
    final selecting = selection.isSelecting;
    final contacts = contactsState.contacts;

    return PopScope(
      // the phone's back button leaves delete mode first
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selecting) _selection.clear();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: selecting
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _selection.clear,
          )
              : null,
          title: selecting
              ? Text(
            '${selection.count}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          )
              : Text(
            _tab == 0 ? AppBrand.name : 'Updates',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          actions: selecting
              ? [
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _deleteSelected,
            ),
            const SizedBox(width: 8),
          ]
              : [
            if (_tab == 0)
              Consumer<SearchProvider>(
                builder: (_, search, _) => IconButton(
                  tooltip: search.isSearching ? 'Close search' : 'Search',
                  icon: Icon(
                    search.isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    searchController.clear();
                    context.read<SearchProvider>().toggle();
                  },
                ),
              ),

            IconButton(
              tooltip: 'My Tasks',
              icon: const Icon(Icons.task_alt, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyTasksScreen()),
              ),
            ),

            _buildProfileButton(),
            const SizedBox(width: 16),
          ],
        ),

        // only the Chats tab has the "New chat" button
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

        // bottom bar to switch between Chats and Updates
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE3F1ED),
          selectedIndex: _tab,
          onDestinationSelected: (i) {
            _selection.clear(); // leaving the tab leaves delete mode
            setState(() => _tab = i);
          },
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

        // Updates tab shows the status screen
        body: _tab == 1
            ? UpdatesScreen(
          contacts: contacts
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
            Consumer<SearchProvider>(
              builder: (_, search, _) {
                if (!search.isSearching) return const SizedBox.shrink();
                return Container(
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
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    cursorColor: AppColors.emerald,
                    onChanged: (value) =>
                        context.read<SearchProvider>().setQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSoft,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              },
            ),

            // offline / connecting / back online message
            const ConnectionBanner(),

            Expanded(
              child: uid == null
                  ? const Center(
                child: Text(
                  'Please log in to view your contacts.',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 17,
                  ),
                ),
              )
                  : contactsState.isLoading &&
                  contacts.isEmpty &&
                  groupsState.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.emerald,
                ),
              )
                  : Consumer<SearchProvider>(
                builder: (_, search, _) =>
                    _buildChatList(search.query),
              ),
            ),
          ],
        ),
      ),
    );
  }
}