import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

// A short way to read the translated texts in any screen:
//   context.l10n.getStarted
// A screen that reads texts this way rebuilds by itself when the language changes.
extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}