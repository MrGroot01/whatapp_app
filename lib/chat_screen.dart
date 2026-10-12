import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'database_helper.dart';

// One message = text + who sent it + time + tick status
class Message {
  final int id;
  final String text;
  final bool isMe;
  final DateTime time;
  int status; // 0 = sent, 1 = delivered, 2 = read

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = 0,
  });

  factory Message.fromRow(Map<String, Object?> r) {
    return Message(
      id: r['id'] as int,
      text: r['text'] as String,
      isMe: (r['is_me'] as int) == 1,
      time: DateTime.fromMillisecondsSinceEpoch(r['time_ms'] as int),
      status: r['status'] as int,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final Color color;

  const ChatScreen({super.key, required this.name, required this.color});

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

  List<Message> messages = [];
  bool loading = true;
  bool hasText = false;
  bool typing = false;
  bool showEmoji = false;
  bool showScrollDown = false;

  @override
  void initState() {
    super.initState();
    loadMessages();

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
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // ---------- DATABASE ----------
  Future<void> loadMessages() async {
    // first time only: add a few demo messages
    if (!await DatabaseHelper.isSeeded(widget.name)) {
      await seedMessages();
      await DatabaseHelper.markSeeded(widget.name);
    }

    final rows = await DatabaseHelper.getMessages(widget.name);
    if (!mounted) return;
    setState(() {
      messages = rows.map(Message.fromRow).toList();
      loading = false;
    });
  }

  Future<void> seedMessages() async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1, 18, 15);

    final demo = <List<Object>>[
      ['Hi!', false, yesterday],
      ['Hello, how are you?', true, yesterday.add(const Duration(minutes: 1))],
      [
        'I am good. What about you?',
        false,
        now.subtract(const Duration(minutes: 25))
      ],
      [
        'Doing great, working on my Flutter app',
        true,
        now.subtract(const Duration(minutes: 23))
      ],
      [
        'Nice! Show me when it is done',
        false,
        now.subtract(const Duration(minutes: 21))
      ],
    ];

    for (final d in demo) {
      await DatabaseHelper.addMessage(
        contact: widget.name,
        text: d[0] as String,
        isMe: d[1] as bool,
        timeMs: (d[2] as DateTime).millisecondsSinceEpoch,
        status: 2,
      );
    }
  }

  // ---------- SENDING ----------
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    setState(() => hasText = false);

    final now = DateTime.now();
    final id = await DatabaseHelper.addMessage(
      contact: widget.name,
      text: text,
      isMe: true,
      timeMs: now.millisecondsSinceEpoch,
      status: 0,
    );
    if (!mounted) return;

    final msg = Message(id: id, text: text, isMe: true, time: now);
    setState(() => messages.add(msg));
    scrollToBottom();

    updateTicks(msg);
    sendReply(text);
  }

  // one tick -> two grey ticks -> two blue ticks
  Future<void> updateTicks(Message msg) async {
    await Future.delayed(const Duration(seconds: 1));
    await setStatus(msg, 1);
    await Future.delayed(const Duration(seconds: 1));
    await setStatus(msg, 2);
  }

  Future<void> setStatus(Message msg, int status) async {
    await DatabaseHelper.updateStatus(msg.id, status);
    if (!mounted) return;
    setState(() => msg.status = status);
  }

  // the contact "types" and replies
  Future<void> sendReply(String sentText) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => typing = true);

    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(1500)));
    if (!mounted) return;

    final now = DateTime.now();
    final replyText = pickReply(sentText);
    final id = await DatabaseHelper.addMessage(
      contact: widget.name,
      text: replyText,
      isMe: false,
      timeMs: now.millisecondsSinceEpoch,
      status: 2,
    );
    if (!mounted) return;

    setState(() {
      typing = false;
      messages.add(Message(
        id: id,
        text: replyText,
        isMe: false,
        time: now,
        status: 2,
      ));
    });
  }

  String pickReply(String sent) {
    final t = sent.toLowerCase();
    final random = Random();

    // match whole words only, so "this" is not treated as "hi"
    bool hasWord(String words) => RegExp(r'\b(' + words + r')\b').hasMatch(t);

    if (t.contains('how are you')) {
      return 'I am fine, thanks for asking! 😊';
    }
    if (hasWord('hi|hello|hey')) {
      return ['Hello! 😊', 'Hey, how are you?', 'Hi there!'][random.nextInt(3)];
    }
    if (t.contains('thank')) {
      return 'You are welcome! 🙏';
    }
    if (hasWord('bye')) {
      return 'Bye, take care! 👋';
    }
    if (t.contains('?')) {
      return [
        'Let me check and tell you',
        'Good question 🤔',
        'I will tell you later'
      ][random.nextInt(3)];
    }
    const general = [
      'Okay 👍',
      'Nice!',
      'Haha, true 😂',
      'Alright, got it',
      'Tell me more',
      'Sure, no problem',
    ];
    return general[random.nextInt(general.length)];
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
    await DatabaseHelper.deleteMessage(msg.id);
    if (!mounted) return;
    setState(() => messages.remove(msg));
    snack('Message deleted');
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
      await DatabaseHelper.clearChat(widget.name);
      if (!mounted) return;
      setState(() => messages.clear());
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
                widget.name[0],
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
    return Icon(
      Icons.done_all,
      size: 17,
      color: status == 2 ? _tickRead : _tickGrey,
    );
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

  Widget buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _theirs,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'typing...',
          style: TextStyle(
            color: AppColors.textSoft,
            fontSize: 15,
            fontStyle: FontStyle.italic,
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

    if (messages.isEmpty && !typing) {
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
      itemCount: items.length + (typing ? 1 : 0),
      itemBuilder: (context, i) {
        var index = i;
        if (typing) {
          if (index == 0) return buildTypingBubble();
          index -= 1;
        }
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
                widget.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    typing ? 'typing...' : 'online',
                    style: TextStyle(
                      fontSize: 13,
                      color: typing
                          ? const Color(0xFFF2D98B)
                          : const Color(0xCCFFFFFF),
                    ),
                  ),
                ],
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