import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';

/// The "boarding pass" master card for offer details.
///
/// M3 filled card combining date/status header, route timeline,
/// stats footer, and conditional source banner in a single surface.
/// Each row is a separate private widget for isolated rebuilds.
class OfferMasterCard extends StatelessWidget {
  const OfferMasterCard({super.key, required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: AppTokens.elevationNone,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateStatusHeader(offer: offer),
          _RouteTimeline(offer: offer),
          _StatsFooter(
            offer: offer,
            hasSourceBanner: offer.isExternalSource,
          ),
          if (offer.isExternalSource) _SourceBanner(offer: offer),
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
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeDisplay,
                  style: tt.bodyLarge?.copyWith(color: cs.primary),
                ),
                const SizedBox(height: 24),
                // Destination block
                Semantics(
                  label: 'Destination: ${offer.destinationName}',
                  child: Text(
                    offer.destinationName,
                    style: tt.headlineSmall?.copyWith(
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

class _VisualTracker extends StatelessWidget {
  const _VisualTracker({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.radio_button_unchecked, size: 16, color: cs.primary),
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Container(width: 2, height: 40, color: cs.outlineVariant),
        ),
        Icon(Icons.location_on, size: 20, color: cs.secondary),
      ],
    );
  }
}

// ── Row C: Stats Footer ──────────────────────────────────────────────────────

class _StatsFooter extends StatelessWidget {
  const _StatsFooter({
    required this.offer,
    required this.hasSourceBanner,
  });

  final OfferUiModel offer;
  final bool hasSourceBanner;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final strings = OfferDetailsStrings(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: hasSourceBanner
            ? BorderRadius.zero
            : BorderRadius.only(
                bottomLeft: Radius.circular(AppTokens.radiusXL),
                bottomRight: Radius.circular(AppTokens.radiusXL),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Price column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.priceLabel,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                _PriceValue(offer: offer),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: VerticalDivider(
              color: cs.outlineVariant,
              width: 1,
              thickness: 1,
            ),
          ),
          // Seats column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.availabilityLabel,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        offer.countIcon,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(offer.countDisplay, style: tt.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceValue extends StatelessWidget {
  const _PriceValue({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final style = tt.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: offer.moneyHighlight ? cs.primary : null,
    );

    // Pill badge for "Ask driver" when no price is set
    if (!offer.moneyHighlight) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
          color: cs.surfaceContainerHighest,
          shape: const StadiumBorder(),
        ),
        child: Text(offer.moneyValue, style: style),
      );
    }

    return Text(offer.moneyValue, style: style);
  }
}

// ── Row D: Source Banner (conditional) ────────────────────────────────────────

class _SourceBanner extends StatelessWidget {
  const _SourceBanner({required this.offer});

  final OfferUiModel offer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final strings = OfferDetailsStrings(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTokens.radiusXL),
          bottomRight: Radius.circular(AppTokens.radiusXL),
        ),
      ),
      child: Text(
        strings.driverSubtitle(
          offer.offerKey.kind,
          isExternalSource: true,
        ),
        style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
        textAlign: TextAlign.center,
      ),
    );
  }
}
