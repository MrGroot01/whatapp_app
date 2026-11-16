import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  // give this key to MaterialApp so a notification tap can open a screen
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  // called with the notification's payload when the user taps it
  // (task reminders and other notifications)
  static void Function(String payload)? onNotificationTap;

  // called when the user taps a CHAT notification (payload starts with "chat|")
  static void Function(String payload)? onChatNotificationTap;

  // set when the app was started (from closed) by tapping a notification
  static String? launchPayload;

  static const AndroidNotificationDetails _androidDetails =
  AndroidNotificationDetails(
    'task_reminders',
    'Task reminders',
    channelDescription: 'Reminders for your tasks',
    importance: Importance.high,
    priority: Priority.high,
  );

  // the same message always gets the same number, in every part of the app,
  // so a message never shows two notifications
  static int idFor(String chatId, String messageId) {
    var h = 0x811c9dc5; // FNV-1a
    for (final unit in '$chatId/$messageId'.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    final id = h & 0x3fffffff;
    return id == 0 ? 1 : id;
  }

  static const InitializationSettings _settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  static void _onResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    if (payload.startsWith('chat|')) {
      onChatNotificationTap?.call(payload);
      return;
    }
    onNotificationTap?.call(payload);
  }

  // call once when the app starts

  static Future<void> init() async {
    if (_ready) return;

    try {
      tzdata.initializeTimeZones();

      await _plugin.initialize(
        settings: _settings,
        onDidReceiveNotificationResponse: _onResponse,
      );

      // was the app opened by tapping a notification?
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch != null && launch.didNotificationLaunchApp) {
        launchPayload = launch.notificationResponse?.payload;
      }

      final android = _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final granted =
      await android?.requestNotificationsPermission();

      debugPrint('Notification permission granted: $granted');

      _ready = true;
      debugPrint('Notification service initialized');
    } catch (e, stackTrace) {
      debugPrint('Notification initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Used when a push arrives while the app is closed (background isolate):
  // no permission question, no screen needed.
  static Future<void> initQuiet() async {
    if (_ready) return;

    try {
      await _plugin.initialize(
        settings: _settings,
        onDidReceiveNotificationResponse: _onResponse,
      );
      _ready = true;
    } catch (e) {
      debugPrint('Quiet notification init failed: $e');
    }
  }


  // returns true if the reminder was scheduled
  static Future<bool> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_ready) await init();
    if (!_ready) return false;

    // a reminder in the past cannot be scheduled
    if (!when.isAfter(DateTime.now())) return false;

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: const NotificationDetails(
          android: _androidDetails,
        ),
        // "inexact" needs no special permission; it can be a few minutes late
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      debugPrint('Could not schedule the reminder: $e');
      return false;
    }
  }

  static Future<void> cancel(int id) async {
    if (!_ready || id == 0) return;
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Could not cancel the reminder: $e');
    }
  }

  // a new message from another person: shown at once, tap opens the chat
  static Future<void> showIncomingMessage({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'incoming_messages',
            'Messages',
            channelDescription: 'New messages from your contacts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            // the same message shown twice replaces itself without a new sound
            onlyAlertOnce: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Could not show the message notification: $e');
    }
  }

  static Future<void> showMessageSent({
    required String messageType,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;

    final String body = switch (messageType) {
      'image' => 'Photo sent successfully',
      'file' => 'Document sent successfully',
      'contact' => 'Contact sent successfully',
      _ => 'Message sent successfully',
    };

    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'WhatsApp',
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'message_status',
            'Message status',
            channelDescription:
            'Notifications for successfully sent messages',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Could not show sent notification: $e');
    }
  }
}