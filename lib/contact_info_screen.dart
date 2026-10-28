import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'chat_media.dart';
import 'chat_media_screen.dart';

class ContactInfoScreen extends StatefulWidget {
  final String name;
  final Color color;
  final String phone;
  final String countryCode;
  final String chatId;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback onSearch;
  final VoidCallback onClearChat;

  const ContactInfoScreen({
    super.key,
    required this.name,
    required this.color,
    required this.phone,
    required this.countryCode,
    required this.chatId,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onSearch,
    required this.onClearChat,
  });

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  // created ONCE, so the screen does not re-subscribe on every redraw
  late final Stream<List<MediaEntry>> _mediaStream =
  mediaStream(widget.chatId);

  // the disappearing-messages setting shared by both people in this chat
  late final DatabaseReference _disappearRef = FirebaseDatabase.instance.ref(
    'chats/${widget.chatId}/settings/disappearAfterMs',
  );
  late final Stream<DatabaseEvent> _disappearStream = _disappearRef.onValue;

  static const List<List<Object>> _disappearOptions = [
    ['Off', 0],
    ['5 minutes', 300000],
    ['1 day', 86400000],
    ['7 days', 604800000],
  ];

  // Resolve the other participant from the sorted direct-chat ID.
  // Direct chat IDs are stored as UID1_UID2, with both UIDs sorted.
  late final String _contactUid = _resolveContactUid();

  String _resolveContactUid() {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final parts = widget.chatId.split('_');

    if (myUid.isEmpty || parts.length != 2) return '';
    if (parts[0] == myUid) return parts[1];
    if (parts[1] == myUid) return parts[0];
    return '';
  }

  // Keep one stable stream for this screen; it updates when the contact changes DP.
  late final Stream<DatabaseEvent>? _contactPhotoStream = _contactUid.isEmpty
      ? null
      : FirebaseDatabase.instance
      .ref('publicProfiles/$_contactUid/photoBase64')
      .onValue;

  String get fullPhone => '${widget.countryCode} ${widget.phone}'.trim();

  void _openMedia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatMediaScreen(chatId: widget.chatId, name: widget.name),
      ),
    );
  }

  String _disappearLabel(int ms) {
    for (final o in _disappearOptions) {
      if (o[1] == ms) return o[0] as String;
    }
    return 'Off';
  }

  Future<void> _setDisappear(int ms) async {
    try {
      if (ms == 0) {
        await _disappearRef.remove();
      } else {
        await _disappearRef.set(ms);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(context, 'Could not change the setting. Check your internet.');
    }
  }

  void _showDisappearSheet(int current) {
    showModalBottomSheet(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Disappearing messages',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'New messages in this chat will disappear after the time you choose.',
                style: GoogleFonts.poppins(
                  color: AppColors.textSoft,
                  fontSize: 13,
                ),
              ),
            ),
            for (final o in _disappearOptions)
              ListTile(
                title: Text(
                  o[0] as String,
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                ),
                trailing: current == o[1]
                    ? const Icon(Icons.check_circle, color: AppColors.emerald)
                    : const Icon(
                  Icons.circle_outlined,
                  color: AppColors.textSoft,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setDisappear(o[1] as int);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textDark;
    final softColor = AppColors.textSoft;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: Text(
          'Contact info',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') widget.onClearChat();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear chat')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                StreamBuilder<DatabaseEvent>(
                  stream: _contactPhotoStream,
                  builder: (context, snapshot) {
                    final value = snapshot.data?.snapshot.value;
                    ImageProvider? photo;

                    if (value is String && value.isNotEmpty) {
                      try {
                        photo = MemoryImage(base64Decode(value));
                      } catch (e) {
                        debugPrint('Could not decode contact info DP: $e');
                      }
                    }

                    return CircleAvatar(
                      radius: 62,
                      backgroundColor: widget.color,
                      backgroundImage: photo,
                      child: photo == null
                          ? Text(
                        widget.name.isNotEmpty
                            ? widget.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fullPhone.isEmpty ? 'Phone number unavailable' : fullPhone,
                  style: GoogleFonts.poppins(color: softColor, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.call_outlined,
                      label: 'Audio',
                      onTap: widget.onAudioCall,
                    ),
                    _ActionButton(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      onTap: widget.onVideoCall,
                    ),
                    _ActionButton(
                      icon: Icons.search,
                      label: 'Search',
                      // close this page first, then start the search in the chat
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSearch();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _mediaSection(),
          const SizedBox(height: 8),
          _section(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => _showMessage(context, 'Notification settings'),
          ),
          _section(
            icon: Icons.image_outlined,
            title: 'Media visibility',
            onTap: () => _showMessage(context, 'Media visibility settings'),
          ),
          _section(
            icon: Icons.lock_outline,
            title: 'Encryption',
            subtitle: 'Messages and calls are not yet end-to-end encrypted.',
            onTap: () => _showMessage(
              context,
              'This app does not currently implement end-to-end encryption.',
            ),
          ),
          StreamBuilder<DatabaseEvent>(
            stream: _disappearStream,
            builder: (context, snap) {
              final v = snap.data?.snapshot.value;
              final ms = v is num ? v.toInt() : 0;
              return _section(
                icon: Icons.timer_outlined,
                title: 'Disappearing messages',
                subtitle: _disappearLabel(ms),
                onTap: () => _showDisappearSheet(ms),
              );
            },
          ),
          const SizedBox(height: 8),
          _section(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear chat',
            titleColor: Colors.red,
            onTap: widget.onClearChat,
          ),
          _section(
            icon: Icons.block,
            title: 'Block contact',
            titleColor: Colors.red,
            onTap: () => _showMessage(
              context,
              'Contact blocking is not implemented yet.',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // "Media, links, and docs" with a count and the latest photos
  Widget _mediaSection() {
    return StreamBuilder<List<MediaEntry>>(
      stream: _mediaStream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <MediaEntry>[];
        final images = all.where((e) => e.kind == 'image').toList();
        final shown = images.length < 4 ? images.length : 4;

        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: _openMedia,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Media, links, and docs',
                          style: GoogleFonts.poppins(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (all.isNotEmpty)
                        Text(
                          '${all.length}',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSoft,
                            fontSize: 14,
                          ),
                        ),
                      const Icon(Icons.chevron_right, color: AppColors.textSoft),
                    ],
                  ),
                  if (shown > 0) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: shown,
                        separatorBuilder: (context, index) =>
                        const SizedBox(width: 6),
                        itemBuilder: (context, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: MediaImage(
                              entry: images[i],
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _section({
    IconData? icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: icon == null
            ? null
            : Icon(icon, color: AppColors.textSoft, size: 25),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: titleColor ?? AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: AppColors.textSoft,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.emerald, size: 27),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.emerald,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
