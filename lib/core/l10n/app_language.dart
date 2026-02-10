import 'dart:ui';

/// Supported language preferences.
///
/// [system] defers to the platform locale; [en] and [pl] force a specific locale.
enum AppLanguage { system, en, pl }

/// Convert [AppLanguage] to a [Locale], or `null` for system
/// (which means "let Flutter resolve from the device locale").
Locale? appLanguageToLocale(AppLanguage language) => switch (language) {
  AppLanguage.system => null,
  AppLanguage.en => const Locale('en'),
  AppLanguage.pl => const Locale('pl'),
};
