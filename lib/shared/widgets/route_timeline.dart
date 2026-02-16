import 'package:flutter/material.dart';

import '../../core/locations/domain/location.dart';

/// Visual timeline connecting origin → destination with a dotted line.
///
/// Uses fixed-height rows (no IntrinsicHeight) and a single CustomPaint
/// pass for the gutter icons and connector lines.
class RouteTimeline extends StatelessWidget {
  final Location? origin;
  final Location? destination;
  final VoidCallback onOriginTap;
  final VoidCallback onDestinationTap;
  final String? originError;
  final String? destinationError;

  /// Height of each location row (fixed for CustomPaint layout).
  static const double _rowHeight = 60.0;

  /// Width of the timeline gutter column.
  static const double _gutterWidth = 32.0;

  const RouteTimeline({
    super.key,
    required this.origin,
    required this.destination,
    required this.onOriginTap,
    required this.onDestinationTap,
    this.originError,
    this.destinationError,
  });

  @override
  Widget build(BuildContext context) {
    final hasOriginError = originError != null;
    final hasDestinationError = destinationError != null;
    // Extra height for error text rows
    final originRowHeight = hasOriginError ? _rowHeight + 20 : _rowHeight;
    final destinationRowHeight =
        hasDestinationError ? _rowHeight + 20 : _rowHeight;
    final totalHeight = originRowHeight + destinationRowHeight;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline gutter with icons and dotted line
          SizedBox(
            width: _gutterWidth,
            height: totalHeight,
            child: CustomPaint(
              painter: _TimelineGutterPainter(
                originRowCenter: _rowHeight / 2,
                destinationRowCenter: originRowHeight + _rowHeight / 2,
                color: Theme.of(context).colorScheme.primary,
                hasOriginError: hasOriginError,
                hasDestinationError: hasDestinationError,
                errorColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),

          // Location tiles
          Expanded(
            child: Column(
              children: [
                _LocationTile(
                  label: 'From',
                  locationName: origin?.name,
                  onTap: onOriginTap,
                  height: _rowHeight,
                  errorText: originError,
                ),
                _LocationTile(
                  label: 'To',
                  locationName: destination?.name,
                  onTap: onDestinationTap,
                  height: _rowHeight,
                  errorText: destinationError,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline gutter painter
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineGutterPainter extends CustomPainter {
  final double originRowCenter;
  final double destinationRowCenter;
  final Color color;
  final bool hasOriginError;
  final bool hasDestinationError;
  final Color errorColor;

  _TimelineGutterPainter({
    required this.originRowCenter,
    required this.destinationRowCenter,
    required this.color,
    required this.hasOriginError,
    required this.hasDestinationError,
    required this.errorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Dotted line between origin and destination
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2.0;

    const dashLength = 4.0;
    const dashGap = 4.0;
    var y = originRowCenter + 10;
    while (y < destinationRowCenter - 10) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, (y + dashLength).clamp(0, destinationRowCenter - 10)),
        linePaint,
      );
      y += dashLength + dashGap;
    }

    // Origin circle
    final originPaint = Paint()
      ..color = hasOriginError ? errorColor : color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, originRowCenter), 6, originPaint);

    // Destination pin (filled triangle/arrow pointing down)
    final destPaint = Paint()
      ..color = hasDestinationError ? errorColor : color
      ..style = PaintingStyle.fill;
    final destCenter = Offset(centerX, destinationRowCenter);
    // Draw a small inverted triangle
    final path = Path()
      ..moveTo(destCenter.dx - 6, destCenter.dy - 4)
      ..lineTo(destCenter.dx + 6, destCenter.dy - 4)
      ..lineTo(destCenter.dx, destCenter.dy + 6)
      ..close();
    canvas.drawPath(path, destPaint);
  }

  @override
  bool shouldRepaint(covariant _TimelineGutterPainter oldDelegate) =>
      originRowCenter != oldDelegate.originRowCenter ||
      destinationRowCenter != oldDelegate.destinationRowCenter ||
      color != oldDelegate.color ||
      hasOriginError != oldDelegate.hasOriginError ||
      hasDestinationError != oldDelegate.hasDestinationError;
}

// ─────────────────────────────────────────────────────────────────────────────
// Location tile (single tappable row)
// ─────────────────────────────────────────────────────────────────────────────

class _LocationTile extends StatelessWidget {
  final String label;
  final String? locationName;
  final VoidCallback onTap;
  final double height;
  final String? errorText;

  const _LocationTile({
    required this.label,
    required this.locationName,
    required this.onTap,
    required this.height,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = locationName != null && locationName!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasValue ? locationName! : 'Choose city',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: hasValue
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
