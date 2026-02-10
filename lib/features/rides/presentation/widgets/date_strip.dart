import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/search_criteria_provider.dart';

/// Compact prev/next day navigation strip for the rides list header.
class DateStrip extends ConsumerWidget {
  const DateStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final theme = Theme.of(context);

    final now = DateTime.now();
    final today = normalizeDate(now);
    final selectedDate = criteria.departureDate != null
        ? normalizeDate(criteria.departureDate!)
        : today;

    final canGoBack = selectedDate.isAfter(today);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoBack
              ? () {
                  final prev = selectedDate.subtract(const Duration(days: 1));
                  ref
                      .read(searchCriteriaProvider.notifier)
                      .setDepartureDate(normalizeDate(prev));
                }
              : null,
          tooltip: context.l10n.previousDay,
        ),
        GestureDetector(
          onTap: () => _showDatePicker(context, ref, selectedDate),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatLabel(context, selectedDate, today),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = selectedDate.add(const Duration(days: 1));
            ref
                .read(searchCriteriaProvider.notifier)
                .setDepartureDate(normalizeDate(next));
          },
          tooltip: context.l10n.nextDay,
        ),
      ],
    );
  }

  String _formatLabel(BuildContext context, DateTime selected, DateTime today) {
    final tomorrow = today.add(const Duration(days: 1));
    if (selected == today) return context.l10n.today;
    if (selected == tomorrow) return context.l10n.tomorrow;
    return context.l10n.dateStripDate(selected);
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      ref
          .read(searchCriteriaProvider.notifier)
          .setDepartureDate(normalizeDate(date));
    }
  }
}
