import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/app_locale_provider.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/language_preference_provider.dart';

/// Language selector with three radio options: System, English, Polski.
///
/// When "System" is selected, shows the resolved effective language
/// as a subtitle (e.g. "Currently using: Polski").
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languagePreferenceProvider);
    final effectiveLocale = ref.watch(effectiveLocaleProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final effectiveName = effectiveLocale.languageCode == 'pl'
        ? l10n.languagePolish
        : l10n.languageEnglish;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RadioGroup<AppLanguage>(
          groupValue: selected,
          onChanged: (value) => _setLanguage(ref, value!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  l10n.settingsLanguage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RadioListTile<AppLanguage>(
                title: Text(l10n.languageSystem),
                subtitle: selected == AppLanguage.system
                    ? Text(l10n.effectiveLanguage(effectiveName))
                    : null,
                value: AppLanguage.system,
              ),
              RadioListTile<AppLanguage>(
                title: Text(l10n.languageEnglish),
                value: AppLanguage.en,
              ),
              RadioListTile<AppLanguage>(
                title: Text(l10n.languagePolish),
                value: AppLanguage.pl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setLanguage(WidgetRef ref, AppLanguage language) {
    ref.read(languagePreferenceProvider.notifier).setLanguage(language);
  }
}
