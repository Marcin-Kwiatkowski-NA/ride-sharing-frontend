import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_l10n.dart';

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
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  offer.localizedDate(l10n),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (offer.status != null)
                _StatusChip(status: offer.status!),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.localizedLabel(l10n),
            style: TextStyle(
              color: status.color,
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
    final l10n = context.l10n;

    final timeDisplay = offer.exactTimeDisplay ?? offer.localizedPartOfDay(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual tracker column
          _VisualTracker(cs: cs, stopCount: offer.intermediateStops.length),
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
                // Intermediate stops
                for (final stop in offer.intermediateStops) ...[
                  const SizedBox(height: 16),
                  Text(
                    stop.cityName,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (stop.timeDisplay != null)
                    Row(
                      children: [
                        Text(
                          stop.timeDisplay!,
                          style: tt.bodyMedium?.copyWith(color: cs.primary),
                        ),
                        if (stop.isNextDay) ...[
                          const SizedBox(width: 4),
                          _NextDayBadge(cs: cs, tt: tt),
                        ],
                      ],
                    ),
                ],
                const SizedBox(height: 16),
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

class _NextDayBadge extends StatelessWidget {
  const _NextDayBadge({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppTokens.radiusXS),
      ),
      child: Text(
        '+1',
        style: tt.labelSmall?.copyWith(
          color: cs.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VisualTracker extends StatelessWidget {
  const _VisualTracker({required this.cs, this.stopCount = 0});

  final ColorScheme cs;
  final int stopCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Icon(Icons.radio_button_unchecked, size: 16, color: cs.primary),
        for (int i = 0; i < stopCount; i++) ...[
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Container(width: 2, height: 28, color: cs.outlineVariant),
          ),
          Icon(Icons.circle, size: 10, color: cs.primary),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Container(width: 2, height: 28, color: cs.outlineVariant),
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
    final l10n = context.l10n;

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
                    offer.localizedCountDisplay(l10n),
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
    final l10n = context.l10n;
    final moneyText = offer.localizedMoneyValue(l10n);

    // Concrete price: icon + value in primary
    if (offer.hasMoneyAmount) {
      return Row(
        children: [
          Icon(Icons.sell, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              moneyText,
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
              moneyText,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
