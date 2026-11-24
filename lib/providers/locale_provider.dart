import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_text.dart';

// Holds the language of the app. When it changes, MaterialApp rebuilds and
// every screen shows the new language at once (no restart).
class LocaleProvider extends ChangeNotifier {
  static const String _key = 'app_language';
  static const String _system = 'system';

  // the languages of the app (English first: it is the fallback)
  static const List<Locale> supported = [
    Locale('en'),
    Locale('kn'),
    Locale('hi'),
    Locale('te'),
    Locale('ta'),
    Locale('ml'),
  ];

  // each language is always shown in its own letters
  static const Map<String, String> nativeNames = {
    'en': 'English',
    'kn': 'ಕನ್ನಡ',
    'hi': 'हिन्दी',
    'te': 'తెలుగు',
    'ta': 'தமிழ்',
    'ml': 'മലയാളം',
  };

  Locale? _locale; // null = follow the phone's language

  Locale? get locale => _locale;
  bool get isSystemDefault => _locale == null;

  // read the saved choice (call once, before runApp)
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locale = _fromCode(prefs.getString(_key));
    } catch (e) {
      debugPrint('[LocaleProvider] Could not read the saved language: $e');
    }
    AppText.setChosen(_locale);
  }

  Locale? _fromCode(String? code) {
    if (code == null || code == _system) return null;
    for (final l in supported) {
      if (l.languageCode == code) return l;
    }
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;

    _locale = locale;
    AppText.setChosen(locale);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale?.languageCode ?? _system);
    } catch (e) {
      debugPrint('[LocaleProvider] Could not save the language: $e');
    }
  }
}