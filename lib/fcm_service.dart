
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<String>? _tokenSubscription;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'FCM permission: ${settings.authorizationStatus}',
      );

      // Register the token whenever a user signs in.
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((user) {
            if (user != null) {
              unawaited(_registerToken(user.uid));
            }
          });

      // Update the token if Firebase refreshes it.
      _tokenSubscription =
          _messaging.onTokenRefresh.listen((token) {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              unawaited(_saveToken(user.uid, token));
            }
          });

      // Also handle a user who is already signed in.
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await _registerToken(user.uid);
      }
    } catch (e, stackTrace) {
      debugPrint('FCM initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _initialized = false;
    }
  }

  static Future<void> _registerToken(String uid) async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is not available yet.');
        return;
      }

      // Don't save a token under a different account if the user
      // switches accounts while getToken() is running.
      if (FirebaseAuth.instance.currentUser?.uid != uid) return;

      await _saveToken(uid, token);

      debugPrint('FCM token saved for user: $uid');
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  static Future<void> _saveToken(
      String uid,
      String token,
      ) async {
    // Use the token itself as the key, avoiding hash collisions.
    final tokenKey = Uri.encodeComponent(token);

    await FirebaseDatabase.instance
        .ref('users/$uid/fcmTokens/$tokenKey')
        .set({
      'token': token,
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();

    _authSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }
}
