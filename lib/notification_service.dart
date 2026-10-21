import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const AndroidNotificationDetails _androidDetails =
  AndroidNotificationDetails(
    'task_reminders',
    'Task reminders',
    channelDescription: 'Reminders for your tasks',
    importance: Importance.high,
    priority: Priority.high,
  );

  // call once when the app starts
  static Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);

      // Android 13+ asks the user for permission to show notifications
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _ready = true;
    } catch (e) {
      debugPrint('Notifications are not available: $e');
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