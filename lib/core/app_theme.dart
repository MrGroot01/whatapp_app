import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppBrand {
  static const String name = AppStrings.appName;
  static const String tagline = AppStrings.tagline;
}

// Every colour of the app, in one place.
class AppColors {
  // ---------- BRAND ----------
  static const Color emerald = Color(0xFF0B6B57);
  static const Color emeraldLight = Color(0xFF1AA386);
  static const Color gold = Color(0xFFC9A24B);
  static const Color goldLight = Color(0xFFF2D98B);

  // ---------- SURFACES ----------
  static const Color background = Color(0xFFF7F4EE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color softGreen = Color(0xFFE3F1ED); // icon circles
  static const Color lockedFill = Color(0xFFEFEBE0); // read-only boxes
  static const Color wallpaper = Color(0xFFEFEAE0); // chat background
  static const Color bubbleMine = Color(0xFFD9F2E7); // my message bubble

  // ---------- TEXT ----------
  static const Color textDark = Color(0xFF1C2B2A);
  static const Color textSoft = Color(0xFF6B7A78);
  static const Color bodyText = Color(0xFF4F5E5C);
  static const Color hint = Color(0xFFB8C2C0);

  // ---------- LINES ----------
  static const Color border = Color(0xFFE3DED2); // text box border
  static const Color divider = Color(0xFFE9E4D8); // list separators

  // ---------- STATUS ----------
  static const Color error = Color(0xFFD94B4B);
  static const Color errorBackground = Color(0xFFFCEAEA);
  static const Color tickRead = Color(0xFF34A7E0);
  static const Color tickGrey = Color(0xFF8A9A98);
}