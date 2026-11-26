import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../providers/account_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import 'add_contact_action.dart';
import 'language_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

// One row in the settings list
class SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String id; // '' = no action yet

  const SettingsItem(this.icon, this.title, this.subtitle, {this.id = ''});
}

// The provider is created here, inside the screen, so it stops when the
// screen closes and never shows an old account's data after a new login.
class SettingsScreen extends StatelessWidget {
  final String email;

  const SettingsScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountProvider(fallbackEmail: email),
      child: _SettingsView(email: email),
    );
  }
}

class _SettingsView extends StatefulWidget {
  final String email;

  const _SettingsView({required this.email});

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  // only the search box of this screen lives here (pure UI state)
  final searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    // the provider tells the screen when the picture was saved
    context.read<AccountProvider>().onPhotoUpdated = () {
      if (mounted) _showMessage(context.l10n.profilePhotoUpdated);
    };
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // the camera button: the provider does the work, we only show the result
  Future<void> _changePhoto() async {
    final error = await context.read<AccountProvider>().changePhoto();
    if (error != null) _showMessage(error);
  }

  // open the Profile screen (tap on the header)
  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(email: widget.email),
      ),
    );
  }

  // open the list of app languages
  void _openLanguage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  }

  // the action of a row (null = the row does nothing yet)
  VoidCallback? _actionFor(SettingsItem item) {
    if (item.id == 'language') return _openLanguage;
    if (item.id == 'theme') return _chooseTheme;
    return null;
  }

  // ---------- THEME ----------
  // the name shown under the "Theme" row and in the dialog
  String _themeName(ThemeMode mode) {
    final l = context.l10n;
    if (mode == ThemeMode.light) return l.themeLight;
    if (mode == ThemeMode.dark) return l.themeDark;
    return l.systemDefault;
  }

  // the dialog with 3 options; the tick shows the one in use
  Future<void> _chooseTheme() async {
    final l = context.l10n;
    final p = context.palette;
    final themeProvider = context.read<ThemeProvider>();
    final current = themeProvider.mode;

    final chosen = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) {
        Widget option(ThemeMode mode, IconData icon) {
          final selected = mode == current;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Icon(
              icon,
              color: selected ? p.accent : p.textSoft,
            ),
            title: Text(
              _themeName(mode),
              style: TextStyle(
                color: p.textDark,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: selected
                ? Icon(Icons.check_circle, color: p.accent)
                : null,
            onTap: () => Navigator.pop(dialogContext, mode),
          );
        }

        return AlertDialog(
          backgroundColor: p.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l.chooseTheme,
            style: TextStyle(
              color: p.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(ThemeMode.light, Icons.light_mode_outlined),
              option(ThemeMode.dark, Icons.dark_mode_outlined),
              option(ThemeMode.system, Icons.brightness_6_outlined),
            ],
          ),
        );
      },
    );

    // null = the user closed the dialog without choosing
    if (chosen == null) return;
    await themeProvider.setMode(chosen);
  }

  // ---------- LOGOUT ----------
  Future<void> _confirmLogout() async {
    final l = context.l10n;
    final p = context.palette;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l.logOutTitle,
          style: TextStyle(
            color: p.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l.logOutBody,
          style: TextStyle(color: p.textSoft, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l.cancel,
              style: TextStyle(color: p.textSoft, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l.logOut,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    // push token removed + signed out (the provider does both, in order)
    await context.read<AccountProvider>().logout();
    if (!mounted) return;

    // go to the Login page and remove all old pages
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  // ---------- SMALL UI PIECES ----------
  Widget _initialAvatar(String displayName) {
    return Center(
      child: Text(
        displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // the shared picture, then my phone's copy, then the first letter
  Widget _buildProfileAvatar(AccountProvider account) {
    final name = account.displayName;

    Widget localOrInitial() {
      final file = account.localImage;
      if (file != null) {
        return ClipOval(
          child: Image.file(
            file,
            width: 112,
            height: 112,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _initialAvatar(name),
          ),
        );
      }
      return _initialAvatar(name);
    }

    final bytes = account.photoBytes;
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => localOrInitial(),
        ),
      );
    }
    return localOrInitial();
  }

  // One card with rounded corners and a soft shadow
  Widget whiteCard({required Widget child}) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // One settings row: soft green icon box, title, subtitle
  // (onTap is optional: rows without an action do nothing, as before)
  Widget settingsRow(SettingsItem item, {VoidCallback? onTap}) {
    final p = context.palette;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: p.softGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: p.accent, size: 24),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: p.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(color: p.textSoft, fontSize: 13.5),
      ),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    // rebuilds whenever the provider changes (name, picture, uploading...)
    final account = context.watch<AccountProvider>();

    // rebuilds when the app language changes
    final language = context.watch<LocaleProvider>();
    final languageName = language.isSystemDefault
        ? l.systemDefault
        : (LocaleProvider.nativeNames[language.locale!.languageCode] ?? '');

    // rebuilds when the theme changes
    final themeMode = context.watch<ThemeProvider>().mode;

    final displayName = account.displayName;
    final fullPhone = account.fullPhone;

    // the rows of the list, in the language in use
    final items = <SettingsItem>[
      SettingsItem(
        AppIcons.settingsAccount,
        l.settingsAccount,
        l.settingsAccountSub,
      ),
      SettingsItem(
        AppIcons.settingsPrivacy,
        l.settingsPrivacy,
        l.settingsPrivacySub,
      ),
      SettingsItem(
        AppIcons.settingsChats,
        l.chats,
        l.settingsChatsSub,
      ),
      SettingsItem(
        AppIcons.settingsNotifications,
        l.settingsNotifications,
        l.settingsNotificationsSub,
      ),
      SettingsItem(
        AppIcons.settingsStorage,
        l.settingsStorage,
        l.settingsStorageSub,
      ),
      SettingsItem(
        Icons.brightness_6_outlined,
        l.settingsTheme,
        _themeName(themeMode),
        id: 'theme',
      ),
      SettingsItem(
        AppIcons.settingsLanguage,
        l.settingsLanguage,
        languageName,
        id: 'language',
      ),
      SettingsItem(
        AppIcons.settingsHelp,
        l.settingsHelp,
        l.settingsHelpSub,
      ),
    ];

    // keep only the rows that match the search text
    final shownItems = items
        .where((i) => i.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: p.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---------- GREEN HEADER: back arrow, picture, name, phone, email ----------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emerald, AppColors.emeraldLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(AppIcons.back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // BIG ROUND PICTURE with a white ring and a gold camera button
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _openProfile,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: AppColors.gold,
                            child: _buildProfileAvatar(account),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: account.uploadingPhoto ? null : _changePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.gold,
                              child: account.uploadingPhoto
                                  ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(
                                AppIcons.camera,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // NAME, PHONE and EMAIL (tap = open the Profile screen)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openProfile,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (fullPhone != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              fullPhone,
                              style: const TextStyle(
                                color: AppColors.onEmeraldStrong,
                                fontSize: 15,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            account.email,
                            style: const TextStyle(
                              color: AppColors.onEmeraldSoft,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ---------- BELOW THE HEADER ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SEARCH BAR
                TextField(
                  controller: searchController,
                  style: TextStyle(
                    color: p.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: p.accent,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l.searchSettings,
                    hintStyle: TextStyle(
                      color: p.textSoft,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(AppIcons.search, color: p.textSoft),
                    filled: true,
                    fillColor: p.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: p.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: p.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: p.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ADD NEW CONTACT (same shared code as the Home screen)
                whiteCard(
                  child: settingsRow(
                    SettingsItem(
                      AppIcons.addContact,
                      l.addNewContact,
                      l.addNewContactSub,
                    ),
                    onTap: () => openAddContact(context),
                  ),
                ),
                const SizedBox(height: 20),

                // SETTINGS ROWS (inside one card)
                if (shownItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l.noSettingsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.textSoft,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  whiteCard(
                    child: Column(
                      children: [
                        for (int i = 0; i < shownItems.length; i++) ...[
                          settingsRow(
                            shownItems[i],
                            onTap: _actionFor(shownItems[i]),
                          ),
                          if (i != shownItems.length - 1)
                            Divider(
                              height: 1,
                              indent: 76,
                              endIndent: 16,
                              color: p.softDivider,
                            ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // LOG OUT (always the last card)
                whiteCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: p.errorBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        AppIcons.logout,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      l.logOut,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: _confirmLogout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}