import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// One message = text + who sent it + time + tick status
class Message {
  final String id; // the Firebase key of this message
  final String text;
  final bool isMe;
  final DateTime time;
  final int status; // 0 = sent, 2 = read

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = 0,
  });

  factory Message.fromMap(String id, Map<dynamic, dynamic> data, String myUid) {
    final ts = data['timeMs'];
    final st = data['status'];
    return Message(
      id: id,
      text: (data['text'] ?? '').toString(),
      isMe: data['senderId'] == myUid,
      time: DateTime.fromMillisecondsSinceEpoch(
        ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
      ),
      status: st is num ? st.toInt() : 0,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final Color color;
  final String chatKey; // unique per account + contact

  const ChatScreen({
    super.key,
    required this.name,
    required this.color,
    required this.chatKey,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _wallpaper = Color(0xFFEFEAE0);
  static const Color _mine = Color(0xFFD9F2E7);
  static const Color _theirs = Colors.white;
  static const Color _tickRead = Color(0xFF34A7E0);
  static const Color _tickGrey = Color(0xFF8A9A98);
  static const Color _error = Color(0xFFD94B4B);

  static const List<String> _emojis = [
    '😀', '😁', '😂', '🤣', '😊', '😍', '😘', '😎',
    '🤔', '😅', '😢', '😭', '😡', '🥳', '😴', '🤗',
    '👍', '👎', '👏', '🙏', '💪', '🙌', '👋', '🤝',
    '❤️', '💔', '🔥', '✨', '🎉', '🎂', '🌹', '⭐',
    '🍕', '🍔', '☕', '🍎', '⚽', '🏏', '🎵', '📚',
    '💻', '📱', '🚗', '🏠', '🌞', '🌙', '🌧️', '✅',
  ];

  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  // the "notice board" for this chat in Firebase
  // both people use the SAME board: the two account ids, sorted, joined by "_"
  late final String _chatId = _makeChatId();

  String _makeChatId() {
    final parts = widget.chatKey.split('_');
    if (parts.length != 2) return widget.chatKey;
    parts.sort();
    return parts.join('_');
  }

  late final DatabaseReference _messagesRef =
  FirebaseDatabase.instance.ref('chats/$_chatId/messages');
  StreamSubscription<DatabaseEvent>? _subscription;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Message> messages = [];
  bool loading = true;
  bool loadError = false;
  bool hasText = false;
  bool showEmoji = false;
  bool showScrollDown = false;

  @override
  void initState() {
    super.initState();

    // LIVE: this runs every time anything in the chat changes in Firebase
    _subscription = _messagesRef.onValue.listen(
      _onMessagesChanged,
      onError: (_) {
        if (!mounted) return;
        setState(() {
          loading = false;
          loadError = true;
        });
      },
    );

    scrollController.addListener(() {
      // list is reversed, so offset 0 = bottom
      final away = scrollController.offset > 300;
      if (away != showScrollDown) setState(() => showScrollDown = away);
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus && showEmoji) {
        setState(() => showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // ---------- LIVE MESSAGES ----------
  void _onMessagesChanged(DatabaseEvent event) {
    final value = event.snapshot.value;
    final list = <Message>[];

    if (value is Map) {
      value.forEach((key, data) {
        if (data is Map) {
          list.add(Message.fromMap(key.toString(), data, _myUid));
        }
      });
    }

    // oldest first
    list.sort((a, b) => a.time.compareTo(b.time));

    if (!mounted) return;
    setState(() {
      messages = list;
      loading = false;
      loadError = false;
    });

    _markIncomingAsRead(list);
  }

  // messages from the other person become "read" when this chat is open
  void _markIncomingAsRead(List<Message> list) {
    for (final m in list) {
      if (!m.isMe && m.status != 2) {
        _messagesRef.child(m.id).update({'status': 2});
      }
    }
  }

  // ---------- SENDING ----------
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    messageController.clear();
    setState(() => hasText = false);
    scrollToBottom();

    try {
      // push() makes a new unique key, set() writes the message there
      await _messagesRef.push().set({
        'text': text,
        'senderId': _myUid,
        'timeMs': ServerValue.timestamp,
        'status': 0,
      });
    } catch (e) {
      snack('Could not send. Check your internet and database rules.');
    }
  }

  // ---------- ACTIONS ----------
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void closePanels() {
    FocusScope.of(context).unfocus();
    if (showEmoji) setState(() => showEmoji = false);
  }

  void toggleEmoji() {
    if (showEmoji) {
      setState(() => showEmoji = false);
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
      setState(() => showEmoji = true);
    }
  }

  void insertEmoji(String emoji) {
    final text = messageController.text;
    final sel = messageController.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    final newText = text.replaceRange(start, end, emoji);

    messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() => hasText = newText.trim().isNotEmpty);
  }

  void snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> deleteMessage(Message msg) async {
    try {
      await _messagesRef.child(msg.id).remove();
      snack('Message deleted');
    } catch (e) {
      snack('Could not delete the message');
    }
  }

  Future<void> clearChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear chat?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'All messages with ${widget.name} will be deleted.',
          style: const TextStyle(color: AppColors.textSoft, fontSize: 16),
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
              'Clear',
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

    if (ok == true) {
      try {
        await _messagesRef.remove();
      } catch (e) {
        snack('Could not clear the chat');
      }
    }
  }

  void showMessageOptions(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.emerald),
              title: const Text(
                'Copy',
                style: TextStyle(color: AppColors.textDark, fontSize: 17),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                Navigator.pop(sheetContext);
                snack('Copied');
              },
            ),
            // only your own messages can be deleted
            if (msg.isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: _error),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: _error, fontSize: 17),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  deleteMessage(msg);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void showAttachMenu() {
    closePanels();

    Widget item(IconData icon, String label, Color color) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          snack('$label sharing is coming soon');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSoft, fontSize: 14),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              item(Icons.insert_drive_file, 'Document', const Color(0xFF5F66CD)),
              item(Icons.camera_alt, 'Camera', const Color(0xFFD3396D)),
              item(Icons.photo, 'Gallery', const Color(0xFFAC44CF)),
              item(Icons.location_on, 'Location', const Color(0xFF1FA855)),
            ],
          ),
        ),
      ),
    );
  }

  void showCallDialog(bool video) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 40,
              backgroundColor: widget.color,
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.name,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              video ? 'Video calling...' : 'Calling...',
              style: const TextStyle(color: AppColors.textSoft, fontSize: 16),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE53935),
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------
  String formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${t.hour >= 12 ? 'pm' : 'am'}';
  }

  String dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final that = DateTime.utc(day.year, day.month, day.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }

  // messages + date headers in one list (oldest first)
  List<Object> buildItems() {
    final items = <Object>[];
    DateTime? lastDay;
    for (final m in messages) {
      final day = DateTime(m.time.year, m.time.month, m.time.day);
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(m);
    }
    return items;
  }

  // ---------- UI PIECES ----------
  Widget buildDateChip(DateTime day) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          dayLabel(day),
          style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
        ),
      ),
    );
  }

  Widget buildTick(int status) {
    if (status == 0) {
      return const Icon(Icons.done, size: 17, color: _tickGrey);
    }
    return const Icon(Icons.done_all, size: 17, color: _tickRead);
  }

  Widget buildBubble(Message msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => showMessageOptions(msg),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 5),
          decoration: BoxDecoration(
            color: msg.isMe ? _mine : _theirs,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
              bottomRight: Radius.circular(msg.isMe ? 4 : 16),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  msg.text,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(msg.time),
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 12,
                        ),
                      ),
                      if (msg.isMe) ...[
                        const SizedBox(width: 4),
                        buildTick(msg.status),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    if (loadError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to load messages. Check your Firebase Realtime Database rules.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSoft, fontSize: 16),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet\nSay hi 👋',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSoft, fontSize: 18, height: 1.5),
        ),
      );
    }

    final items = buildItems().reversed.toList();

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(12),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is DateTime) return buildDateChip(item);
        return buildBubble(item as Message);
      },
    );
  }

  Widget buildEmojiPanel() {
    return Container(
      height: 240,
      color: Colors.white,
      child: GridView.count(
        crossAxisCount: 8,
        padding: const EdgeInsets.all(8),
        children: _emojis
            .map(
              (e) => InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => insertEmoji(e),
            child: Center(
              child: Text(e, style: const TextStyle(fontSize: 26)),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: toggleEmoji,
                    icon: Icon(
                      showEmoji
                          ? Icons.keyboard_alt_outlined
                          : Icons.emoji_emotions_outlined,
                      color: AppColors.textSoft,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: AppColors.emerald,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                      ),
                      onChanged: (value) {
                        setState(() => hasText = value.trim().isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 17,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: showAttachMenu,
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.textSoft,
                    ),
                  ),
                  if (!hasText)
                    IconButton(
                      onPressed: () => snack('Camera is coming soon'),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppColors.textSoft,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.emerald,
            child: IconButton(
              onPressed: hasText
                  ? sendMessage
                  : () => snack('Voice messages are coming soon'),
              icon: Icon(
                hasText ? Icons.send_rounded : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _wallpaper,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: widget.color,
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => showCallDialog(true),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => showCallDialog(false),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'clear') clearChat();
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: _error),
                    SizedBox(width: 10),
                    Text(
                      'Clear chat',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // MESSAGES
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: closePanels,
                  child: buildMessageList(),
                ),
                if (showScrollDown)
                  Positioned(
                    right: 14,
                    bottom: 12,
                    child: FloatingActionButton.small(
                      heroTag: null,
                      backgroundColor: Colors.white,
                      onPressed: scrollToBottom,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.emerald,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // BOTTOM BAR (+ emoji panel)
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInputBar(),
                if (showEmoji) buildEmojiPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}