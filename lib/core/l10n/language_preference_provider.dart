import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_language.dart';
import 'shared_preferences_provider.dart';

part 'language_preference_provider.g.dart';

/// Synchronous language preference backed by [SharedPreferences].
///
/// Synchronous because [SharedPreferences] is pre-loaded in `main()` and
/// injected via [ProviderScope.overrides], eliminating any async loading gap
/// (no locale flicker on startup).
@Riverpod(keepAlive: true)
class LanguagePreference extends _$LanguagePreference {
  static const _key = 'app_language_v1';

  @override
  AppLanguage build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    return AppLanguage.values.firstWhere(
      (e) => e.name == stored,
      orElse: () => AppLanguage.system,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, language.name);
    state = language;
  }
}
