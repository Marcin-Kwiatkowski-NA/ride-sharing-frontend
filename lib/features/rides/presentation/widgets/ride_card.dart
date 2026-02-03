import 'package:flutter/material.dart';

import '../../domain/ride_ui_model.dart';
import 'source_badge.dart';

/// Card widget displaying ride information.
///
/// Layout:
/// - Route + price (top row)
/// - Date + part-of-day + time (second row)
/// - Chips: seats, source (bottom row)
class RideCard extends StatelessWidget {
  final RideUiModel ride;
  final VoidCallback? onTap;

  const RideCard({super.key, required this.ride, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route + Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ride.routeDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ride.priceDisplay,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ride.hasPrice ? colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date + Part-of-day + Time row
              Row(
                children: [
                  Text(
                    ride.dateDisplay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '|',
                    style: TextStyle(color: colorScheme.outlineVariant),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ride.partOfDayDisplay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (ride.exactTimeDisplay != null) ...[
                    const Spacer(),
                    Text(
                      ride.exactTimeDisplay!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Chips row: seats + source
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(
                    context,
                    Icons.event_seat_outlined,
                    ride.seatsDisplay,
                  ),
                  SourceBadge(
                    text: ride.sourceBadgeText,
                    color: ride.sourceBadgeColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
