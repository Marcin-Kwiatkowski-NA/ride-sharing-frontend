import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../features/offers/domain/part_of_day.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shows a bottom sheet for picking departure time.
///
/// Two sections:
/// 1. "Pick exact time" — opens [showTimePicker], calls [onExactTimePicked].
/// 2. "Or choose time of day" — [PartOfDay] chips, calls [onPartOfDayPicked].
Future<void> showTimePickerSheet(
  BuildContext context, {
  TimeOfDay? currentTime,
  PartOfDay? currentPartOfDay,
  required ValueChanged<TimeOfDay> onExactTimePicked,
  required ValueChanged<PartOfDay> onPartOfDayPicked,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _TimePickerSheetContent(
      currentTime: currentTime,
      currentPartOfDay: currentPartOfDay,
      onExactTimePicked: onExactTimePicked,
      onPartOfDayPicked: onPartOfDayPicked,
    ),
  );
}

class _TimePickerSheetContent extends StatelessWidget {
  final TimeOfDay? currentTime;
  final PartOfDay? currentPartOfDay;
  final ValueChanged<TimeOfDay> onExactTimePicked;
  final ValueChanged<PartOfDay> onPartOfDayPicked;

  const _TimePickerSheetContent({
    this.currentTime,
    this.currentPartOfDay,
    required this.onExactTimePicked,
    required this.onPartOfDayPicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exact time row
            Material(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _pickExactTime(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentTime != null
                              ? '${currentTime!.hour.toString().padLeft(2, '0')}:${currentTime!.minute.toString().padLeft(2, '0')}'
                              : l10n.selectDepartureTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider with label
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            // Part of day chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PartOfDay.values.map((pod) {
                final isSelected = currentPartOfDay == pod;
                return ChoiceChip(
                  label: Text(_partOfDayLabel(pod, l10n)),
                  avatar: Icon(partOfDayIcon(pod), size: 18),
                  selected: isSelected,
                  onSelected: (_) {
                    onPartOfDayPicked(pod);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExactTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? TimeOfDay.now(),
    );
    if (picked != null && context.mounted) {
      onExactTimePicked(picked);
      Navigator.of(context).pop();
    }
  }
}

String _partOfDayLabel(PartOfDay pod, AppLocalizations l10n) => switch (pod) {
      PartOfDay.morning => l10n.partOfDayMorning,
      PartOfDay.afternoon => l10n.partOfDayAfternoon,
      PartOfDay.evening => l10n.partOfDayEvening,
      PartOfDay.night => l10n.partOfDayNight,
    };
