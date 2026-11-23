import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

// The texts for code that has no screen (providers, services).
// It always follows the language the user chose; LocaleProvider keeps it updated.
//   AppText.l.couldNotDelete
class AppText {
  AppText._();

  static Locale? _chosen; // null = follow the phone

  static void setChosen(Locale? locale) => _chosen = locale;

  // Reads the saved language. A push that arrives while the app is closed
  // runs in its own process, which does not know the choice yet.
  static Future<void> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final code = prefs.getString('app_language');
      _chosen = (code == null || code == 'system') ? null : Locale(code);
    } catch (_) {
      // keep what we have
    }
  }

  // 'en', 'hi', 'kn'... the language in use (for dates and times)
  static String get languageCode {
    final base = _chosen ?? PlatformDispatcher.instance.locale;
    for (final s in AppLocalizations.supportedLocales) {
      if (s.languageCode == base.languageCode) return s.languageCode;
    }
    return 'en';
  }

  static AppLocalizations get l {
    final base = _chosen ?? PlatformDispatcher.instance.locale;
    for (final s in AppLocalizations.supportedLocales) {
      if (s.languageCode == base.languageCode) {
        return lookupAppLocalizations(s);
      }
    }
    return lookupAppLocalizations(const Locale('en'));
  }
}