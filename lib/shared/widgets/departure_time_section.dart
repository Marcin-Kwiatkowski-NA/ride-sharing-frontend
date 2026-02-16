import 'package:flutter/material.dart';

import '../../features/offers/domain/part_of_day.dart';
import 'date_quick_picker.dart';
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
  final TextEditingController? timeController;
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
    this.timeController,
    this.onPickTime,
    this.timeError,
    this.selectedPartOfDay,
    this.onPartOfDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ] else ...[
          if (timeController != null && onPickTime != null)
            GestureDetector(
              onTap: onPickTime,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time of departure',
                    prefixIcon: const Icon(Icons.access_time_outlined),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    errorText: timeError,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
