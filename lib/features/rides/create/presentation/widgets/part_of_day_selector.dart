import 'package:flutter/material.dart';

import '../../../domain/part_of_day.dart';

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
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: PartOfDay.values.map((pod) {
        return ChoiceChip(
          label: Text(partOfDayLabel(pod)),
          avatar: Icon(
            partOfDayIcon(pod),
            size: 18,
          ),
          selected: selected == pod,
          onSelected: (_) => onSelected(pod),
        );
      }).toList(),
    );
  }
}
