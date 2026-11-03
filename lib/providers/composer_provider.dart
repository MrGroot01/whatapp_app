import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../message_sync_service.dart';
import '../models/message.dart';
import '../push_queue.dart';

class ComposerProvider extends ChangeNotifier {
  ComposerProvider({
    required this.chatId,
    required this.myUid,
    required this.getDisappearMs,
  });

  final String chatId;
  final String myUid;
  final int Function() getDisappearMs;

  late final DatabaseReference _messagesRef =
  FirebaseDatabase.instance.ref('chats/$chatId/messages');

  Message? _replyingTo; // null = not replying
  File? _draftImageFile;
  String _draftImageName = '';
  bool _hasText = false;
  bool _showEmoji = false;
  bool _uploading = false;
  bool _disposed = false;

  Message? get replyingTo => _replyingTo;
  File? get draftImageFile => _draftImageFile;
  bool get hasText => _hasText;
  bool get showEmoji => _showEmoji;
  bool get uploading => _uploading;

  // ---------- SMALL STATE ----------
  void setHasText(bool value) {
    if (_hasText == value) return;
    _hasText = value;
    _notify();
  }

  void setShowEmoji(bool value) {
    if (_showEmoji == value) return;
    _showEmoji = value;
    _notify();
  }

  void startReply(Message msg) {
    _replyingTo = msg;
    _showEmoji = false;
    _notify();
  }

  void clearReply() {
    if (_replyingTo == null) return;
    _replyingTo = null;
    _notify();
  }

  void setDraftImage(File file, String name) {
    _draftImageFile = file;
    _draftImageName = name;
    _notify();
  }

  void clearDraftImage() {
    _draftImageFile = null;
    _draftImageName = '';
    _notify();
  }

  static String previewOf(Message m) {
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

  Map<String, dynamic> _withReply(Map<String, dynamic> data) {
    final r = _replyingTo;
    if (r != null) {
      data['replyToId'] = r.id;
      data['replyText'] = previewOf(r);
      data['replySenderId'] = r.senderId;
    }
    final disappearMs = getDisappearMs();
    if (disappearMs > 0) data['expireAfterMs'] = disappearMs;
    return data;
  }

  String _chatIdWith(String otherUid) {
    final parts = [myUid, otherUid]..sort();
    return parts.join('_');
  }

  void _resetAfterSend() {
    _hasText = false;
    _replyingTo = null;
    _draftImageFile = null;
    _draftImageName = '';
    _notify();
  }

  // ---------- SEND TEXT / PHOTO ----------
  Future<String?> sendMessage(String text) {
    return _enqueueDraft(
      text,
      failText: 'Could not send the message. Please try again.',
    );
  }

  // ---------- SEND LATER ----------
  Future<String?> scheduleMessage(String text, DateTime when) {
    return _enqueueDraft(
      text,
      sendAt: when,
      failText: 'Could not schedule the message. Please try again.',
    );
  }

  Future<String?> _enqueueDraft(
      String text, {
        DateTime? sendAt,
        required String failText,
      }) async {
    final imageFile = _draftImageFile;
    final imageName = _draftImageName;

    if (text.isEmpty && imageFile == null) return 'Nothing to send';
    if (myUid.isEmpty) return 'Please log in again';

    try {
      final data = <String, dynamic>{
        'text': text,
        'type': imageFile != null ? 'image' : 'text',
      };

      if (imageFile != null) {
        final imageBase64 = base64Encode(await imageFile.readAsBytes());
        if (imageBase64.length > 5 * 1024 * 1024) {
          return 'Image is too large. Please choose a smaller photo.';
        }
        data['imageBase64'] = imageBase64;
        data['fileName'] = imageName;
      }

      if (sendAt == null) {
        await MessageSyncService.enqueue(
          chatId: chatId,
          data: _withReply(data),
        );
      } else {
        await MessageSyncService.enqueue(
          chatId: chatId,
          data: _withReply(data),
          sendAt: sendAt,
        );
      }

      _resetAfterSend();
      return null;
    } catch (e) {
      debugPrint('Send failed: $e');
      return failText;
    }
  }

  // ---------- SHARE A CONTACT ----------
  Future<String?> sendSharedContact({
    required String uid,
    required String name,
    required String phone,
    required String countryCode,
  }) async {
    if (myUid.isEmpty) return 'Please log in again';

    try {
      await MessageSyncService.enqueue(
        chatId: chatId,
        data: _withReply({
          'text': name,
          'type': 'contact',
          'contactUid': uid,
          'contactName': name,
          'contactPhone': phone,
          'contactCountryCode': countryCode,
        }),
      );
      clearReply();
      return null;
    } catch (e) {
      debugPrint('Share contact failed: $e');
      return 'Could not share the contact. Please try again.';
    }
  }

  Future<String?> sendDocument(File file, String name) async {
    if (myUid.isEmpty) return 'Please log in again';
    if (MessageSyncService.connection.value != ConnState.online) {
      return 'Documents can only be sent when you are online.';
    }

    _uploading = true;
    _notify();

    try {
      final message = <String, dynamic>{
        ..._withReply(<String, dynamic>{
          'text': name,
          'type': 'file',
          'fileName': name,
        }),
        'senderId': myUid,
        'timeMs': ServerValue.timestamp,
        'status': 0,
      };

      final after = message.remove('expireAfterMs');
      if (after is num && after > 0) {
        message['expireAtMs'] = MessageSyncService.nowMs() + after.toInt();
      }

      final ref = FirebaseStorage.instance.ref(
        'chats/$chatId/'
            '${DateTime.now().millisecondsSinceEpoch}_$name',
      );

      await ref.putFile(file);
      message['url'] = await ref.getDownloadURL();

      final newMessageRef = _messagesRef.push();
      await newMessageRef.set(message);
      unawaited(
        PushQueue.add(
          chatId: chatId,
          messageId: newMessageRef.key ?? '',
          data: {'type': 'file', 'fileName': name, 'text': name},
        ),
      );

      clearReply();
      return null;
    } catch (e, stackTrace) {
      debugPrint('Attachment save failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return 'Could not save the attachment. Please try again.';
    } finally {
      _uploading = false;
      _notify();
    }
  }

  Future<int> forwardMessage(Message msg, List<String> otherUids) async {
    int done = 0;

    for (final uid in otherUids) {
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
            chatId: _chatIdWith(uid),
            data: data,
          );
        } else {
          // photos and documents are big: they need the internet right now
          data['senderId'] = myUid;
          data['timeMs'] = ServerValue.timestamp;
          data['status'] = 0;
          final forwardRef = FirebaseDatabase.instance
              .ref('chats/${_chatIdWith(uid)}/messages')
              .push();
          await forwardRef.set(data);
          unawaited(
            PushQueue.add(
              chatId: _chatIdWith(uid),
              messageId: forwardRef.key ?? '',
              data: data,
            ),
          );
        }
        done++;
      } catch (e) {
        debugPrint('Forward to $uid failed: $e');
      }
    }
    return done;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}