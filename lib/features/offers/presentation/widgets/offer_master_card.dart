import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/offer_ui_model.dart';

/// The trip details card for offer details.
///
/// M3 card combining date/status header, route timeline,
/// and inline price/seats row in a single elevated surface.
class OfferMasterCard extends StatelessWidget {
  const OfferMasterCard({super.key, required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: AppTokens.elevationLow,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateStatusHeader(offer: offer),
          _RouteTimeline(offer: offer),
          Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant),
          _PriceSeatsRow(offer: offer),
        ],
      ),
    );
  }
}

// ── Row A: Date + Status ─────────────────────────────────────────────────────

class _DateStatusHeader extends StatelessWidget {
  const _DateStatusHeader({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  offer.dateDisplay,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (offer.statusChip != null)
                _StatusChip(spec: offer.statusChip!),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.spec});

  final StatusChipSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: spec.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
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

// ── Row B: Route Timeline ────────────────────────────────────────────────────

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final timeDisplay = offer.exactTimeDisplay ?? offer.partOfDayDisplay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual tracker column
          _VisualTracker(cs: cs),
          const SizedBox(width: 12),
          // Text data column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin block
                Semantics(
                  label: 'Origin: ${offer.originName}',
                  child: Text(
                    offer.originName,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  timeDisplay,
                  style: tt.bodyMedium?.copyWith(color: cs.primary),
                ),
                const SizedBox(height: 20),
                // Destination block
                Semantics(
                  label: 'Destination: ${offer.destinationName}',
                  child: Text(
                    offer.destinationName,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualTracker extends StatelessWidget {
  const _VisualTracker({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Icon(Icons.radio_button_unchecked, size: 16, color: cs.primary),
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Container(width: 2, height: 44, color: cs.outlineVariant),
        ),
        Icon(Icons.location_on, size: 20, color: cs.secondary),
      ],
    );
  }
}

// ── Row C: Price & Seats ─────────────────────────────────────────────────────

class _PriceSeatsRow extends StatelessWidget {
  const _PriceSeatsRow({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Price
          Expanded(child: _PriceItem(offer: offer)),
          const SizedBox(width: 16),
          // Seats
          Expanded(
            child: Row(
              children: [
                Icon(offer.countIcon, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    offer.countDisplay,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  const _PriceItem({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Concrete price: icon + value in primary
    if (offer.moneyHighlight) {
      return Row(
        children: [
          Icon(Icons.sell, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              offer.moneyValue,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
        ],
      );
    }

    // No price: subtle rounded tag
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: cs.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell_outlined, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              offer.moneyValue,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
