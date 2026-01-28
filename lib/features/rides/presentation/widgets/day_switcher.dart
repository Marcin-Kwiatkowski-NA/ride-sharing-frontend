import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/search_criteria_provider.dart';

/// Day switcher widget with Today, Tomorrow, and date picker buttons.
class DaySwitcher extends ConsumerWidget {
  const DaySwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final selectedDate = criteria.departureDate ?? DateTime.now();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final isToday = selectedDay == today;
    final isTomorrow = selectedDay == tomorrow;
    final isOtherDate = !isToday && !isTomorrow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Today'),
            selected: isToday,
            onSelected: (_) => _setDate(ref, today),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Tomorrow'),
            selected: isTomorrow,
            onSelected: (_) => _setDate(ref, tomorrow),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.calendar_today, size: 18),
            label: Text(_formatDate(selectedDate)),
            side: isOtherDate
                ? BorderSide(color: Theme.of(context).colorScheme.primary)
                : null,
            backgroundColor: isOtherDate
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            onPressed: () => _showDatePicker(context, ref, selectedDate),
          ),
        ],
      ),
    );
  }

  void _setDate(WidgetRef ref, DateTime date) {
    ref.read(searchCriteriaProvider.notifier).setDepartureDate(date);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      _setDate(ref, date);
    }
  }
}
