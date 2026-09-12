import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en', 'pt', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale.languageCode);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    try {
      return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
          AppLocalizations('es');
    } catch (e) {
      return AppLocalizations('es');
    }
  }
}
