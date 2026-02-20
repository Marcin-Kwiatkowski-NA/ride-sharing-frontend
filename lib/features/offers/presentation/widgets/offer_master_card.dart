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

class _RouteTimeline extends StatefulWidget {
  const _RouteTimeline({required this.offer});

  final OfferUiModel offer;

  @override
  State<_RouteTimeline> createState() => _RouteTimelineState();
}

class _RouteTimelineState extends State<_RouteTimeline> {
  bool _showFullRoute = false;

  /// Find stop indices matching the search context.
  /// Returns (originIndex, destinationIndex) or null if no context.
  (int, int)? _findSearchSegment() {
    final offer = widget.offer;
    if (offer.searchOriginOsmId == null ||
        offer.searchDestinationOsmId == null) {
      return null;
    }
    if (offer.stops.length <= 2) return null;

    final sorted = [...offer.stops]
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    int? originIdx;
    int? destIdx;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].location.osmId == offer.searchOriginOsmId) {
        originIdx = i;
      }
      if (sorted[i].location.osmId == offer.searchDestinationOsmId) {
        destIdx = i;
      }
    }

    if (originIdx != null && destIdx != null && originIdx < destIdx) {
      return (originIdx, destIdx);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final offer = widget.offer;

    final timeDisplay =
        offer.exactTimeDisplay ?? offer.localizedPartOfDay(l10n);
    final segment = _findSearchSegment();
    final hasContext = segment != null && !_showFullRoute;

    // Build the list of intermediate stops with context info
    final stopsToShow = <_StopDisplayInfo>[];
    if (hasContext) {
      final (searchOriginIdx, searchDestIdx) = segment;
      final sorted = [...offer.stops]
        ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

      // Only show stops between searchOrigin and searchDest (exclusive)
      for (int i = 0; i < sorted.length; i++) {
        if (i <= searchOriginIdx || i >= searchDestIdx) continue;
        final s = sorted[i];
        final stopUi = offer.intermediateStops
            .where((is_) => is_.cityName == s.location.name)
            .firstOrNull;
        stopsToShow.add(_StopDisplayInfo(
          cityName: s.location.name,
          timeDisplay: stopUi?.timeDisplay,
          isNextDay: stopUi?.isNextDay ?? false,
          isMuted: true,
        ));
      }
    } else {
      for (final stop in offer.intermediateStops) {
        stopsToShow.add(_StopDisplayInfo(
          cityName: stop.cityName,
          timeDisplay: stop.timeDisplay,
          isNextDay: stop.isNextDay,
          isMuted: false,
        ));
      }
    }

    // Determine origin/destination names for contextual display
    String originName = offer.originName;
    String destName = offer.destinationName;
    if (hasContext) {
      final sorted = [...offer.stops]
        ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
      final (searchOriginIdx, searchDestIdx) = segment;
      originName = sorted[searchOriginIdx].location.name;
      destName = sorted[searchDestIdx].location.name;
    }

    // Count collapsed stops
    int collapsedCount = 0;
    if (hasContext) {
      final sorted = [...offer.stops]
        ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
      final (searchOriginIdx, searchDestIdx) = segment;
      collapsedCount =
          searchOriginIdx + (sorted.length - 1 - searchDestIdx);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisualTracker(cs: cs, stopCount: stopsToShow.length),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin block
                Semantics(
                  label: 'Origin: $originName',
                  child: Text(
                    originName,
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
                for (final stop in stopsToShow) ...[
                  const SizedBox(height: 16),
                  Text(
                    stop.cityName,
                    style: stop.isMuted
                        ? tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          )
                        : tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                  if (stop.timeDisplay != null)
                    Row(
                      children: [
                        Text(
                          stop.timeDisplay!,
                          style: stop.isMuted
                              ? tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                )
                              : tt.bodyMedium
                                  ?.copyWith(color: cs.primary),
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
                  label: 'Destination: $destName',
                  child: Text(
                    destName,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // "Show full route" chip
                if (hasContext && collapsedCount > 0) ...[
                  const SizedBox(height: 8),
                  ActionChip(
                    label: Text(l10n.showFullRoute),
                    avatar: const Icon(Icons.unfold_more, size: 16),
                    onPressed: () =>
                        setState(() => _showFullRoute = true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StopDisplayInfo {
  final String cityName;
  final String? timeDisplay;
  final bool isNextDay;
  final bool isMuted;

  const _StopDisplayInfo({
    required this.cityName,
    this.timeDisplay,
    this.isNextDay = false,
    this.isMuted = false,
  });
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
