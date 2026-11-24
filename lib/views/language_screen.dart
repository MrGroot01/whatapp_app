import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../providers/locale_provider.dart';

// The list of app languages. Tapping one changes the whole app at once.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // rebuilds when the language changes
    final state = context.watch<LocaleProvider>();
    final current = state.locale?.languageCode; // null = system default

    Widget option({
      required String title,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: Icon(
          selected ? AppIcons.selected : AppIcons.notSelected,
          color: selected ? AppColors.emerald : AppColors.textSoft,
        ),
        onTap: onTap,
      );
    }

    final rows = <Widget>[
      option(
        title: l.systemDefault,
        selected: state.isSystemDefault,
        onTap: () => context.read<LocaleProvider>().setLocale(null),
      ),
      for (final locale in LocaleProvider.supported) ...[
        const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: AppColors.softDivider,
        ),
        option(
          // each language is shown in its own letters
          title: LocaleProvider.nativeNames[locale.languageCode] ??
              locale.languageCode,
          selected: current == locale.languageCode,
          onTap: () => context.read<LocaleProvider>().setLocale(locale),
        ),
      ],
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l.settingsLanguage,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: Text(
              l.chooseLanguageHelp,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Container(
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
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}