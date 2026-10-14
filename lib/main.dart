import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';

Future<void> main() async {
  // needed before using Firebase
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;

  try {
    // connect to Firebase using the address in firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // Android may already have started the default app: that is fine
    if (e.code != 'duplicate-app') {
      debugPrint('Firebase start failed: ${e.code} ${e.message}');
      startupError = '[${e.code}] ${e.message}';
    }
  } catch (e, stackTrace) {
    debugPrint('Firebase start failed: $e');
    debugPrintStack(stackTrace: stackTrace);
    startupError = e.toString();
  }

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

        // Manually define font sizes for the entire app.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32),
          displayMedium: TextStyle(fontSize: 28),
          displaySmall: TextStyle(fontSize: 24),

          headlineLarge: TextStyle(fontSize: 22),
          headlineMedium: TextStyle(fontSize: 20),
          headlineSmall: TextStyle(fontSize: 18),

          titleLarge: TextStyle(fontSize: 18),
          titleMedium: TextStyle(fontSize: 16),
          titleSmall: TextStyle(fontSize: 14),

          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),

          labelLarge: TextStyle(fontSize: 14),
          labelMedium: TextStyle(fontSize: 12),
          labelSmall: TextStyle(fontSize: 11),
        ),
      ),

      home: startupError == null
          ? const SplashScreen()
          : StartupErrorScreen(message: startupError!),
    );
  }
}

// Shown only when Firebase could not start
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
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Firebase could not start',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SelectableText(message, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}