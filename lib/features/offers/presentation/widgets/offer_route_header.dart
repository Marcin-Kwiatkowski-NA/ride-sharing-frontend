import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import 'source_badge.dart';

/// Route header showing origin → destination with source and status chips.
class OfferRouteHeader extends StatelessWidget {
  final OfferUiModel offer;

  const OfferRouteHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.trip_origin, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                offer.originName,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Container(
            width: 2,
            height: 24,
            color: colorScheme.outlineVariant,
          ),
        ),
        // Destination
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                offer.destinationName,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date
        Text(
          offer.dateDisplay,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Chips: Source + Status
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SourceBadge(
              text: offer.sourceBadgeText,
              color: offer.sourceBadgeColor,
            ),
            if (offer.statusChip != null)
              _StatusChip(spec: offer.statusChip!),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final StatusChipSpec spec;

  const _StatusChip({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: spec.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spec.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spec.icon, size: 14, color: spec.color),
          const SizedBox(width: 4),
          Text(
            spec.label,
            style: TextStyle(
              color: spec.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
