import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import '../../domain/part_of_day.dart' show partOfDayIcon;
import 'offer_section.dart';

/// When section showing part-of-day chip and exact time.
class OfferWhenSection extends StatelessWidget {
  final OfferUiModel offer;

  const OfferWhenSection({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OfferSection(
      title: 'WHEN',
      child: Row(
        children: [
          // Part-of-day chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!offer.isTimeUndefined)
                  Icon(
                    partOfDayIcon(offer.partOfDay),
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                if (!offer.isTimeUndefined) const SizedBox(width: 6),
                Text(
                  offer.partOfDayDisplay,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Exact time (if available)
          if (offer.exactTimeDisplay != null) ...[
            const SizedBox(width: 16),
            Text(offer.exactTimeDisplay!, style: theme.textTheme.headlineMedium),
          ] else if (!offer.isTimeUndefined) ...[
            const SizedBox(width: 16),
            Text(
              '(approximate)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
