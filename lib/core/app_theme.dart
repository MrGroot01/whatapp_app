import 'package:flutter/material.dart';

import 'app_strings.dart';

// The app name. It comes from AppStrings, so it lives in ONE place.
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
  static const Color softGreen = Color(0xFFE3F1ED);
  static const Color lockedFill = Color(0xFFEFEBE0);
  static const Color wallpaper = Color(0xFFEFEAE0);
  static const Color bubbleMine = Color(0xFFD9F2E7);
  static const Color selectedTile = Color(0xFFD9F2E7);

  // ---------- TEXT ----------
  static const Color textDark = Color(0xFF1C2B2A);
  static const Color textSoft = Color(0xFF6B7A78);
  static const Color bodyText = Color(0xFF4F5E5C);
  static const Color hint = Color(0xFFB8C2C0);

  // ---------- LINES ----------
  static const Color border = Color(0xFFE3DED2);
  static const Color divider = Color(0xFFE9E4D8);
  static const Color softDivider = Color(0xFFEFEBE0);

  // ---------- SHADOW ----------
  static const Color shadow = Color(0x14000000);

  // ---------- TEXT ON THE GREEN HEADER ----------
  static const Color onEmeraldStrong = Color(0xE6FFFFFF);
  static const Color onEmeraldSoft = Color(0xCCFFFFFF);
  static const Color onEmeraldHint = Color(0xB3FFFFFF);

  // ---------- STATUS ----------
  static const Color error = Color(0xFFD94B4B);
  static const Color errorBackground = Color(0xFFFCEAEA);
  static const Color tickRead = Color(0xFF34A7E0);
  static const Color tickGrey = Color(0xFF8A9A98);

  // ---------- CHAT ----------
  static const Color bubbleTheirs = Color(0xFFFFFFFF);
  static const Color quoteOther = Color(0xFFAC44CF);
  static const Color quoteBackground = Color(0x0F000000);
  static const Color sheetHandle = Color(0xFFD5D5D5);
  static const Color buttonDisabled = Color(0xFFBFD8D2);
  static const Color searchFill = Color(0xFFF3F0E8);
  static const Color noticeYellow = Color(0xFFFFF4D6);
  static const Color highlight = Color(0xFFFFE58F);
  static const Color highlightCurrent = Color(0xFFFFB84D);

  // attach menu circles
  static const Color attachDocument = Color(0xFF5F66CD);
  static const Color attachCamera = Color(0xFFD3396D);
  static const Color attachGallery = Color(0xFFAC44CF);
  static const Color attachContact = Color(0xFF0795DC);
  static const Color attachLocation = Color(0xFF1FA855);

  // ---------- PROFILE ----------
  static const Color mutedText = Color(0xFF9AA5A3);
  static const Color buttonDisabledGrey = Color(0xFFB8C2C0);

  // ---------- GROUP INFO ----------
  static const Color plainBackground = Color(0xFFF7F7F7);

  // ---------- GROUP MEMBER PICKER ----------
  static const Color removeBadge = Color(0xFF8A9A98);

  // ---------- STATUS VIEWER ----------
  static const Color statusScrim = Color(0x99000000);
  static const Color statusScrimClear = Color(0x00000000);

  // ---------- STATUS RING ----------
  static const Color statusRingSeen = Color(0xFFB8C2C0);

  // ---------- CONTACT INFO ----------
  static const Color dangerRed = Color(0xFFF44336);

  // ---------- CALL ----------
  static const Color callPanel = Color(0xCC17201D);
  static const Color callButtonBg = Color(0x26FFFFFF);
  static const Color callEndRed = Color(0xFFF0145A);
  static const Color callAvatarShadow = Color(0x55000000);
  static const Color callActiveIcon = Color(0xFF111B21);
  static const Color callGradientTop = Color(0xFF0E4D3E);
  static const Color callGradientBottom = Color(0xFF06140F);
  static const Color callShade = Color(0x99000000);
  static const Color callShadeClear = Color(0x00000000);

  // ---------- CHAT MEDIA ----------
  static const Color filePdf = Color(0xFFE53935);
  static const Color fileDoc = Color(0xFF1E88E5);
  static const Color fileSheet = Color(0xFF43A047);
  static const Color fileSlide = Color(0xFFFB8C00);
  static const Color fileOther = Color(0xFF607D8B);
  static const Color emptyIcon = Color(0xFFCFC9BA);
  static const Color linkBlue = Color(0xFF1E6FD9);

  // ---------- START FLOW ----------
  static const Color shadowMedium = Color(0x33000000);
  static const Color splashShadow = Color(0x44000000);
  static const Color otpBannerBorder = Color(0x800B6B57);

  // ---------- CREATE TASK ----------
  static const Color taskSourceBox = Color(0xFFE7F0EC);
}

// ---------------------------------------------------------------------------
// The colours that CHANGE with the theme (light / dark).
// AppColors above contains the original fixed colour values.
// Screens that follow the selected theme use context.palette.xxx.
// ---------------------------------------------------------------------------
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  // ---------- GENERAL ----------
  final Color background;
  final Color card;
  final Color softGreen;
  final Color lockedFill;
  final Color plainBackground;

  // ---------- TEXT ----------
  final Color textDark;
  final Color textSoft;
  final Color bodyText;
  final Color hint;
  final Color mutedText;

  // ---------- LINES AND SHADOWS ----------
  final Color border;
  final Color divider;
  final Color softDivider;
  final Color shadow;

  // ---------- STATUS ----------
  final Color errorBackground;

  // ---------- BRAND ----------
  final Color accent;

  // ---------- CHAT ----------
  final Color sheetHandle;
  final Color buttonDisabled;
  final Color searchFill;
  final Color bubbleMine;
  final Color bubbleTheirs;
  final Color wallpaper;
  final Color quoteBackground;
  final Color noticeYellow;
  final Color selectedTile;

  // ---------- MEDIA ----------
  final Color emptyIcon;

  // ---------- CREATE TASK ----------
  final Color taskSourceBox;

  const AppPalette({
    required this.background,
    required this.card,
    required this.softGreen,
    required this.lockedFill,
    required this.plainBackground,
    required this.textDark,
    required this.textSoft,
    required this.bodyText,
    required this.hint,
    required this.mutedText,
    required this.border,
    required this.divider,
    required this.softDivider,
    required this.shadow,
    required this.errorBackground,
    required this.accent,
    required this.sheetHandle,
    required this.buttonDisabled,
    required this.searchFill,
    required this.bubbleMine,
    required this.bubbleTheirs,
    required this.wallpaper,
    required this.quoteBackground,
    required this.noticeYellow,
    required this.selectedTile,
    required this.emptyIcon,
    required this.taskSourceBox,
  });

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    card: AppColors.card,
    softGreen: AppColors.softGreen,
    lockedFill: AppColors.lockedFill,
    plainBackground: AppColors.plainBackground,

    textDark: AppColors.textDark,
    textSoft: AppColors.textSoft,
    bodyText: AppColors.bodyText,
    hint: AppColors.hint,
    mutedText: AppColors.mutedText,

    border: AppColors.border,
    divider: AppColors.divider,
    softDivider: AppColors.softDivider,
    shadow: AppColors.shadow,

    errorBackground: AppColors.errorBackground,
    accent: AppColors.emerald,

    sheetHandle: AppColors.sheetHandle,
    buttonDisabled: AppColors.buttonDisabled,
    searchFill: AppColors.searchFill,
    bubbleMine: AppColors.bubbleMine,
    bubbleTheirs: AppColors.bubbleTheirs,
    wallpaper: AppColors.wallpaper,
    quoteBackground: AppColors.quoteBackground,
    noticeYellow: AppColors.noticeYellow,
    selectedTile: AppColors.selectedTile,

    emptyIcon: AppColors.emptyIcon,
    taskSourceBox: AppColors.taskSourceBox,
  );

  // ---------- DARK PALETTE ----------
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0F1715),
    card: Color(0xFF1A2523),
    softGreen: Color(0xFF1F3A33),
    lockedFill: Color(0xFF25322F),
    plainBackground: Color(0xFF151F1D),

    textDark: Color(0xFFE6EEEC),
    textSoft: Color(0xFF9AA8A5),
    bodyText: Color(0xFFC1CCC9),
    hint: Color(0xFF71817D),
    mutedText: Color(0xFF7F8D8A),

    border: Color(0xFF2C3A38),
    divider: Color(0xFF33413D),
    softDivider: Color(0xFF243230),
    shadow: Color(0x33000000),

    errorBackground: Color(0xFF3A1E1E),
    accent: AppColors.emeraldLight,

    sheetHandle: Color(0xFF44534F),
    buttonDisabled: Color(0xFF36564D),
    searchFill: Color(0xFF24312F),
    bubbleMine: Color(0xFF164D3B),
    bubbleTheirs: Color(0xFF26332F),
    wallpaper: Color(0xFF101B18),
    quoteBackground: Color(0x1AFFFFFF),
    noticeYellow: Color(0xFF3C3523),
    selectedTile: Color(0xFF23443A),

    emptyIcon: Color(0xFF66736F),
    taskSourceBox: Color(0xFF1B2B27),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? softGreen,
    Color? lockedFill,
    Color? plainBackground,
    Color? textDark,
    Color? textSoft,
    Color? bodyText,
    Color? hint,
    Color? mutedText,
    Color? border,
    Color? divider,
    Color? softDivider,
    Color? shadow,
    Color? errorBackground,
    Color? accent,
    Color? sheetHandle,
    Color? buttonDisabled,
    Color? searchFill,
    Color? bubbleMine,
    Color? bubbleTheirs,
    Color? wallpaper,
    Color? quoteBackground,
    Color? noticeYellow,
    Color? selectedTile,
    Color? emptyIcon,
    Color? taskSourceBox,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      softGreen: softGreen ?? this.softGreen,
      lockedFill: lockedFill ?? this.lockedFill,
      plainBackground: plainBackground ?? this.plainBackground,

      textDark: textDark ?? this.textDark,
      textSoft: textSoft ?? this.textSoft,
      bodyText: bodyText ?? this.bodyText,
      hint: hint ?? this.hint,
      mutedText: mutedText ?? this.mutedText,

      border: border ?? this.border,
      divider: divider ?? this.divider,
      softDivider: softDivider ?? this.softDivider,
      shadow: shadow ?? this.shadow,

      errorBackground: errorBackground ?? this.errorBackground,
      accent: accent ?? this.accent,

      sheetHandle: sheetHandle ?? this.sheetHandle,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      searchFill: searchFill ?? this.searchFill,
      bubbleMine: bubbleMine ?? this.bubbleMine,
      bubbleTheirs: bubbleTheirs ?? this.bubbleTheirs,
      wallpaper: wallpaper ?? this.wallpaper,
      quoteBackground: quoteBackground ?? this.quoteBackground,
      noticeYellow: noticeYellow ?? this.noticeYellow,
      selectedTile: selectedTile ?? this.selectedTile,

      emptyIcon: emptyIcon ?? this.emptyIcon,
      taskSourceBox: taskSourceBox ?? this.taskSourceBox,
    );
  }

  // ---------- LERP ----------
  // Used by Flutter to smoothly transition between themes.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;

    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppPalette(
      background: mix(background, other.background),
      card: mix(card, other.card),
      softGreen: mix(softGreen, other.softGreen),
      lockedFill: mix(lockedFill, other.lockedFill),
      plainBackground: mix(plainBackground, other.plainBackground),

      textDark: mix(textDark, other.textDark),
      textSoft: mix(textSoft, other.textSoft),
      bodyText: mix(bodyText, other.bodyText),
      hint: mix(hint, other.hint),
      mutedText: mix(mutedText, other.mutedText),

      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      softDivider: mix(softDivider, other.softDivider),
      shadow: mix(shadow, other.shadow),

      errorBackground: mix(errorBackground, other.errorBackground),
      accent: mix(accent, other.accent),

      sheetHandle: mix(sheetHandle, other.sheetHandle),
      buttonDisabled: mix(buttonDisabled, other.buttonDisabled),
      searchFill: mix(searchFill, other.searchFill),
      bubbleMine: mix(bubbleMine, other.bubbleMine),
      bubbleTheirs: mix(bubbleTheirs, other.bubbleTheirs),
      wallpaper: mix(wallpaper, other.wallpaper),
      quoteBackground: mix(quoteBackground, other.quoteBackground),
      noticeYellow: mix(noticeYellow, other.noticeYellow),
      selectedTile: mix(selectedTile, other.selectedTile),

      emptyIcon: mix(emptyIcon, other.emptyIcon),
      taskSourceBox: mix(taskSourceBox, other.taskSourceBox),
    );
  }
}

// Short way to read the palette: context.palette.card
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

class AppTheme {
  static const Color _seed = Color(0xFF25D366);

  // Poppins typography.
  static const TextTheme _textTheme = TextTheme(
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
  );

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      textTheme: _textTheme,
      extensions: const [AppPalette.light],
    );
  }

  static ThemeData dark() {
    const p = AppPalette.dark;

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: p.background,
      cardColor: p.card,
      dividerColor: p.divider,
      textTheme: _textTheme,

      // dialogs, sheets, popup menus and snackbars turn dark by themselves
      dialogTheme: DialogThemeData(backgroundColor: p.card),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        modalBackgroundColor: p.card,
      ),
      popupMenuTheme: PopupMenuThemeData(color: p.card),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.card,
        contentTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: p.textDark,
        ),
      ),

      extensions: const [AppPalette.dark],
    );
  }
}