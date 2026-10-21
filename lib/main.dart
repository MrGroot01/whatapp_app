import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';


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

  // keep a copy of the database on the phone, so old data shows offline
  // (its own try, so a problem here never shows the error screen)
  try {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(100 * 1024 * 1024);
  } catch (e) {
    debugPrint('Offline copy not enabled: $e');
  }

  // prepare reminders (time zones + notification permission)
  await NotificationService.init();
  runApp(MyApp(startupError: startupError));
}
class MyApp extends StatelessWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 28),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontSize: 24),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 20),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11),
        ),
      ),
      home: startupError == null
          ? const SplashScreen()
          : StartupErrorScreen(message: startupError!),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final String message;

  const StartupErrorScreen({super.key, required this.message});

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
