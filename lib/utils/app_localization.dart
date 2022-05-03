import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/generated/intl/messages_all.dart'
    as package;
import 'package:multiple_localization/multiple_localization.dart';

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
        package.initializeMessages, locale, (l) => AppLocalizations(l),
        setDefaultLocale: true);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// App localization.
class AppLocalizations {
  /// Delegate.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  final String locale;

  AppLocalizations(this.locale);

  String get title => Intl.message('Multiple localization', name: 'title');

  String get messageFromApp =>
      Intl.message('Default Message from App', name: 'messageFromApp');

  String get messageFromPackageForOverride =>
      Intl.message('Default overrided message from Package',
          name: 'messageFromPackageForOverride');
}

// Other localization, for example from package

class _PackageLocalizationsDelegate
    extends LocalizationsDelegate<PackageLocalizations> {
  const _PackageLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<PackageLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
        package.initializeMessages, locale, (l) => PackageLocalizations(l));
  }

  @override
  bool shouldReload(LocalizationsDelegate<PackageLocalizations> old) => false;
}

/// Package localization.
class PackageLocalizations {
  /// Delegate.
  static const LocalizationsDelegate<PackageLocalizations> delegate =
      _PackageLocalizationsDelegate();

  static PackageLocalizations of(BuildContext context) =>
      Localizations.of<PackageLocalizations>(context, PackageLocalizations)!;

  final String locale;

  PackageLocalizations(this.locale);

  String get messageFromPackage =>
      Intl.message('Default Message from Package', name: 'messageFromPackage');

  String get messageFromPackageForOverride =>
      Intl.message('Default Message from Package for override',
          name: 'messageFromPackageForOverride');
}
