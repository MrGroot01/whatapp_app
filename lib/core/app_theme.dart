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
  static const Color softGreen = Color(0xFFE3F1ED); // icon circles
  static const Color lockedFill = Color(0xFFEFEBE0); // read-only boxes
  static const Color wallpaper = Color(0xFFEFEAE0); // chat background
  static const Color bubbleMine = Color(0xFFD9F2E7); // my message bubble
  static const Color selectedTile = Color(0xFFD9F2E7); // a selected chat row

  // ---------- TEXT ----------
  static const Color textDark = Color(0xFF1C2B2A);
  static const Color textSoft = Color(0xFF6B7A78);
  static const Color bodyText = Color(0xFF4F5E5C);
  static const Color hint = Color(0xFFB8C2C0);

  // ---------- LINES ----------
  static const Color border = Color(0xFFE3DED2); // text box border
  static const Color divider = Color(0xFFE9E4D8); // list separators
  static const Color softDivider = Color(0xFFEFEBE0); // lines inside cards

  // ---------- SHADOW ----------
  static const Color shadow = Color(0x14000000); // soft card shadow

  // ---------- TEXT ON THE GREEN HEADER ----------
  static const Color onEmeraldStrong = Color(0xE6FFFFFF); // phone number
  static const Color onEmeraldSoft = Color(0xCCFFFFFF); // email
  static const Color onEmeraldHint = Color(0xB3FFFFFF); // search hint

  // ---------- STATUS ----------
  static const Color error = Color(0xFFD94B4B);
  static const Color errorBackground = Color(0xFFFCEAEA);
  static const Color tickRead = Color(0xFF34A7E0);
  static const Color tickGrey = Color(0xFF8A9A98);

  // ---------- CHAT ----------
  static const Color bubbleTheirs = Color(0xFFFFFFFF); // their message bubble
  static const Color quoteOther = Color(0xFFAC44CF); // reply bar of others
  static const Color quoteBackground = Color(0x0F000000); // quote inside bubble
  static const Color sheetHandle = Color(0xFFD5D5D5); // small bar on a sheet
  static const Color buttonDisabled = Color(0xFFBFD8D2); // disabled green button
  static const Color searchFill = Color(0xFFF3F0E8); // search box in a sheet
  static const Color noticeYellow = Color(0xFFFFF4D6); // disappearing notice
  static const Color highlight = Color(0xFFFFE58F); // search match
  static const Color highlightCurrent = Color(0xFFFFB84D); // current match

  // attach menu circles
  static const Color attachDocument = Color(0xFF5F66CD);
  static const Color attachCamera = Color(0xFFD3396D);
  static const Color attachGallery = Color(0xFFAC44CF);
  static const Color attachContact = Color(0xFF0795DC);
  static const Color attachLocation = Color(0xFF1FA855);


  // ---------- PROFILE ----------
  static const Color mutedText = Color(0xFF9AA5A3); // "Not added" text
  static const Color buttonDisabledGrey = Color(0xFFB8C2C0); // disabled button


  // ---------- GROUP INFO ----------
  static const Color plainBackground = Color(0xFFF7F7F7); // group info page


  // ---------- GROUP MEMBER PICKER ----------
  static const Color removeBadge = Color(0xFF8A9A98); // small x on a picked person

  // ---------- STATUS VIEWER ----------
  static const Color statusScrim = Color(0x99000000); // dark shade on a status
  static const Color statusScrimClear = Color(0x00000000); // fades to nothing


  // ---------- STATUS RING ----------
  static const Color statusRingSeen = Color(0xFFB8C2C0); // ring of a seen status


  // ---------- CONTACT INFO ----------
  static const Color dangerRed = Color(0xFFF44336); // Clear chat / Block contact


  // ---------- CALL ----------
  static const Color callPanel = Color(0xCC17201D); // control panel
  static const Color callButtonBg = Color(0x26FFFFFF); // round buttons
  static const Color callEndRed = Color(0xFFF0145A); // end call button
  static const Color callAvatarShadow = Color(0x55000000);
  static const Color callActiveIcon = Color(0xFF111B21); // icon on a white button
  static const Color callGradientTop = Color(0xFF0E4D3E);
  static const Color callGradientBottom = Color(0xFF06140F);
  static const Color callShade = Color(0x99000000); // dark shade over the camera
  static const Color callShadeClear = Color(0x00000000);


  // ---------- CHAT MEDIA ----------
  static const Color filePdf = Color(0xFFE53935);
  static const Color fileDoc = Color(0xFF1E88E5);
  static const Color fileSheet = Color(0xFF43A047);
  static const Color fileSlide = Color(0xFFFB8C00);
  static const Color fileOther = Color(0xFF607D8B);
  static const Color emptyIcon = Color(0xFFCFC9BA); // icon on an empty tab
  static const Color linkBlue = Color(0xFF1E6FD9); // link text


  // ---------- START FLOW ----------
  static const Color shadowMedium = Color(0x33000000); // logo and banner shadow
  static const Color splashShadow = Color(0x44000000); // logo shadow on splash
  static const Color otpBannerBorder = Color(0x800B6B57); // incoming SMS banner



  // ---------- CREATE TASK ----------
  static const Color taskSourceBox = Color(0xFFE7F0EC); // the chat message box

}