import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_language.dart';
import 'language_preference_provider.dart';

part 'app_locale_provider.g.dart';

/// Locale for [MaterialApp.locale].
///
/// Returns `null` when the user chose [AppLanguage.system], letting Flutter
/// resolve from the device locale bounded by `supportedLocales`.
@riverpod
Locale? appLocale(Ref ref) {
  final lang = ref.watch(languagePreferenceProvider);
  return appLanguageToLocale(lang);
}

/// The effective locale currently in use.
///
/// Resolves "system" mode to the actual locale Flutter would pick, following
/// the same `supportedLocales` matching rules (exact languageCode match,
/// else first supported locale).
///
/// Use this when you need the resolved locale outside the widget tree
/// (e.g. settings subtitle).
@riverpod
Locale effectiveLocale(Ref ref) {
  final appLoc = ref.watch(appLocaleProvider);
  if (appLoc != null) return appLoc;

  // System mode: resolve from platform locale against supported locales.
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  const supported = [Locale('en'), Locale('pl')];
  return supported.firstWhere(
    (s) => s.languageCode == deviceLocale.languageCode,
    orElse: () => supported.first,
  );
}
