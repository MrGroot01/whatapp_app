import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'core/app_strings.dart';

import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'services/fcm_service.dart';
import 'services/push_service.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/search_provider.dart';

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

  await NotificationService.init();

  if (startupError == null) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // the saved language is read BEFORE the first screen, so the app opens
  // in the language the user chose last time
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
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
    // when the language changes, this rebuilds the whole app at once
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (_) => AppStrings.appName,

      // ---------- LANGUAGE ----------
      locale: locale, // null = follow the phone
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // a phone language we do not support falls back to English
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final l in supported) {
            if (l.languageCode == deviceLocale.languageCode) return l;
          }
        }
        return const Locale('en');
      },

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
              Text(
                AppLocalizations.of(context).firebaseCouldNotStart,
                style: const TextStyle(
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