import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'group_service.dart';
import 'incoming_message_notifier.dart';
import 'notification_service.dart';

// Runs when a push arrives while the app is in the background or closed.
// It must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushService.showFromMessage(message);
}

// Receives the pushes sent by the push server and shows them as notifications.
// Payload of a chat notification:  chat|<chatId>|<1 if group, else 0>|<senderId>
class PushService {
  PushService._();

  static bool _started = false;
  static String? _pendingPayload; // a tap that came before the app was ready

  // call once after the first frame (see main.dart)
  static void init() {
    if (_started) return;
    _started = true;

    NotificationService.onChatNotificationTap = (payload) {
      unawaited(openChat(payload));
    };

    // the app is open: show the push unless I am looking at that chat
    FirebaseMessaging.onMessage.listen((message) {
      final chatId = (message.data['chatId'] ?? '').toString();
      if (chatId.isNotEmpty && IncomingMessageNotifier.activeChatId == chatId) {
        return;
      }
      unawaited(showFromMessage(message));
    });

    // the app was closed and the user tapped a notification to open it
    final launch = NotificationService.launchPayload;
    if (launch != null && launch.startsWith('chat|')) {
      _pendingPayload = launch;
    }
  }

  // turns the data of a push into a notification on this phone
  static Future<void> showFromMessage(RemoteMessage message) async {
    final d = message.data;
    final chatId = (d['chatId'] ?? '').toString();
    if (chatId.isEmpty) return;

    final messageId = (d['messageId'] ?? '').toString();
    final title = (d['title'] ?? '').toString();
    final body = (d['body'] ?? '').toString();
    final isGroup = (d['isGroup'] ?? '0').toString() == '1' ? '1' : '0';
    final senderId = (d['senderId'] ?? '').toString();

    await NotificationService.initQuiet();
    await NotificationService.showIncomingMessage(
      id: NotificationService.idFor(chatId, messageId),
      title: title.isEmpty ? 'New message' : title,
      body: body,
      payload: 'chat|$chatId|$isGroup|$senderId',
    );
  }

  // opens a tap that arrived before the home screen existed
  static void openPendingChat() {
    final payload = _pendingPayload;
    if (payload == null) return;
    _pendingPayload = null;
    unawaited(openChat(payload));
  }

  // opens the chat that a notification belongs to
  static Future<void> openChat(String payload) async {
    final nav = NotificationService.navigatorKey.currentState;
    final me = FirebaseAuth.instance.currentUser?.uid;

    // the app is not ready (or nobody is logged in): try again later
    if (nav == null || me == null) {
      _pendingPayload = payload;
      return;
    }

    final parts = payload.split('|');
    if (parts.length < 4) return;

    final chatId = parts[1];
    final isGroup = parts[2] == '1';
    final senderId = parts[3];

    // I am already looking at this chat
    if (IncomingMessageNotifier.activeChatId == chatId) return;

    final db = FirebaseDatabase.instance;

    try {
      if (isGroup) {
        final snap = await db.ref('groups/$chatId').get();
        final v = snap.value;
        if (v is! Map) return;
        final g = GroupItem.fromMap(chatId, Map<dynamic, dynamic>.from(v));

        nav.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              name: g.name,
              color: GroupService.colorFor(chatId),
              chatKey: chatId,
              isGroup: true,
            ),
          ),
        );
        return;
      }

      if (senderId.isEmpty) return;

      var name = '';
      var phone = '';
      var code = '+91';

      final saved = await db.ref('users/$me/contacts/$senderId').get();
      final sv = saved.value;
      if (sv is Map) {
        name = (sv['name'] ?? '').toString();
        phone = (sv['phone'] ?? '').toString();
        code = (sv['countryCode'] ?? '+91').toString();
      } else {
        final profile = await db.ref('publicProfiles/$senderId').get();
        final pv = profile.value;
        if (pv is Map) {
          name = (pv['name'] ?? '').toString();
          phone = (pv['phone'] ?? '').toString();
          code = (pv['countryCode'] ?? '+91').toString();
        }
      }

      nav.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            name: name.isEmpty ? 'Chat' : name,
            color: GroupService.colorFor(senderId),
            chatKey: '${me}_$senderId',
            phone: phone,
            countryCode: code,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Could not open the chat from the notification: $e');
    }
  }
}