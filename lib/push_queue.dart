import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

// After a message is sent, the app leaves a small "job" in pushQueue/.
// The push server (push-server/index.js) reads the job and sends the
// notification to the other people in the chat.
class PushQueue {
  PushQueue._();

  static Future<void> add({
    required String chatId,
    required String messageId,
    required Map<dynamic, dynamic> data,
  }) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || chatId.isEmpty) return;

    try {
      await FirebaseDatabase.instance.ref('pushQueue').push().set({
        'chatId': chatId,
        'messageId': messageId,
        'senderId': me,
        'type': (data['type'] ?? 'text').toString(),
        'preview': previewOf(data),
        'timeMs': ServerValue.timestamp,
      });
    } catch (e) {
      // the message itself is already sent; only the push is missed
      debugPrint('Could not queue the push notification: $e');
    }
  }

  // a short text for any kind of message
  static String previewOf(Map<dynamic, dynamic> data) {
    switch ((data['type'] ?? 'text').toString()) {
      case 'image':
        return '📷 Photo';
      case 'file':
        final name = (data['fileName'] ?? data['text'] ?? '').toString();
        return '📄 ${name.isEmpty ? 'Document' : name}';
      case 'contact':
        return '👤 ${data['contactName'] ?? 'Contact'}';
      default:
        final t = (data['text'] ?? '').toString();
        return t.length > 120 ? '${t.substring(0, 120)}…' : t;
    }
  }
}