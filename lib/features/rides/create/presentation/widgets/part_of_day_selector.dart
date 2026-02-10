import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../offers/domain/part_of_day.dart';

/// Material 3 Wrap + ChoiceChip selector for part-of-day selection.
class PartOfDaySelector extends StatelessWidget {
  final PartOfDay? selected;
  final ValueChanged<PartOfDay> onSelected;

  const PartOfDaySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: PartOfDay.values.map((pod) {
        return ChoiceChip(
          label: Text(_partOfDayLabel(pod, l10n)),
          avatar: Icon(partOfDayIcon(pod), size: 18),
          selected: selected == pod,
          onSelected: (_) => onSelected(pod),
        );
      }).toList(),
    );
  }
}

String _partOfDayLabel(PartOfDay pod, AppLocalizations l10n) =>
    switch (pod) {
      PartOfDay.morning => l10n.partOfDayMorning,
      PartOfDay.afternoon => l10n.partOfDayAfternoon,
      PartOfDay.evening => l10n.partOfDayEvening,
      PartOfDay.night => l10n.partOfDayNight,
    };
