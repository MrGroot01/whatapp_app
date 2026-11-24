import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../providers/account_provider.dart';
import '../providers/locale_provider.dart';
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
    return null;
  }

  // ---------- LOGOUT ----------
  Future<void> _confirmLogout() async {
    final l = context.l10n;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l.logOutTitle,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l.logOutBody,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppColors.textSoft, fontSize: 16),
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

  // One white card with rounded corners and a soft shadow
  Widget whiteCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // One settings row: soft green icon box, title, subtitle
  // (onTap is optional: rows without an action do nothing, as before)
  Widget settingsRow(SettingsItem item, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.softGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: AppColors.emerald, size: 24),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 13.5),
      ),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // rebuilds whenever the provider changes (name, picture, uploading...)
    final account = context.watch<AccountProvider>();

    // rebuilds when the app language changes
    final language = context.watch<LocaleProvider>();
    final languageName = language.isSystemDefault
        ? l.systemDefault
        : (LocaleProvider.nativeNames[language.locale!.languageCode] ?? '');

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
      backgroundColor: AppColors.background,
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
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: AppColors.emerald,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l.searchSettings,
                    hintStyle: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 16,
                    ),
                    prefixIcon:
                    const Icon(AppIcons.search, color: AppColors.textSoft),
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppColors.emerald),
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

                // SETTINGS ROWS (inside one white card)
                if (shownItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l.noSettingsFound,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSoft,
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
                            const Divider(
                              height: 1,
                              indent: 76,
                              endIndent: 16,
                              color: AppColors.softDivider,
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
                        color: AppColors.errorBackground,
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