
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatImageService {
  static final ImagePicker _picker = ImagePicker();

  // Select an image from the camera or gallery.
  static Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 35,
      maxWidth: 700,
      maxHeight: 700,
    );

    return picked == null ? null : File(picked.path);
  }

  // Save the image as Base64 in Realtime Database.
  static Future<void> sendImage({
    required String chatKey,
    required File file,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in again.');
    }

    final bytes = await file.readAsBytes();
    final imageBase64 = base64Encode(bytes);
    final timeMs = DateTime.now().millisecondsSinceEpoch;

    final messagesRef =
    FirebaseDatabase.instance.ref('chats/$chatKey/messages');

    final messageRef = messagesRef.push();

    await messageRef.set({
      'text': file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'Photo',
      'type': 'image',
      'imageBase64': imageBase64,
      'fileName': file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'image.jpg',
      'senderId': user.uid,
      'timeMs': timeMs,
      'status': 0,
    });
  }
}

// Camera and gallery selection.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

// Display a Base64 image in the chat.
class ChatImageBubble extends StatelessWidget {
  final String imageBase64;

  const ChatImageBubble({
    super.key,
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FullImageScreen(imageBase64: imageBase64),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(imageBase64),
          width: 220,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 220,
            height: 120,
            child: Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

// Full-screen image viewer.
class FullImageScreen extends StatelessWidget {
  final String imageBase64;

  const FullImageScreen({
    super.key,
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(
            base64Decode(imageBase64),
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
