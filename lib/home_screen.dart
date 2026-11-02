import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_service.dart';
import 'app_theme.dart';
import 'add_contact_screen.dart';
import 'chat_screen.dart';
import 'connection_banner.dart';
import 'database_helper.dart';
import 'group_member_picker.dart';
import 'group_service.dart';
import 'message_sync_service.dart';
import 'search_provider.dart';
import 'session_helper.dart';
import 'settings_screen.dart';
import 'my_tasks_screen.dart';
import 'incoming_message_notifier.dart';
import 'push_service.dart';
import 'status_service.dart'; // StatusContact
import 'updates_screen.dart'; // the Updates tab

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

// the newest message of one chat, shown under the name in the chat list
class _LastMessage {
  final String preview; // short text for any kind of message
  final String type;
  final String senderId;
  final int timeMs;
  final int status; // 0 = sent, 1 = delivered, 2 = read
  final int expireAtMs;

  const _LastMessage({
    required this.preview,
    required this.type,
    required this.senderId,
    required this.timeMs,
    required this.status,
    required this.expireAtMs,
  });

  factory _LastMessage.fromMap(Map<dynamic, dynamic> d) {
    final type = (d['type'] ?? 'text').toString();

    String preview;
    switch (type) {
      case 'image':
        final caption = (d['text'] ?? '').toString().trim();
        preview = caption.isEmpty ? '📷 Photo' : '📷 $caption';
        break;
      case 'file':
        final name = (d['fileName'] ?? d['text'] ?? '').toString();
        preview = '📄 ${name.isEmpty ? 'Document' : name}';
        break;
      case 'contact':
        preview = '👤 ${(d['contactName'] ?? 'Contact').toString()}';
        break;
      default:
        preview = (d['text'] ?? '').toString().replaceAll('\n', ' ');
    }

    final ts = d['timeMs'];
    final st = d['status'];
    final ex = d['expireAtMs'];

    return _LastMessage(
      preview: preview,
      type: type,
      senderId: (d['senderId'] ?? '').toString(),
      // a message that is still being saved has no server time yet
      timeMs: ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
      status: st is num ? st.toInt() : 0,
      expireAtMs: ex is num ? ex.toInt() : 0,
    );
  }
}

// one row of the chat list: a group or a contact
class _ChatRow {
  final GroupItem? group;
  final Contact? contact;
  final int timeMs; // time of the newest message (0 = no messages yet)

  const _ChatRow({this.group, this.contact, required this.timeMs});

  String get name => group?.name ?? contact?.name ?? '';
}

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
  File? profileImage;

  // 0 = Chats, 1 = Updates (status)
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

  // ---------- LAST MESSAGES ----------
  // chat id -> the newest message of that chat (one listener per chat)
  final Map<String, StreamSubscription<DatabaseEvent>> _lastSubs = {};
  final Map<String, _LastMessage> _last = {};
  Timer? _clockTimer;

  // ---------- DELETE CHATS (long-press) ----------
  // chats selected by long-press; delete mode is on while this is not empty
  final Set<String> _selected = {};
  // chat id -> time (ms) when I deleted it; older messages stay hidden
  final Map<String, int> _clearedAt = {};
  StreamSubscription<DatabaseEvent>? _clearedSub;

  @override
  void initState() {
    super.initState();
    context.read<SearchProvider>().reset(); // start with search closed

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
      _listenCleared(uid);
    } else {
      _contactsLoading = false;
    }
    SessionHelper.saveSession(widget.email);
    IncomingMessageNotifier.start();
    TaskService.startListening();
    MessageSyncService.start(); // watches the internet + sends waiting messages
    loadProfileImage();

    // refresh the times ("Today" / "Yesterday") and expired messages
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    // the app was opened by tapping a message notification: open that chat
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => PushService.openPendingChat(),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _clearedSub?.cancel();
    _contactsSubscription?.cancel();
    _groupIndexSub?.cancel();
    for (final s in _groupSubs.values) {
      s.cancel();
    }
    _groupSubs.clear();
    for (final s in _lastSubs.values) {
      s.cancel();
    }
    _lastSubs.clear();
    _syncedRef?.keepSynced(false);
    MessageSyncService.stop();
    IncomingMessageNotifier.stop();
    TaskService.stopListening();
    searchController.dispose();
    super.dispose();
  }

  // ---------- LAST MESSAGE OF EACH CHAT ----------
  // the chat board between me and a contact
  String _chatIdWith(String contactId) {
    final me = _currentUid ?? '';
    return ([me, contactId]..sort()).join('_');
  }

  void _watchLastMessage(String chatId) {
    if (chatId.isEmpty || _lastSubs.containsKey(chatId)) return;

    _lastSubs[chatId] = _database
        .ref('chats/$chatId/messages')
        .limitToLast(1)
        .onValue
        .listen(
          (event) {
        if (!mounted) return;

        _LastMessage? newest;
        final v = event.snapshot.value;
        if (v is Map) {
          for (final entry in v.entries) {
            final d = entry.value;
            if (d is Map) {
              newest = _LastMessage.fromMap(Map<dynamic, dynamic>.from(d));
            }
          }
        }

        setState(() {
          if (newest == null) {
            _last.remove(chatId);
          } else {
            _last[chatId] = newest;
          }
        });
      },
      onError: (Object e) {
        // for example: no permission for this chat
        debugPrint('[HomeScreen] Last message error ($chatId): $e');
      },
    );
  }

  // the newest message, unless it has already disappeared
  // or I deleted the chat after it was sent
  _LastMessage? _visibleLast(String chatId) {
    final m = _last[chatId];
    if (m == null) return null;
    if (m.expireAtMs > 0 && m.expireAtMs <= MessageSyncService.nowMs()) {
      return null;
    }
    final clearedAt = _clearedAt[chatId];
    if (clearedAt != null && m.timeMs <= clearedAt) return null;
    return m;
  }

  // true = I deleted this chat and nothing new has arrived since
  bool _isHidden(String chatId) {
    return _clearedAt.containsKey(chatId) && _visibleLast(chatId) == null;
  }

  // 4:20 pm  /  Yesterday  /  12/10/2026
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

  // the line under the name: ticks + the last message
  Widget _buildLastLine(
      String chatId,
      String fallback, {
        bool isGroup = false,
      }) {
    const baseStyle = TextStyle(color: AppColors.textSoft, fontSize: 15);

    final last = _visibleLast(chatId);
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

    // my own messages get the tick, like in the chat
    Widget? tick;
    if (mine && !isCall) {
      // groups have no read ticks: one grey tick only
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
    final last = _visibleLast(chatId);
    final text = last != null ? _formatListTime(last.timeMs) : fallback;
    if (text.isEmpty) return null;
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
    );
  }

  // ---------- DELETE CHATS ----------
  // long-press / tap in delete mode: select or unselect one chat
  void _toggleSelect(String chatId) {
    setState(() {
      if (!_selected.remove(chatId)) _selected.add(chatId);
    });
  }

  void _clearSelection() => setState(() => _selected.clear());

  // reads the "I deleted this chat at ..." notes from Firebase
  void _listenCleared(String uid) {
    _clearedSub = _database.ref('users/$uid/clearedChats').onValue.listen(
          (event) {
        if (!mounted) return;
        final map = <String, int>{};
        final v = event.snapshot.value;
        if (v is Map) {
          v.forEach((key, t) {
            if (t is num) map[key.toString()] = t.toInt();
          });
        }
        setState(() {
          _clearedAt
            ..clear()
            ..addAll(map);
        });
      },
      onError: (Object e) => debugPrint('[HomeScreen] Cleared chats error: $e'),
    );
  }

  // delete the selected chats for me only (the other people keep theirs)
  Future<void> _deleteSelected() async {
    final me = _currentUid;
    if (me == null || _selected.isEmpty) return;

    final count = _selected.length;
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
      // one note per chat: "I deleted this chat at <server time>"
      final updates = <String, Object?>{
        for (final id in _selected)
          'users/$me/clearedChats/$id': ServerValue.timestamp,
      };
      await _database.ref().update(updates).timeout(
        const Duration(seconds: 15),
      );

      if (!mounted) return;
      _clearSelection();
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
            _lastSubs.remove(id)?.cancel();
            _last.remove(id);
            _selected.remove(id);
          }
        }

        // start watching new groups
        for (final id in ids) {
          if (_groupSubs.containsKey(id)) continue;
          _watchLastMessage(id); // the group chat id is the group id
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

      // show the last messages while the contacts are loaded from the phone
      for (final c in localContacts) {
        _watchLastMessage(_chatIdWith(c.id));
      }
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
        remoteContacts
            .map((contact) => <String, dynamic>{
          'id': contact.id,
          'name': contact.name,
          'phone': contact.phone,
          'countryCode': contact.countryCode,
          'lastMessage': contact.message,
          'time': contact.time,
        })
            .toList(),
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

    // one last-message listener for every contact (also for new contacts)
    for (final c in remoteContacts) {
      _watchLastMessage(_chatIdWith(c.id));
    }
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

    contacts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return contacts;
  }

  // one group row in the list
  Widget _buildGroupTile(GroupItem group) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: _selected.contains(group.id) ? _selectedTile : null,
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
      onLongPress: () => _toggleSelect(group.id),
      onTap: _selected.isNotEmpty
          ? () => _toggleSelect(group.id)
          : () => openGroupChat(group.id, group.name),
    );
  }

  // one contact row in the list
  Widget _buildContactTile(Contact contact) {
    final chatId = _chatIdWith(contact.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: _selected.contains(chatId) ? _selectedTile : null,
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
      onLongPress: () => _toggleSelect(chatId),
      onTap: () {
        // in delete mode a tap selects / unselects the chat
        if (_selected.isNotEmpty) {
          _toggleSelect(chatId);
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

  // groups and contacts together, the newest message on top
  Widget _buildChatList(String searchText) {
    final query = searchText.toLowerCase();
    final searching = query.isNotEmpty;

    final rows = <_ChatRow>[];

    for (final g in _groups.values) {
      if (!g.name.toLowerCase().contains(query)) continue;
      // a deleted chat stays hidden, but search can still find it
      if (!searching && _isHidden(g.id)) continue;
      rows.add(_ChatRow(group: g, timeMs: _visibleLast(g.id)?.timeMs ?? 0));
    }

    for (final c in _contacts) {
      // search still finds a contact by name or phone number
      final matches =
          c.name.toLowerCase().contains(query) || c.phone.contains(query);
      if (!matches) continue;
      final chatId = _chatIdWith(c.id);
      if (!searching && _isHidden(chatId)) continue;
      rows.add(_ChatRow(contact: c, timeMs: _visibleLast(chatId)?.timeMs ?? 0));
    }

    rows.sort((a, b) {
      if (a.timeMs != b.timeMs) return b.timeMs.compareTo(a.timeMs);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

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
        final row = rows[index];
        if (row.group != null) return _buildGroupTile(row.group!);
        return _buildContactTile(row.contact!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;
    final selecting = _selected.isNotEmpty;

    return PopScope(
      // the phone's back button leaves delete mode first
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selecting) _clearSelection();
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
            onPressed: _clearSelection,
          )
              : null,
          title: selecting
              ? Text(
            '${_selected.length}',
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
            // search icon (only on the Chats tab)
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
                      : _database
                      .ref('publicProfiles/$uid/photoBase64')
                      .onValue,
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
          onDestinationSelected: (i) => setState(() {
            _tab = i;
            _selected.clear(); // leaving the tab leaves delete mode
          }),
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
            // search bar shows/hides from SearchProvider
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
                  : _contactsLoading &&
                  _contacts.isEmpty &&
                  _groups.isEmpty
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