import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_l10n.dart';

class OfferCard extends StatelessWidget {
  final OfferUiModel offer;
  final VoidCallback? onTap;

  const OfferCard({super.key, required this.offer, this.onTap});

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
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          // Soft, diffused shadow for depth
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
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
                  child: _RouteTimeline(offer: offer),
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
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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

  const _RouteTimeline({required this.offer});

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
                // Dashed Line
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: colorScheme.outlineVariant,
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
                Text(
                  offer.originName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16), // Breathing room between cities

                // Destination Name
                Text(
                  offer.destinationName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      ],
    );
  }
}

// Helper for the dashed line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

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
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}