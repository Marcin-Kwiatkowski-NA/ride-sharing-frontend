import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../booking/domain/booking_mode.dart';
import '../../../rides/data/dto/ride_stop_dto.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_l10n.dart';

class OfferCard extends StatelessWidget {
  final OfferUiModel offer;
  final VoidCallback? onTap;
  final String? originDistanceHint;
  final String? destinationDistanceHint;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.originDistanceHint,
    this.destinationDistanceHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Clean surface
        borderRadius: BorderRadius.circular(20), // Modern, large radius
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          // Soft, diffused shadow for depth
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20), // Generous padding (Bigger card)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LEFT: Time Display
                SizedBox(
                  width: 75, // Fixed width for alignment consistency
                  child: _TimeDisplay(offer: offer),
                ),

                // 2. MIDDLE: Visual Route Timeline
                Expanded(
                  child: _RouteTimeline(
                    offer: offer,
                    originDistanceHint: originDistanceHint,
                    destinationDistanceHint: destinationDistanceHint,
                  ),
                ),

                const SizedBox(width: 12),

                // 3. RIGHT: Price & Seats Badge
                _PriceAndSeats(offer: offer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 1. Time Display Logic
// ──────────────────────────────────────────────────────────────────────────────
class _TimeDisplay extends StatelessWidget {
  final OfferUiModel offer;

  const _TimeDisplay({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    // SCENARIO A: Exact Time (e.g., 17:00)
    // Clean, big, bold. No "Part of day".
    if (offer.exactTimeDisplay != null) {
      return Text(
        offer.exactTimeDisplay!,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800, // Extra Bold
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
          height: 1.0,
        ),
      );
    }

    // SCENARIO B: Approximate / Flexible
    // Show Icon + Part of Day (e.g., "Evening")
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_filled_rounded, // Or a specific icon based on part of day
            size: 20,
            color: colorScheme.onTertiaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          offer.localizedPartOfDay(l10n),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          l10n.flexible, // "Elastycznie"
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 2. Route Timeline (Visual Connector)
// ──────────────────────────────────────────────────────────────────────────────
class _RouteTimeline extends StatelessWidget {
  final OfferUiModel offer;
  final String? originDistanceHint;
  final String? destinationDistanceHint;

  const _RouteTimeline({
    required this.offer,
    this.originDistanceHint,
    this.destinationDistanceHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The Graphic Line
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Column(
              children: [
                // Origin Dot (Hollow)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                // Dashed Line with intermediate dots
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: colorScheme.outlineVariant,
                        intermediateDotCount: offer.intermediateStops.length,
                        dotColor: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                // Destination Pin (Filled)
                Icon(
                    Icons.location_on,
                    size: 14,
                    color: colorScheme.primary
                ),
              ],
            ),
          ),

          // The City Names
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Origin Name
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        offer.originName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (originDistanceHint != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        originDistanceHint!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),

                // Compact intermediate stops display
                if (offer.intermediateStops.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _ViaLabel(
                      stops: offer.intermediateStops,
                      allStops: offer.stops,
                      searchOriginOsmId: offer.searchOriginOsmId,
                      searchDestinationOsmId: offer.searchDestinationOsmId,
                    ),
                  ),

                if (offer.intermediateStops.isEmpty)
                  const SizedBox(height: 16),

                // Destination Name
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        offer.destinationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (destinationDistanceHint != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        destinationDistanceHint!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 3. Price & Seats (Right Side Badge)
// ──────────────────────────────────────────────────────────────────────────────
class _PriceAndSeats extends StatelessWidget {
  final OfferUiModel offer;

  const _PriceAndSeats({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Price Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: offer.hasMoneyAmount
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            offer.hasMoneyAmount
                ? offer.localizedMoneyValue(l10n)
                : l10n.unknownPrice,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: offer.hasMoneyAmount
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Seats Info (Subtle)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              offer.localizedCountDisplay(l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.airline_seat_recline_normal_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),

        // Booking mode badge (internal rides only)
        if (!offer.isExternalSource &&
            offer.offerKey.kind == OfferKind.ride) ...[
          const SizedBox(height: 6),
          _BookingModeBadge(bookingMode: offer.bookingMode),
        ],

        // Facebook badge (external rides)
        if (offer.isExternalSource) ...[
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Facebook',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingModeBadge extends StatelessWidget {
  final BookingMode bookingMode;

  const _BookingModeBadge({required this.bookingMode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isInstant = bookingMode == BookingMode.instant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isInstant ? cs.primaryContainer : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInstant ? Icons.bolt : Icons.hourglass_top,
            size: 10,
            color: isInstant
                ? cs.onPrimaryContainer
                : cs.onTertiaryContainer,
          ),
          const SizedBox(width: 2),
          Text(
            isInstant
                ? l10n.bookingModeInstant
                : l10n.bookingModeRequest,
            style: tt.labelSmall?.copyWith(
              fontSize: 10,
              color: isInstant
                  ? cs.onPrimaryContainer
                  : cs.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViaLabel extends StatelessWidget {
  final List<IntermediateStopUi> stops;
  final List<RideStopDto> allStops;
  final int? searchOriginOsmId;
  final int? searchDestinationOsmId;

  const _ViaLabel({
    required this.stops,
    this.allStops = const [],
    this.searchOriginOsmId,
    this.searchDestinationOsmId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredStops = _filterBySearchContext();

    if (filteredStops.isEmpty) return const SizedBox.shrink();

    final String label;
    if (filteredStops.length == 1) {
      label = 'Via ${filteredStops.first}';
    } else {
      label = 'Via ${filteredStops.first} + ${filteredStops.length - 1}';
    }

    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Filter intermediate stop names to only those within the search segment.
  List<String> _filterBySearchContext() {
    if (searchOriginOsmId == null ||
        searchDestinationOsmId == null ||
        allStops.length <= 2) {
      return stops.map((s) => s.cityName).toList();
    }

    final sorted = [...allStops]
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    int? originIdx;
    int? destIdx;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].location.osmId == searchOriginOsmId) originIdx = i;
      if (sorted[i].location.osmId == searchDestinationOsmId) destIdx = i;
    }

    if (originIdx == null || destIdx == null || originIdx >= destIdx) {
      return stops.map((s) => s.cityName).toList();
    }

    // Return only stops between origin and destination
    final result = <String>[];
    for (int i = originIdx + 1; i < destIdx; i++) {
      result.add(sorted[i].location.name);
    }
    return result;
  }
}

// Helper for the dashed line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final int intermediateDotCount;
  final Color? dotColor;

  _DashedLinePainter({
    required this.color,
    this.intermediateDotCount = 0,
    this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashHeight = 4;
    const dashSpace = 3;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }

    // Draw intermediate stop dots
    if (intermediateDotCount > 0 && size.height > 0) {
      final dotPaint = Paint()..color = dotColor ?? color;
      for (int i = 0; i < intermediateDotCount; i++) {
        final y = size.height * (i + 1) / (intermediateDotCount + 1);
        canvas.drawCircle(Offset(0, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      intermediateDotCount != oldDelegate.intermediateDotCount ||
      color != oldDelegate.color;
}