import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'app_theme_mode';

  static const String _light = 'light';
  static const String _dark = 'dark';
  static const String _system = 'system';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  bool get isSystemDefault => _mode == ThemeMode.system;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _mode = _fromText(prefs.getString(_key));
    } catch (e) {
      debugPrint('[ThemeProvider] Could not read the saved theme: $e');
    }
  }

  ThemeMode _fromText(String? text) {
    if (text == _light) return ThemeMode.light;
    if (text == _dark) return ThemeMode.dark;
    return ThemeMode.system;
  }

  String _toText(ThemeMode mode) {
    if (mode == ThemeMode.light) return _light;
    if (mode == ThemeMode.dark) return _dark;
    return _system;
  }
  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _toText(mode));
    } catch (e) {
      debugPrint('[ThemeProvider] Could not save the theme: $e');
    }
  }
}