import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'create_task_screen.dart';
import 'call_screen.dart';
import 'contact_info_screen.dart';
import 'chat_media_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'incoming_message_notifier.dart';
import 'app_theme.dart';
import 'connection_banner.dart';
import 'database_helper.dart';
import 'message_sync_service.dart';

// One message = text / image / file / contact + who sent it + time + tick status
class Message {
  final String id; // the Firebase key of this message
  final String text;
  final bool isMe;
  final String senderId;
  final DateTime time;
  // 0 = sent, 2 = read, -1 = waiting for the internet, -2 = refused by server
  final int status;
  final String type; // 'text', 'image', 'file' or 'contact'
  final String url; // Storage URL for documents / older image messages
  final String
  imageBase64; // compressed image stored directly in Realtime Database
  final String fileName;
  final bool forwarded;
  final String replyToId; // the message this one replies to
  final String replyText; // short preview of that message
  final String replySenderId; // who wrote that message
  final Map<String, String> reactions; // account id -> emoji
  final String contactUid; // shared contact: account id
  final String contactName;
  final String contactPhone;
  final String contactCountryCode;

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.senderId,
    required this.time,
    this.status = 0,
    this.type = 'text',
    this.url = '',
    this.imageBase64 = '',
    this.fileName = '',
    this.forwarded = false,
    this.replyToId = '',
    this.replyText = '',
    this.replySenderId = '',
    this.reactions = const {},
    this.contactUid = '',
    this.contactName = '',
    this.contactPhone = '',
    this.contactCountryCode = '',
  });

  factory Message.fromMap(String id, Map<dynamic, dynamic> data, String myUid) {
    final ts = data['timeMs'];
    final st = data['status'];

    final reactions = <String, String>{};
    final rawReactions = data['reactions'];
    if (rawReactions is Map) {
      rawReactions.forEach((key, value) {
        if (value != null) reactions[key.toString()] = value.toString();
      });
    }

    final sender = (data['senderId'] ?? '').toString();

    return Message(
      id: id,
      text: (data['text'] ?? '').toString(),
      isMe: sender == myUid,
      senderId: sender,
      time: DateTime.fromMillisecondsSinceEpoch(
        ts is num ? ts.toInt() : DateTime.now().millisecondsSinceEpoch,
      ),
      status: st is num ? st.toInt() : 0,
      type: (data['type'] ?? 'text').toString(),
      url: (data['url'] ?? '').toString(),
      imageBase64: (data['imageBase64'] ?? '').toString(),
      fileName: (data['fileName'] ?? '').toString(),
      forwarded: data['forwarded'] == true,
      replyToId: (data['replyToId'] ?? '').toString(),
      replyText: (data['replyText'] ?? '').toString(),
      replySenderId: (data['replySenderId'] ?? '').toString(),
      reactions: reactions,
      contactUid: (data['contactUid'] ?? '').toString(),
      contactName: (data['contactName'] ?? '').toString(),
      contactPhone: (data['contactPhone'] ?? '').toString(),
      contactCountryCode: (data['contactCountryCode'] ?? '').toString(),
    );
  }
}

// One saved contact, used by the "share contact" and "forward" pickers
class _SavedContact {
  final String id;
  final String name;
  final String phone;
  final String countryCode;

  const _SavedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
  });
}

class ChatScreen extends StatefulWidget {
  final String name;
  final Color color;
  final String chatKey; // unique per account + contact
  final String phone; // contact phone number (without country code)
  final String countryCode; // e.g. +91

  const ChatScreen({
    super.key,
    required this.name,
    required this.color,
    required this.chatKey,
    this.phone = '',
    this.countryCode = '+91',
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
  static const Color _quoteOther = Color(0xFFAC44CF);

  // the quick reactions shown when you long-press a message
  static const List<String> _quickReactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  static const List<String> _emojis = [
    '😀', '😁', '😂', '🤣', '😊', '😍', '😘', '😎',
    '🤔', '😅', '😢', '😭', '😡', '🥳', '😴', '🤗',
    '👍', '👎', '👏', '🙏', '💪', '🙌', '👋', '🤝',
    '❤️', '💔', '🔥', '✨', '🎉', '🎂', '🌹', '⭐',
    '🍕', '🍔', '☕', '🍎', '⚽', '🏏', '🎵', '📚',
    '💻', '📱', '🚗', '🏠', '🌞', '🌙', '🌧️', '✅',
  ];

  final messageController = TextEditingController();
  // the message list can jump to any message (Search needs this)
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
    ItemPositionsListener.create();

  // ---------- SEARCH IN CHAT ----------
  bool searching = false;
  String searchQuery = '';
  int currentMatch = 0; // 0 = the newest match
  String? _currentMatchId;
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
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

  // the chat board between ME and another account (used by "forward")
  String _chatIdWith(String otherUid) {
    final parts = [_myUid, otherUid]..sort();
    return parts.join('_');
  }

  late final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref(
    'chats/$_chatId/messages',
  );
  StreamSubscription<DatabaseEvent>? _subscription;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // camera / gallery
  final ImagePicker _picker = ImagePicker();

  // Image selected for sending or scheduling with an optional text message.
  File? _draftImageFile;
  String _draftImageName = '';

  bool get _hasDraftContent =>
      messageController.text.trim().isNotEmpty || _draftImageFile != null;

  // speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  String _textBeforeMic = ''; // what was already typed before pressing the mic
  bool _heardWords = false;

  // language the mic understands. null = phone default.
  // Examples: 'en_IN' (Indian English), 'hi_IN' (Hindi), 'kn_IN' (Kannada)
  static const String? _speechLocale = 'en_IN';

  // messages from Firebase + messages still waiting in the phone's outbox
  List<Message> _remote = [];
  List<Message> _pending = [];
  Timer? _loadingTimer;

  List<Message> messages = [];
  bool loading = true;
  bool loadError = false;
  bool hasText = false;
  bool showEmoji = false;
  bool showScrollDown = false;
  bool uploading = false;
  bool listening = false;

  // the message the user is replying to (null = not replying)
  Message? replyingTo;

  @override
  void initState() {
    super.initState();
    IncomingMessageNotifier.activeChatId = _chatId;

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

    itemPositionsListener.itemPositions.addListener(_onPositionsChanged);

    // messages waiting for the internet (shown with a clock)
    MessageSyncService.version.addListener(_loadPending);
    _loadPending();

    // offline and nothing came from Firebase: do not spin forever
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && loading) setState(() => loading = false);
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus && showEmoji) {
        setState(() => showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    MessageSyncService.version.removeListener(_loadPending);
    _subscription?.cancel();
    _speech.cancel();
    messageController.dispose();
    itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    searchController.dispose();
    searchFocus.dispose();
    focusNode.dispose();
    if (IncomingMessageNotifier.activeChatId == _chatId) {
      IncomingMessageNotifier.activeChatId = '';
    }
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

    if (!mounted) return;
    _remote = list;
    loading = false;
    loadError = false;
    _rebuildMessages();


    _markIncomingAsRead(list);
  }

  // Firebase messages + messages still waiting in the outbox.
  // The same id is shown only once, so nothing appears twice.
  void _rebuildMessages() {
    if (!mounted) return;
    final ids = _remote.map((m) => m.id).toSet();
    final merged = <Message>[
      ..._remote,
      ..._pending.where((m) => !ids.contains(m.id)),
    ]..sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });

    setState(() {
      messages = merged;
      if (_pending.isNotEmpty) loading = false;
    });
  }

  // reads the messages waiting in SQLite for this chat
  Future<void> _loadPending() async {
    final uid = _myUid;
    if (uid.isEmpty) return;

    final rows = await DatabaseHelper.outboxForChat(uid, _chatId);
    final list = <Message>[];

    for (final row in rows) {
      try {
        final payload = Map<dynamic, dynamic>.from(
          jsonDecode(row['payload'] as String) as Map,
        );
        // -1 = waiting for the internet, -2 = the server refused it
        payload['status'] = (row['state'] as int) == 1 ? -2 : -1;
        list.add(Message.fromMap(row['id'] as String, payload, uid));
      } catch (e) {
        debugPrint('Bad outbox row: $e');
      }
    }

    if (!mounted) return;
    _pending = list;
    _rebuildMessages();
  }

  // messages from the other person become "read" when this chat is open

  Future<void> _markIncomingAsDelivered(List<Message> list) async {
    for (final m in list) {
      if (!m.isMe && m.status == 0) {
        try {
          await _messagesRef.child(m.id).update({'status': 1});
        } catch (e) {
          debugPrint('Delivery status update failed: $e');
        }
      }
    }
  }

  Future<void> _markIncomingAsRead(List<Message> list) async {
    for (final m in list) {
      if (!m.isMe && m.status != 2) {
        try {
          await _messagesRef.child(m.id).update({'status': 2});
        } catch (e) {
          debugPrint('Read status update failed: $e');
        }
      }
    }
  }


  // ---------- REPLY HELPERS ----------
  // a short text that describes any kind of message
  String _previewOf(Message m) {
    String t;
    switch (m.type) {
      case 'image':
        t = '📷 Photo';
        break;
      case 'file':
        t = '📄 ${m.fileName.isNotEmpty ? m.fileName : m.text}';
        break;
      case 'contact':
        t = '👤 ${m.contactName}';
        break;
      default:
        t = m.text;
    }
    return t.length > 100 ? '${t.substring(0, 100)}…' : t;
  }

  // adds the "reply to" fields when the user is replying to a message
  Map<String, dynamic> _withReply(Map<String, dynamic> data) {
    final r = replyingTo;
    if (r != null) {
      data['replyToId'] = r.id;
      data['replyText'] = _previewOf(r);
      data['replySenderId'] = r.senderId;
    }
    return data;
  }

  void startReply(Message msg) {
    setState(() {
      replyingTo = msg;
      showEmoji = false;
    });
    focusNode.requestFocus();
  }

  // ---------- SENDING TEXT / IMAGE ----------
  Future<void> sendMessage() async {
    if (listening) {
      await _speech.stop();
      if (mounted) setState(() => listening = false);
    }

    final text = messageController.text.trim();
    final imageFile = _draftImageFile;
    final imageName = _draftImageName;

    if (text.isEmpty && imageFile == null) return;
    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    try {
      final data = <String, dynamic>{
        'text': text,
        'type': imageFile != null ? 'image' : 'text',
      };

      if (imageFile != null) {
        final imageBase64 = base64Encode(await imageFile.readAsBytes());
        if (imageBase64.length > 5 * 1024 * 1024) {
          snack('Image is too large. Please choose a smaller photo.');
          return;
        }
        data['imageBase64'] = imageBase64;
        data['fileName'] = imageName;
      }

      await MessageSyncService.enqueue(
        chatId: _chatId,
        data: _withReply(data),
      );

      if (!mounted) return;
      messageController.clear();
      setState(() {
        hasText = false;
        replyingTo = null;
        _draftImageFile = null;
        _draftImageName = '';
      });
      scrollToBottom();
    } catch (e) {
      debugPrint('Send failed: $e');
      snack('Could not send the message. Please try again.');
    }
  }

  // ---------- SCHEDULE A MESSAGE OR IMAGE ("Send later") ----------
  int _daysFromToday(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(when.year, when.month, when.day);
    return day.difference(today).inDays;
  }

  String _scheduleLabel(DateTime when) {
    final diff = _daysFromToday(when);
    final time = formatTime(when);
    if (diff == 0) return 'today at $time';
    if (diff == 1) return 'tomorrow at $time';
    return 'on ${dayLabel(when)} at $time';
  }

  Future<void> showScheduleSheet() async {
    final text = messageController.text.trim();
    final imageFile = _draftImageFile;
    final imageName = _draftImageName;

    if (text.isEmpty && imageFile == null) {
      snack('Type a message or select an image first');
      return;
    }
    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }
    closePanels();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    var when = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final valid = when.isAfter(
              DateTime.now().add(const Duration(minutes: 1)),
            );
            final dateText = _daysFromToday(when) == 1
                ? 'Tomorrow, ${dayLabel(when)}'
                : dayLabel(when);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5D5D5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Schedule sending',
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final now = DateTime.now();
                              final d = await showDatePicker(
                                context: context,
                                initialDate: when,
                                firstDate: DateTime(now.year, now.month, now.day),
                                lastDate: now.add(const Duration(days: 365)),
                              );
                              if (d != null) {
                                setSheetState(() {
                                  when = DateTime(
                                    d.year, d.month, d.day,
                                    when.hour, when.minute,
                                  );
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                dateText,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(when),
                            );
                            if (t != null) {
                              setSheetState(() {
                                when = DateTime(
                                  when.year, when.month, when.day,
                                  t.hour, t.minute,
                                );
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14,
                            ),
                            child: Text(
                              formatTime(when),
                              style: GoogleFonts.poppins(
                                color: AppColors.emerald,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: valid
                            ? () => Navigator.pop(sheetContext, when)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFBFD8D2),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          valid
                              ? 'Send ${_scheduleLabel(when)}'
                              : 'Pick a time in the future',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: AppColors.emerald,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked == null || !mounted) return;
    await _scheduleMessage(
      text,
      picked,
      imageFile: imageFile,
      imageName: imageName,
    );
  }

  Future<void> _scheduleMessage(
      String text,
      DateTime when, {
        File? imageFile,
        String imageName = '',
      }) async {
    try {
      final data = <String, dynamic>{
        'text': text,
        'type': imageFile != null ? 'image' : 'text',
      };

      if (imageFile != null) {
        final imageBase64 = base64Encode(await imageFile.readAsBytes());
        if (imageBase64.length > 5 * 1024 * 1024) {
          snack('Image is too large. Please choose a smaller photo.');
          return;
        }
        data['imageBase64'] = imageBase64;
        data['fileName'] = imageName;
      }

      await MessageSyncService.enqueue(
        chatId: _chatId,
        data: _withReply(data),
        sendAt: when,
      );

      if (!mounted) return;
      messageController.clear();
      setState(() {
        hasText = false;
        replyingTo = null;
        _draftImageFile = null;
        _draftImageName = '';
      });
      snack('Message scheduled for ${_scheduleLabel(when)}');
    } catch (e) {
      debugPrint('Schedule failed: $e');
      snack('Could not schedule the message. Please try again.');
    }
  }

  // ---------- CALL ----------
  // Video call -> the in-app call screen (camera)
  // Voice call -> the phone's own dialer with the number already typed in
  void openCallScreen({required bool video}) {
    closePanels();

    if (!video) {
      dialNumber();
      return;
    }

    final otherUid = _otherUid;

    if (_myUid.isEmpty || otherUid.isEmpty) {
      snack('Could not identify the contact account');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          name: widget.name,
          color: widget.color,
          phone: widget.phone,
          countryCode: widget.countryCode,
          video: true,
          myUid: _myUid,
          otherUid: otherUid,
        ),
      ),
    );
  }

  Future<void> dialNumber() async {
    // remove spaces, dashes and brackets from the saved number
    var number = widget.phone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (number.isEmpty) {
      snack('No phone number saved for ${widget.name}');
      return;
    }

    // add the country code (for example +91) unless the number already has one
    if (!number.startsWith('+')) {
      number =
      '${widget.countryCode}${number.replaceFirst(RegExp(r'^0+'), '')}';
    }

    try {
      final opened = await launchUrl(Uri(scheme: 'tel', path: number));
      if (!opened) snack('Could not open the phone dialer');
    } catch (e) {
      debugPrint('Dialer failed: $e');
      snack('Could not open the phone dialer');
    }
  }

  // ---------- CAMERA / GALLERY / DOCUMENT ----------
  Future<void> pickFromCamera() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 35,
        maxWidth: 700,
        maxHeight: 700,
      );
      if (x == null || !mounted) return;
      setState(() {
        _draftImageFile = File(x.path);
        _draftImageName = x.name;
      });
    } catch (e) {
      snack('Could not open the camera. Check camera permission.');
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxWidth: 700,
        maxHeight: 700,
      );
      if (x == null || !mounted) return;
      setState(() {
        _draftImageFile = File(x.path);
        _draftImageName = x.name;
      });
    } catch (e) {
      snack('Could not open the gallery');
    }
  }

  Future<void> pickDocument() async {
    try {
      final res = await FilePicker.platform.pickFiles();
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.single;
      final path = picked.path;
      if (path == null) return;
      await _uploadAndSend(File(path), picked.name, 'file');
    } catch (e) {
      snack('Could not pick the document');
    }
  }

  // Images are stored as Base64 in Realtime Database (no Firebase Storage).
  // Documents still use Firebase Storage because they are binary files.
  Future<void> _uploadAndSend(
      File file,
      String name,
      String type,
      ) async {
    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    if (mounted) setState(() => uploading = true);

    try {
      final messageData = <String, dynamic>{
        'text': type == 'image' ? '' : name,
        'type': type,
        'fileName': name,
      };

      if (type == 'image') {
        // Read and save the compressed image into the SQLite outbox.
        final bytes = await file.readAsBytes();
        final imageBase64 = base64Encode(bytes);

        // Keep below the Realtime Database write-size limit.
        if (imageBase64.length > 5 * 1024 * 1024) {
          snack('Image is too large. Please choose a smaller photo.');
          return;
        }

        messageData['imageBase64'] = imageBase64;

        await MessageSyncService.enqueue(
          chatId: _chatId,
          data: _withReply(messageData),
        );

        if (mounted) {
          setState(() => replyingTo = null);
        }

        scrollToBottom();

        if (MessageSyncService.connection.value != ConnState.online) {
          snack('Photo saved. It will send when internet returns.');
        }
      } else {
        // Documents still require an internet connection.
        if (MessageSyncService.connection.value != ConnState.online) {
          snack('Documents can only be sent when you are online.');
          return;
        }

        final message = <String, dynamic>{
          ..._withReply(messageData),
          'senderId': _myUid,
          'timeMs': ServerValue.timestamp,
          'status': 0,
        };

        final ref = FirebaseStorage.instance.ref(
          'chats/$_chatId/'
              '${DateTime.now().millisecondsSinceEpoch}_$name',
        );

        await ref.putFile(file);
        message['url'] = await ref.getDownloadURL();

        await _messagesRef.push().set(message);

        if (mounted) {
          setState(() => replyingTo = null);
        }

        scrollToBottom();
      }
    } catch (e, stackTrace) {
      debugPrint('Attachment save failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      snack('Could not save the attachment. Please try again.');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> openUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      snack('Could not open the file');
    }
  }

  // ---------- SAVED CONTACTS (for share + forward) ----------
  Color _colorFor(String key) {
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
    return colors[key.hashCode.abs() % colors.length];
  }

  Future<List<_SavedContact>> _loadSavedContacts() async {
    final list = <_SavedContact>[];
    if (_myUid.isEmpty) return list;

    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/$_myUid/contacts')
          .get();
      final value = snap.value;
      if (value is Map) {
        value.forEach((key, data) {
          if (data is Map) {
            list.add(
              _SavedContact(
                id: key.toString(),
                name: (data['name'] ?? 'Contact').toString(),
                phone: (data['phone'] ?? '').toString(),
                countryCode: (data['countryCode'] ?? '+91').toString(),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Could not load contacts: $e');
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  // a bottom sheet with a search box and the list of saved contacts
  // multi = false -> tap one contact and the sheet closes
  // multi = true  -> tick several contacts, then press the send button
  Future<List<_SavedContact>?> _pickContacts({
    required String title,
    required bool multi,
  }) async {
    closePanels();

    final all = await _loadSavedContacts();
    if (!mounted) return null;

    if (all.isEmpty) {
      snack('No saved contacts yet');
      return null;
    }

    final selected = <String>{};
    String query = '';

    return showModalBottomSheet<List<_SavedContact>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final q = query.trim().toLowerCase();
            final shown = all.where((c) {
              if (q.isEmpty) return true;
              return c.name.toLowerCase().contains(q) ||
                  '${c.countryCode}${c.phone}'.contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                color: AppColors.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        cursorColor: AppColors.emerald,
                        onChanged: (v) => setSheetState(() => query = v),
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: shown.isEmpty
                          ? Center(
                        child: Text(
                          'No contact found',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSoft,
                            fontSize: 16,
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final c = shown[index];

                          final avatar = CircleAvatar(
                            backgroundColor: _colorFor(c.id),
                            child: Text(
                              c.name.isNotEmpty
                                  ? c.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );

                          final nameText = Text(
                            c.name,
                            style: GoogleFonts.poppins(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );

                          final phoneText = Text(
                            '${c.countryCode} ${c.phone}',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSoft,
                              fontSize: 13,
                            ),
                          );

                          if (!multi) {
                            return ListTile(
                              leading: avatar,
                              title: nameText,
                              subtitle: phoneText,
                              onTap: () =>
                                  Navigator.pop(sheetContext, [c]),
                            );
                          }

                          return CheckboxListTile(
                            secondary: avatar,
                            title: nameText,
                            subtitle: phoneText,
                            activeColor: AppColors.emerald,
                            value: selected.contains(c.id),
                            onChanged: (checked) {
                              setSheetState(() {
                                if (checked == true) {
                                  selected.add(c.id);
                                } else {
                                  selected.remove(c.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (multi)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: selected.isEmpty
                                ? null
                                : () => Navigator.pop(
                              sheetContext,
                              all
                                  .where((c) => selected.contains(c.id))
                                  .toList(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              selected.isEmpty
                                  ? 'Select contacts'
                                  : 'Send to ${selected.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- SHARE A CONTACT ----------
  Future<void> shareContact() async {
    final picked = await _pickContacts(title: 'Share contact', multi: false);
    if (picked == null || picked.isEmpty) return;
    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    final c = picked.first;

    try {
      await MessageSyncService.enqueue(
        chatId: _chatId,
        data: _withReply({
          'text': c.name,
          'type': 'contact',
          'contactUid': c.id,
          'contactName': c.name,
          'contactPhone': c.phone,
          'contactCountryCode': c.countryCode,
        }),
      );
      if (mounted) setState(() => replyingTo = null);
      scrollToBottom();
    } catch (e) {
      debugPrint('Share contact failed: $e');
      snack('Could not share the contact. Please try again.');
    }
  }

  // tap on a shared contact card
  Future<void> showContactCard(Message msg) async {
    final uid = msg.contactUid;
    final canUse = uid.isNotEmpty && uid != _myUid;

    bool alreadySaved = false;
    if (canUse) {
      try {
        final snap = await FirebaseDatabase.instance
            .ref('users/$_myUid/contacts/$uid')
            .get();
        alreadySaved = snap.exists;
      } catch (e) {
        debugPrint('Contact check failed: $e');
      }
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: _colorFor(uid.isEmpty ? msg.contactName : uid),
                child: Text(
                  msg.contactName.isNotEmpty
                      ? msg.contactName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                msg.contactName,
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${msg.contactCountryCode} ${msg.contactPhone}',
                style: GoogleFonts.poppins(
                  color: AppColors.textSoft,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              if (canUse)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      openChatWith(msg);
                    },
                    icon: const Icon(Icons.chat),
                    label: Text(
                      'Message',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              if (canUse && !alreadySaved) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      saveSharedContact(msg);
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(
                      'Save contact',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emerald,
                      side: const BorderSide(color: AppColors.emerald),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              if (canUse && alreadySaved)
                Text(
                  'Already in your contacts',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSoft,
                    fontSize: 14,
                  ),
                ),
              if (!canUse)
                Text(
                  uid == _myUid ? 'This is your own number' : '',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSoft,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void openChatWith(Message msg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          name: msg.contactName,
          color: _colorFor(msg.contactUid),
          chatKey: '${_myUid}_${msg.contactUid}',
          phone: msg.contactPhone,
          countryCode: msg.contactCountryCode,
        ),
      ),
    );
  }

  Future<void> saveSharedContact(Message msg) async {
    final uid = msg.contactUid;
    if (uid.isEmpty || uid == _myUid) return;

    try {
      await FirebaseDatabase.instance.ref('users/$_myUid/contacts/$uid').set({
        'uid': uid,
        'name': msg.contactName,
        'phone': msg.contactPhone,
        'countryCode': msg.contactCountryCode,
        'addedAt': ServerValue.timestamp,
        'lastMessage': 'Tap to start chatting',
        'time': '',
      });
      snack('Contact saved');
    } catch (e) {
      debugPrint('Save contact failed: $e');
      snack('Could not save the contact. Check the database rules.');
    }
  }

  // ---------- REACTIONS ----------
  // tap the same emoji again to remove your reaction
  Future<void> reactTo(Message msg, String emoji) async {
    if (msg.status < 0) {
      snack('Wait until the message is sent');
      return;
    }

    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    final ref = _messagesRef.child(msg.id).child('reactions').child(_myUid);

    try {
      if (msg.reactions[_myUid] == emoji) {
        await ref.remove();
      } else {
        await ref.set(emoji);
      }
    } catch (e) {
      debugPrint('Reaction failed: $e');
      snack('Could not add the reaction. Check the database rules.');
    }
  }

  // the "+" button: pick any emoji from the full list
  void pickAnyEmoji(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SizedBox(
        height: 300,
        child: GridView.count(
          crossAxisCount: 8,
          padding: const EdgeInsets.all(12),
          children: _emojis
              .map(
                (e) => InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.pop(sheetContext);
                reactTo(msg, e);
              },
              child: Center(
                child: Text(e, style: const TextStyle(fontSize: 26)),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  // ---------- FORWARD ----------
  Future<void> forwardMessage(Message msg) async {
    if (msg.status < 0) {
      snack('Wait until the message is sent');
      return;
    }

    final picked = await _pickContacts(title: 'Forward to...', multi: true);
    if (picked == null || picked.isEmpty) return;
    if (_myUid.isEmpty) {
      snack('Please log in again');
      return;
    }

    int done = 0;

    for (final c in picked) {
      try {
        final data = <String, dynamic>{
          'text': msg.text,
          'type': msg.type,
          'forwarded': true,
        };
        if (msg.url.isNotEmpty) data['url'] = msg.url;
        if (msg.imageBase64.isNotEmpty) data['imageBase64'] = msg.imageBase64;
        if (msg.fileName.isNotEmpty) data['fileName'] = msg.fileName;
        if (msg.type == 'contact') {
          data['contactUid'] = msg.contactUid;
          data['contactName'] = msg.contactName;
          data['contactPhone'] = msg.contactPhone;
          data['contactCountryCode'] = msg.contactCountryCode;
        }

        if (msg.type == 'text' || msg.type == 'contact') {
          // small: saved on the phone first, works offline
          await MessageSyncService.enqueue(
            chatId: _chatIdWith(c.id),
            data: data,
          );
        } else {
          // photos and documents are big: they need the internet right now
          data['senderId'] = _myUid;
          data['timeMs'] = ServerValue.timestamp;
          data['status'] = 0;
          await FirebaseDatabase.instance
              .ref('chats/${_chatIdWith(c.id)}/messages')
              .push()
              .set(data);
        }
        done++;
      } catch (e) {
        debugPrint('Forward to ${c.name} failed: $e');
      }
    }

    snack(
      done == picked.length
          ? 'Message forwarded'
          : 'Forwarded to $done of ${picked.length} contacts',
    );
  }
  // ---------- CREATE A TASK FROM A MESSAGE ----------
  // the account id of the person I am chatting with
  String get _otherUid {
    final parts = widget.chatKey.split('_');
    if (parts.length != 2) return '';
    return parts[0] == _myUid ? parts[1] : parts[0];
  }

  // ---------- CREATE A TASK FROM A MESSAGE ----------
  void createTaskFromMessage(Message msg) {
    final text = msg.type == 'text' ? msg.text : _previewOf(msg);
    final firstLine = text.split('\n').first.trim();
    final title =
    firstLine.length > 80 ? '${firstLine.substring(0, 80)}...' : firstLine;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(
          initialTitle: title,
          sourceText: text,
          fromName: msg.isMe ? 'You' : widget.name,
          sourceTime: msg.time,
          chatId: _chatId,
          messageId: msg.id,
          // the chat contact can get this task
          assigneeUid: _otherUid,
          assigneeName: widget.name,
          // my own message -> start with the contact selected
          assignByDefault: msg.isMe,
        ),
      ),
    );
  }
  // ---------- SPEECH TO TEXT ----------
  Future<bool> _initSpeech() async {
    if (_speechReady) return true;
    _speechReady = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    return _speechReady;
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    if ((status == 'notListening' || status == 'done') && listening) {
      setState(() => listening = false);
    }
  }

  void _onSpeechError(SpeechRecognitionError e) {
    if (!mounted) return;
    debugPrint('Speech error: ${e.errorMsg}');
    setState(() => listening = false);

    if (e.errorMsg == 'error_speech_timeout' ||
        e.errorMsg == 'error_no_match') {
      // only complain if nothing was heard
      if (!_heardWords) {
        snack("I didn't hear anything. Tap the mic and speak clearly.");
      }
    } else if (e.errorMsg == 'error_permission') {
      snack('Please allow the microphone permission for this app');
    } else if (e.errorMsg == 'error_network' ||
        e.errorMsg == 'error_network_timeout' ||
        e.errorMsg == 'error_language_unavailable' ||
        e.errorMsg == 'error_language_not_supported') {
      snack(
        'Voice error: ${e.errorMsg}\n'
            'Download your language in the phone settings '
            '(Offline speech recognition), or type your message.',
      );
    } else {
      snack('Speech error: ${e.errorMsg}');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isEmpty) return;

    _heardWords = true;
    final full = _textBeforeMic.isEmpty ? words : '$_textBeforeMic $words';

    messageController.value = TextEditingValue(
      text: full,
      selection: TextSelection.collapsed(offset: full.length),
    );
    if (mounted) setState(() => hasText = true);
  }

  // tap the mic: start listening
  Future<void> toggleListening() async {
    final ok = await _initSpeech();
    if (!ok) {
      snack('Microphone permission is needed. Allow it in the app settings.');
      return;
    }
    if (!mounted) return;

    closePanels();
    _textBeforeMic = messageController.text.trim();
    _heardWords = false;
    setState(() => listening = true);

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: stt.SpeechListenOptions(
        localeId: _speechLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  // tap stop: keep the text in the box so you can edit it or send it
  Future<void> stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => listening = false);
  }

  // cancel: throw away what was heard
  Future<void> cancelListening() async {
    await _speech.cancel();
    messageController.text = _textBeforeMic;
    messageController.selection = TextSelection.collapsed(
      offset: _textBeforeMic.length,
    );
    if (mounted) {
      setState(() {
        listening = false;
        hasText = _textBeforeMic.isNotEmpty;
      });
    }
  }

  // small bar shown while the mic is listening
  Widget buildListeningBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: _error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Listening... speak now',
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: cancelListening,
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: _error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ACTIONS ----------
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: 0, // the list is reversed: item 0 is the newest message
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // shows the "scroll down" button when the newest message is out of view
  void _onPositionsChanged() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || !mounted) return;
    final atBottom = positions.any((p) => p.index == 0);
    if (showScrollDown == atBottom) {
      setState(() => showScrollDown = !atBottom);
    }
  }

  // ---------- SEARCH IN CHAT ----------
  void startSearch() {
    searchController.clear();
    setState(() {
      searching = true;
      searchQuery = '';
      currentMatch = 0;
      showEmoji = false;
      replyingTo = null;
    });
  }

  void stopSearch() {
    searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      searching = false;
      searchQuery = '';
      currentMatch = 0;
    });
  }

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
      currentMatch = 0; // start from the newest match
    });
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _jumpToCurrentMatch(animate: false),
    );
  }

  // delta = 1 -> older match (up arrow), delta = -1 -> newer match (down arrow)
  void goToMatch(int delta) {
    final matches = _searchMatches(buildItems().reversed.toList());
    if (matches.isEmpty) return;
    setState(() {
      currentMatch = (currentMatch + delta).clamp(0, matches.length - 1).toInt();
    });
    _jumpToCurrentMatch(animate: true);
  }

  void _jumpToCurrentMatch({required bool animate}) {
    if (!mounted || !itemScrollController.isAttached) return;
    final matches = _searchMatches(buildItems().reversed.toList());
    if (matches.isEmpty) return;

    final index = matches[currentMatch.clamp(0, matches.length - 1).toInt()];
    if (animate) {
      itemScrollController.scrollTo(
        index: index,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      itemScrollController.jumpTo(index: index, alignment: 0.5);
    }
  }

  bool _messageMatches(Message m, String query) {
    final needle = query.toLowerCase();
    switch (m.type) {
      case 'text':
        return m.text.toLowerCase().contains(needle);
      case 'file':
        final name = m.fileName.isNotEmpty ? m.fileName : m.text;
        return name.toLowerCase().contains(needle);
      case 'contact':
        return m.contactName.toLowerCase().contains(needle) ||
            m.contactPhone.contains(needle);
      default:
        return false; // photos have no text to search
    }
  }

  // the positions (in the shown list) of the messages that match the search
  List<int> _searchMatches(List<Object> items) {
    final q = searchQuery.trim();
    if (q.isEmpty) return <int>[];

    final result = <int>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is Message && _messageMatches(item, q)) result.add(i);
    }
    return result;
  }

  // text with the searched words highlighted in yellow
  // (the current match is orange)
  Widget _highlightedText(String text, String messageId, {double fontSize = 17}) {
    final style = GoogleFonts.poppins(
      color: AppColors.textDark,
      fontSize: fontSize,
      height: 1.3,
    );

    final q = searching ? searchQuery.trim() : '';
    if (q.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final needle = q.toLowerCase();
    if (lower.length != text.length) return Text(text, style: style);

    final color = messageId == _currentMatchId
        ? const Color(0xFFFFB84D)
        : const Color(0xFFFFE58F);

    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final i = lower.indexOf(needle, start);
      if (i < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (i > start) spans.add(TextSpan(text: text.substring(start, i)));
      spans.add(
        TextSpan(
          text: text.substring(i, i + needle.length),
          style: TextStyle(backgroundColor: color),
        ),
      );
      start = i + needle.length;
    }

    return Text.rich(TextSpan(style: style, children: spans));
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
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> deleteMessage(Message msg) async {
    try {
      // a message still waiting on the phone only needs to leave the outbox
      if (msg.status < 0) {
        await MessageSyncService.discard(msg.id);
        snack('Message deleted');
        return;
      }
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
        title: Text(
          'Clear chat?',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'All messages with ${widget.name} will be deleted.',
          style: GoogleFonts.poppins(color: AppColors.textSoft, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.textSoft,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(
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

  // long-press on a message: emoji reactions + Reply / Forward / Copy / Delete
  void showMessageOptions(Message msg) {
    closePanels();
    final mine = msg.reactions[_myUid];

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
            const SizedBox(height: 14),

            // EMOJI REACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final e in _quickReactions)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        reactTo(msg, e);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mine == e ? _mine : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      pickAnyEmoji(msg);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: _wallpaper,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textSoft,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.emerald),
              title: Text(
                'Reply',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                startReply(msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward, color: AppColors.emerald),
              title: Text(
                'Forward',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                forwardMessage(msg);
              },

            ),

            // the server refused this message: send it again
            if (msg.status == -2)
              ListTile(
                leading: const Icon(Icons.refresh, color: AppColors.emerald),
                title: Text(
                  'Try again',
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 17,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  MessageSyncService.retry(msg.id);
                },
              ),

            // only text messages can be copied
            if (msg.type == 'text')
              ListTile(
                leading: const Icon(
                  Icons.copy_rounded,
                  color: AppColors.emerald,
                ),
                title: Text(
                  'Copy',
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 17,
                  ),
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
                title: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: _error, fontSize: 17),
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

    Widget item(IconData icon, String label, Color color, VoidCallback action) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          action();
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
              style: GoogleFonts.poppins(
                color: AppColors.textSoft,
                fontSize: 14,
              ),
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
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 24,
            runSpacing: 22,
            children: [
              item(
                Icons.insert_drive_file,
                'Document',
                const Color(0xFF5F66CD),
                pickDocument,
              ),
              item(
                Icons.camera_alt,
                'Camera',
                const Color(0xFFD3396D),
                pickFromCamera,
              ),
              item(
                Icons.photo,
                'Gallery',
                const Color(0xFFAC44CF),
                pickFromGallery,
              ),
              item(
                Icons.person,
                'Contact',
                const Color(0xFF0795DC),
                shareContact,
              ),
              item(
                Icons.location_on,
                'Location',
                const Color(0xFF1FA855),
                    () => snack('Location sharing is coming soon'),
              ),
            ],
          ),
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
          style: GoogleFonts.poppins(color: AppColors.textSoft, fontSize: 13),
        ),
      ),
    );
  }


  Widget buildTick(int status) {
    // Waiting for internet
    if (status == -1) {
      return const Icon(
        Icons.schedule,
        size: 16,
        color: _tickGrey,
      );
    }

    // Failed to send
    if (status == -2) {
      return const Icon(
        Icons.error_outline,
        size: 17,
        color: _error,
      );
    }

    // Sent: one grey tick
    if (status == 0) {
      return const Icon(
        Icons.done,
        size: 17,
        color: _tickGrey,
      );
    }

    // Delivered: two grey ticks
    if (status == 1) {
      return const Icon(
        Icons.done_all,
        size: 17,
        color: _tickGrey,
      );
    }

    // Read: two blue ticks
    return const Icon(
      Icons.done_all,
      size: 17,
      color: _tickRead,
    );
  }


  // the quoted message shown at the top of a reply bubble
  Widget buildReplyQuote(Message msg) {
    final fromMe = msg.replySenderId == _myUid;
    final barColor = fromMe ? AppColors.emerald : _quoteOther;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: const Color(0x0F000000),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: barColor),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fromMe ? 'You' : widget.name,
                          style: GoogleFonts.poppins(
                            color: barColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          msg.replyText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSoft,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // the small emoji badge under a message
  Widget buildReactions(Message msg) {
    final emojis = msg.reactions.values.toSet().take(3).join(' ');
    final total = msg.reactions.length;

    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emojis, style: const TextStyle(fontSize: 15)),
          if (total > 1)
            Text(
              ' $total',
              style: GoogleFonts.poppins(
                color: AppColors.textSoft,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  // text, image, file or contact card inside a bubble
  Widget buildContent(Message msg) {
    // A shared contact card
    if (msg.type == 'contact') {
      return InkWell(
        onTap: () => showContactCard(msg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _colorFor(
                msg.contactUid.isEmpty ? msg.contactName : msg.contactUid,
              ),
              child: Text(
                msg.contactName.isNotEmpty
                    ? msg.contactName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.contactName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${msg.contactCountryCode} ${msg.contactPhone}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSoft,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // New image messages are loaded from Base64 in Realtime Database.
    if (msg.type == 'image' && msg.imageBase64.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    body: Center(
                      child: InteractiveViewer(
                        child: Image.memory(
                          base64Decode(msg.imageBase64),
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                base64Decode(msg.imageBase64),
                width: 220,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox(
                  width: 220,
                  height: 120,
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          if (msg.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2, right: 2),
              child: _highlightedText(msg.text, msg.id),
            ),
        ],
      );
    }

    // Support older image messages that were saved as Storage URLs.
    if (msg.type == 'image' && msg.url.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => openUrl(msg.url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                msg.url,
                width: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 220,
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.emerald),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => const SizedBox(
                  width: 220,
                  height: 120,
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          if (msg.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2, right: 2),
              child: _highlightedText(msg.text, msg.id),
            ),
        ],
      );
    }

    if (msg.type == 'file') {
      return InkWell(
        onTap: () => openUrl(msg.url),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file,
              color: AppColors.emerald,
              size: 32,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _highlightedText(
                msg.fileName.isNotEmpty ? msg.fileName : msg.text,
                msg.id,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return _highlightedText(msg.text, msg.id);
  }

  Widget buildBubble(Message msg) {
    final bubble = GestureDetector(
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
              if (msg.forwarded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.forward,
                        size: 14,
                        color: AppColors.textSoft,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Forwarded',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSoft,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              if (msg.replyToId.isNotEmpty) buildReplyQuote(msg),
              buildContent(msg),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(msg.time),
                      style: GoogleFonts.poppins(
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
    );

    return Column(
      crossAxisAlignment: msg.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [bubble, if (msg.reactions.isNotEmpty) buildReactions(msg)],
    );
  }

  Widget buildMessageList(List<Object> items) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    if (loadError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load messages. Check your Firebase Realtime Database rules.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSoft, fontSize: 16),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet\nSay hi 👋',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.textSoft,
            fontSize: 18,
            height: 1.5,
          ),
        ),
      );
    }

    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is DateTime) {
          return buildDateChip(item);
        }

        final msg = item as Message;

        return Dismissible(
          key: ValueKey(msg.id),
          direction: DismissDirection.startToEnd,
          dismissThresholds: const {DismissDirection.startToEnd: 0.2},
          confirmDismiss: (_) async {
            startReply(msg);
            return false;
          },
          background: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.reply, color: AppColors.textSoft),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Align(
              alignment:
              msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: buildBubble(msg),
            ),
          ),
        );
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

  // the bar above the input while replying
  Widget buildReplyBar() {
    final r = replyingTo!;
    final fromMe = r.isMe;
    final barColor = fromMe ? AppColors.emerald : _quoteOther;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Colors.white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: barColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fromMe ? 'You' : widget.name,
                          style: GoogleFonts.poppins(
                            color: barColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _previewOf(r),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSoft,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSoft),
                  onPressed: () => setState(() => replyingTo = null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_draftImageFile != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _draftImageFile!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Photo attached')),
                  IconButton(
                    tooltip: 'Remove photo',
                    onPressed: () {
                      setState(() {
                        _draftImageFile = null;
                        _draftImageName = '';
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Row(
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
                          style: GoogleFonts.poppins(
                            color: AppColors.textDark,
                            fontSize: 17,
                          ),
                          onChanged: (value) {
                            setState(() => hasText = value.trim().isNotEmpty);
                          },
                          decoration: InputDecoration(
                            hintText: listening ? 'Listening...' : 'Message',
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textSoft,
                              fontSize: 17,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
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
                          onPressed: pickFromCamera,
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
              GestureDetector(
                // long-press the send button = "Send later"
                onLongPress: (_hasDraftContent && !listening) ? showScheduleSheet : null,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.emerald,
                  child: IconButton(
                    onPressed: listening
                        ? stopListening
                        : (_hasDraftContent ? sendMessage : toggleListening),
                    icon: Icon(
                      listening
                          ? Icons.stop
                          : (_hasDraftContent ? Icons.send_rounded : Icons.mic),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Open the WhatsApp-style contact information page from the chat header.
  void openContactInfo() {
    closePanels();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactInfoScreen(
          name: widget.name,
          phone: widget.phone,
          countryCode: widget.countryCode,
          color: widget.color,
          chatId: _chatId,
          onAudioCall: () => openCallScreen(video: false),
          onVideoCall: () => openCallScreen(video: true),
          onSearch: startSearch,
          onClearChat: clearChat,
        ),
      ),
    );
  }

  // photos, documents and links shared in this chat
  void openMedia() {
    closePanels();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMediaScreen(chatId: _chatId, name: widget.name),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value,
      IconData icon,
      String label, {
        bool danger = false,
      }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: danger ? _error : AppColors.textSoft),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: danger ? _error : AppColors.textDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // the normal top bar of the chat
  AppBar buildNormalAppBar() {
    return AppBar(
      backgroundColor: AppColors.emerald,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      title: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: openContactInfo,
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: widget.color,
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () => openCallScreen(video: true),
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () => openCallScreen(video: false),
        ),
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) {
            switch (value) {
              case 'info':
                openContactInfo();
                break;
              case 'search':
                startSearch();
                break;
              case 'media':
                openMedia();
                break;
              case 'clear':
                clearChat();
                break;
            }
          },
          itemBuilder: (context) => [
            _menuItem('info', Icons.person_outline, 'View Profile'),
            _menuItem('search', Icons.search, 'Search'),
            _menuItem(
              'media',
              Icons.photo_library_outlined,
              'Media, links, and docs',
            ),
            const PopupMenuDivider(),
            _menuItem('clear', Icons.delete_sweep, 'Clear chat', danger: true),
          ],
        ),
      ],
    );
  }

  // the top bar while searching: a text box, a counter and two arrows
  AppBar buildSearchAppBar(int total) {
    return AppBar(
      backgroundColor: AppColors.emerald,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: stopSearch,
      ),
      title: TextField(
        controller: searchController,
        focusNode: searchFocus,
        autofocus: true,
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 17),
        onChanged: onSearchChanged,
        onSubmitted: (_) => goToMatch(1),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xB3FFFFFF),
            fontSize: 17,
          ),
          border: InputBorder.none,
        ),
      ),
      actions: [
        if (searchQuery.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                total == 0 ? 'No results' : '${currentMatch + 1} of $total',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: total == 0 ? null : () => goToMatch(1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: total == 0 ? null : () => goToMatch(-1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // the list shown on screen: newest first (the list is reversed)
    final items = buildItems().reversed.toList();

    // search results: the positions of the messages that match
    final matches = searching ? _searchMatches(items) : <int>[];
    if (currentMatch >= matches.length) {
      currentMatch = matches.isEmpty ? 0 : matches.length - 1;
    }
    _currentMatchId =
    matches.isEmpty ? null : (items[matches[currentMatch]] as Message).id;

    return PopScope(
      // the phone's back button closes the search first
      canPop: !searching,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && searching) stopSearch();
      },
      child: Scaffold(
        backgroundColor: _wallpaper,
        appBar: searching
            ? buildSearchAppBar(matches.length)
            : buildNormalAppBar(),
        body: Column(
          children: [
            // internet / waiting-to-send message
            const ConnectionBanner(),

            // MESSAGES
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: closePanels,
                    child: buildMessageList(items),
                  ),
                  if (showScrollDown && !searching)
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

            // upload progress
            if (uploading)
              const LinearProgressIndicator(color: AppColors.emerald),

            // BOTTOM BAR (hidden while searching, like WhatsApp)
            if (!searching)
              SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (replyingTo != null) buildReplyBar(),
                    if (listening) buildListeningBar(),
                    buildInputBar(),
                    if (showEmoji) buildEmojiPanel(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
