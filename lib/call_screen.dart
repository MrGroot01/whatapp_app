import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final Color color;
  final String phone; // without country code
  final String countryCode; // e.g. +91
  final bool video; // true = video call screen

  const CallScreen({
    super.key,
    required this.name,
    required this.color,
    this.phone = '',
    this.countryCode = '+91',
    this.video = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const Color _panel = Color(0xFF161D22);
  static const Color _button = Color(0xFF2A3236);
  static const Color _red = Color(0xFFF0154F);

  late bool isVideo = widget.video;
  bool muted = false;
  bool speaker = false;
  bool ringing = false;
  Timer? _ringTimer;

  @override
  void initState() {
    super.initState();
    // "Calling..." turns into "Ringing..." after 3 seconds
    _ringTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => ringing = true);
    });
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    super.dispose();
  }

  // ---------- TEXTS ----------
  String get statusText {
    if (ringing) return 'Ringing...';
    return isVideo ? 'Video calling...' : 'Calling...';
  }

  String get displayNumber {
    final p = widget.phone.replaceAll(RegExp(r'\s'), '');
    if (p.isEmpty) return '';
    if (p.length == 10) {
      return '${widget.countryCode} ${p.substring(0, 5)} ${p.substring(5)}';
    }
    return '${widget.countryCode} $p';
  }

  // ---------- ACTIONS ----------
  void snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 15)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // a normal phone call through the phone's dialer
  Future<void> openDialer() async {
    if (widget.phone.isEmpty) {
      snack('No phone number saved for ${widget.name}');
      return;
    }
    try {
      final number = '${widget.countryCode}${widget.phone}';
      final ok = await launchUrl(Uri(scheme: 'tel', path: number));
      if (!ok) snack('Could not open the dialer');
    } catch (e) {
      snack('Could not open the dialer');
    }
  }

  void showMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.white),
              title: Text(
                'Call with the phone dialer',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                openDialer();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------- UI PIECES ----------
  // small round button in the top corners
  Widget cornerButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  // big round button with a label under it
  Widget roundButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    bool red = false,
  }) {
    final bg = red ? _red : (active ? Colors.white : _button);
    final fg = red ? Colors.white : (active ? Colors.black : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 30),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget buildAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final number = displayNumber;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF08130F),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F3D34), Color(0xFF08130F)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ---------- TOP: minimize, name + number + status, add ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cornerButton(
                        Icons.close_fullscreen_rounded,
                            () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            children: [
                              Text(
                                widget.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (number.isNotEmpty)
                                Text(
                                  number,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xCCFFFFFF),
                                    fontSize: 16,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: GoogleFonts.poppins(
                                  color: const Color(0x99FFFFFF),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      cornerButton(
                        Icons.person_add_alt_1_rounded,
                            () => snack('Group calls are coming soon'),
                      ),
                    ],
                  ),
                ),

                // ---------- MIDDLE: big picture ----------
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size =
                      (constraints.maxHeight - 24).clamp(90.0, 190.0);
                      return Center(child: buildAvatar(size.toDouble()));
                    },
                  ),
                ),

                // ---------- BOTTOM: the 6 buttons ----------
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          roundButton(
                            icon: Icons.volume_up_rounded,
                            label: 'Speaker',
                            active: speaker,
                            onTap: () => setState(() => speaker = !speaker),
                          ),
                          roundButton(
                            icon: isVideo
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                            label: 'Video',
                            active: isVideo,
                            onTap: () => setState(() => isVideo = !isVideo),
                          ),
                          roundButton(
                            icon: Icons.mic_off_rounded,
                            label: 'Mute',
                            active: muted,
                            onTap: () => setState(() => muted = !muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          roundButton(
                            icon: Icons.more_horiz_rounded,
                            label: 'More',
                            onTap: showMore,
                          ),
                          roundButton(
                            icon: Icons.file_upload_outlined,
                            label: 'Share',
                            onTap: () => snack('Screen sharing is coming soon'),
                          ),
                          roundButton(
                            icon: Icons.call_end_rounded,
                            label: 'End',
                            red: true,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
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
}