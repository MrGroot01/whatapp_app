import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/chat_media.dart';
import '../core/app_icons.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../models/media_entry.dart';
import 'chat_media_screen.dart';
import 'widgets/media_widgets.dart';

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
    [AppStrings.disappearOff, 0],
    [AppStrings.disappear5Min, 300000],
    [AppStrings.disappear1Day, 86400000],
    [AppStrings.disappear7Days, 604800000],
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
    return AppStrings.disappearOff;
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
      _showMessage(context, AppStrings.couldNotChangeSetting);
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
                AppStrings.disappearingTitle,
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
                AppStrings.disappearingChatHelp,
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
                    ? const Icon(AppIcons.selected, color: AppColors.emerald)
                    : const Icon(
                  AppIcons.notSelected,
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
      backgroundColor: AppColors.plainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.contactInfoTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') widget.onClearChat();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text(AppStrings.clearChat)),
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
                  fullPhone.isEmpty ? AppStrings.phoneUnavailable : fullPhone,
                  style: GoogleFonts.poppins(color: softColor, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: AppIcons.infoAudioCall,
                      label: AppStrings.actionAudio,
                      onTap: widget.onAudioCall,
                    ),
                    _ActionButton(
                      icon: AppIcons.infoVideoCall,
                      label: AppStrings.actionVideo,
                      onTap: widget.onVideoCall,
                    ),
                    _ActionButton(
                      icon: AppIcons.search,
                      label: AppStrings.search,
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
            icon: AppIcons.infoNotifications,
            title: AppStrings.settingsNotifications,
            onTap: () => _showMessage(context, AppStrings.notificationSettingsMsg),
          ),
          _section(
            icon: AppIcons.infoMediaVisibility,
            title: AppStrings.mediaVisibility,
            onTap: () =>
                _showMessage(context, AppStrings.mediaVisibilitySettingsMsg),
          ),
          _section(
            icon: AppIcons.locked,
            title: AppStrings.encryption,
            subtitle: AppStrings.encryptionSub,
            onTap: () => _showMessage(context, AppStrings.encryptionMsg),
          ),
          StreamBuilder<DatabaseEvent>(
            stream: _disappearStream,
            builder: (context, snap) {
              final v = snap.data?.snapshot.value;
              final ms = v is num ? v.toInt() : 0;
              return _section(
                icon: AppIcons.disappearing,
                title: AppStrings.disappearingTitle,
                subtitle: _disappearLabel(ms),
                onTap: () => _showDisappearSheet(ms),
              );
            },
          ),
          const SizedBox(height: 8),
          _section(
            icon: AppIcons.infoClearChat,
            title: AppStrings.clearChat,
            titleColor: AppColors.dangerRed,
            onTap: widget.onClearChat,
          ),
          _section(
            icon: AppIcons.infoBlock,
            title: AppStrings.blockContact,
            titleColor: AppColors.dangerRed,
            onTap: () => _showMessage(context, AppStrings.blockingNotImplemented),
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
                          AppStrings.mediaLinksDocs,
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
                      const Icon(
                        AppIcons.chevronRight,
                        color: AppColors.textSoft,
                      ),
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