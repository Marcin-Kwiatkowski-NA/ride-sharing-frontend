import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Quick-pick date selector with [Today], [Tomorrow], [Pick date...] chips.
///
/// ~90% of rides are today or tomorrow — this eliminates unnecessary taps.
class DateQuickPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? errorText;

  const DateQuickPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final isToday = selectedDate != null &&
        selectedDate!.year == today.year &&
        selectedDate!.month == today.month &&
        selectedDate!.day == today.day;

    final isTomorrow = selectedDate != null &&
        selectedDate!.year == tomorrow.year &&
        selectedDate!.month == tomorrow.month &&
        selectedDate!.day == tomorrow.day;

    final isCustom = selectedDate != null && !isToday && !isTomorrow;

    final customLabel = isCustom
        ? DateFormat('MMM d').format(selectedDate!)
        : 'Pick date...';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('Today'),
                selected: isToday,
                onSelected: (_) => onDateSelected(today),
              ),
              ChoiceChip(
                label: const Text('Tomorrow'),
                selected: isTomorrow,
                onSelected: (_) => onDateSelected(tomorrow),
              ),
              ChoiceChip(
                label: Text(customLabel),
                avatar: isCustom ? null : const Icon(Icons.calendar_today, size: 16),
                selected: isCustom,
                onSelected: (_) => _pickCustomDate(context, today),
              ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickCustomDate(BuildContext context, DateTime today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
