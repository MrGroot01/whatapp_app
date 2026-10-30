import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'fcm_service.dart';
import 'push_service.dart';
import 'package:provider/provider.dart';
import 'search_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    // Ignore a duplicate default app; report other Firebase startup errors.
    if (e.code != 'duplicate-app') {
      debugPrint('Firebase start failed: ${e.code} ${e.message}');
      startupError = '[${e.code}] ${e.message}';
    }
  } catch (e, stackTrace) {
    debugPrint('Firebase start failed: $e');
    debugPrintStack(stackTrace: stackTrace);
    startupError = e.toString();
  }

  // Keep a copy of the database on the phone for offline access.
  if (startupError == null) {
    try {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(
        100 * 1024 * 1024,
      );
    } catch (e) {
      debugPrint('Offline copy not enabled: $e');
    }
  }

  // Prepare existing reminders and local notifications.
  await NotificationService.init();

  // Pushes that arrive while the app is closed or in the background.
  if (startupError == null) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: MyApp(startupError: startupError),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize FCM after the first frame.
    // FcmService.init() checks for a signed-in user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startupError == null) {
        FcmService.init();
        PushService.init(); // shows pushes and opens the chat on tap
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25D366),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
          ),
        ),
      ),
      home: widget.startupError == null
          ? const SplashScreen()
          : StartupErrorScreen(message: widget.startupError!),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final String message;

  const StartupErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase could not start',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}