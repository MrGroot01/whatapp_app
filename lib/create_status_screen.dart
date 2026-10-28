import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'status_service.dart';

// image == null  -> a text status on a coloured background
// image != null  -> a photo status with an optional caption
class CreateStatusScreen extends StatefulWidget {
  final File? image;

  const CreateStatusScreen({super.key, this.image});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _caption = TextEditingController();
  int _bg = 0;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    _caption.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    if (_sending) return;

    final image = widget.image;
    final text = _text.text.trim();

    if (image == null && text.isEmpty) {
      _snack('Type something first');
      return;
    }

    setState(() => _sending = true);

    try {
      if (image != null) {
        await StatusService.postImage(image, _caption.text.trim());
      } else {
        await StatusService.postText(
          text,
          StatusService.backgrounds[_bg].toARGB32(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on TimeoutException {
      // offline: Firebase keeps the write and sends it when the internet is back
      if (!mounted) return;
      _snack('No internet. Your status will post when you are back online.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _sendButton() {
    return FloatingActionButton(
      heroTag: 'status_send',
      backgroundColor: AppColors.emerald,
      foregroundColor: Colors.white,
      onPressed: _sending ? null : _send,
      child: _sending
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.send_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;

    // ---------- PHOTO ----------
    if (image != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(child: Image.file(image, fit: BoxFit.contain)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _caption,
                          maxLength: 300,
                          minLines: 1,
                          maxLines: 3,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add a caption...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _sendButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---------- TEXT ----------
    return Scaffold(
      backgroundColor: StatusService.backgrounds[_bg],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          IconButton(
            tooltip: 'Change colour',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => setState(
                  () => _bg = (_bg + 1) % StatusService.backgrounds.length,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: TextField(
              controller: _text,
              autofocus: true,
              maxLength: 700,
              maxLines: null,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              decoration: const InputDecoration(
                hintText: 'Type a status',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _sendButton(),
    );
  }
}