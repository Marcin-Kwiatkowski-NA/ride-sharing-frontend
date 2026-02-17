import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vamigo/core/l10n/app_language.dart';
import 'package:vamigo/core/l10n/language_preference_provider.dart';
import 'package:vamigo/core/l10n/shared_preferences_provider.dart';

void main() {
  group('LanguagePreference', () {
    late ProviderContainer container;

    Future<ProviderContainer> buildContainer({
      Map<String, Object> initialValues = const {},
    }) async {
      SharedPreferences.setMockInitialValues(initialValues);
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    }

    tearDown(() => container.dispose());

    test('defaults to AppLanguage.system with no stored value', () async {
      container = await buildContainer();

      final lang = container.read(languagePreferenceProvider);

      expect(lang, AppLanguage.system);
    });

    test('restores persisted language choice', () async {
      container = await buildContainer(
        initialValues: {'app_language_v1': 'pl'},
      );

      final lang = container.read(languagePreferenceProvider);

      expect(lang, AppLanguage.pl);
    });

    test('setLanguage persists and updates state', () async {
      container = await buildContainer();

      await container
          .read(languagePreferenceProvider.notifier)
          .setLanguage(AppLanguage.en);

      expect(container.read(languagePreferenceProvider), AppLanguage.en);

      // Verify persisted
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('app_language_v1'), 'en');
    });

    test('handles unknown stored value gracefully', () async {
      container = await buildContainer(
        initialValues: {'app_language_v1': 'unknown_lang'},
      );

      final lang = container.read(languagePreferenceProvider);

      expect(lang, AppLanguage.system);
    });
  });
}
