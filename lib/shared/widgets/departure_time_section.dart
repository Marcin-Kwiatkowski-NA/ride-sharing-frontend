import 'package:flutter/material.dart';

import '../../features/offers/domain/part_of_day.dart';
import 'date_quick_picker.dart';
import 'departure_picker_helpers.dart';
import 'part_of_day_selector.dart';
import 'time_mode_selector.dart';

/// Shared departure date + time section used by both post ride and post seat screens.
///
/// Pure presentation widget — delegates all state changes via callbacks.
class DepartureTimeSection extends StatelessWidget {
  // Date
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? dateError;

  // Time mode
  final bool isApproximate;
  final ValueChanged<bool> onIsApproximateChanged;

  // Exact time
  final TimeOfDay? exactTime;
  final VoidCallback? onPickTime;
  final String? timeError;

  // Approximate
  final PartOfDay? selectedPartOfDay;
  final ValueChanged<PartOfDay>? onPartOfDaySelected;

  const DepartureTimeSection({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.dateError,
    required this.isApproximate,
    required this.onIsApproximateChanged,
    this.exactTime,
    this.onPickTime,
    this.timeError,
    this.selectedPartOfDay,
    this.onPartOfDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date quick picker
        DateQuickPicker(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
          errorText: dateError,
        ),

        // Time mode selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: TimeModeSelector(
            isApproximate: isApproximate,
            onChanged: onIsApproximateChanged,
          ),
        ),

        // Time selection based on mode
        if (isApproximate) ...[
          if (onPartOfDaySelected != null)
            PartOfDaySelector(
              selected: selectedPartOfDay,
              onSelected: onPartOfDaySelected!,
            ),
          if (timeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                timeError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
        ] else ...[
          if (onPickTime != null) ...[
            Text(
              'Time of departure',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Material(
              color: colorScheme.surfaceContainerLow,
              shape: StadiumBorder(
                side: BorderSide(
                  color: timeError != null
                      ? colorScheme.error
                      : colorScheme.outlineVariant,
                ),
              ),
              child: InkWell(
                onTap: onPickTime,
                customBorder: const StadiumBorder(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: kMinInteractiveDimension,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          exactTime != null
                              ? formatPickedTime(exactTime!)
                              : 'Set time',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: exactTime != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (timeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  timeError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }
}
