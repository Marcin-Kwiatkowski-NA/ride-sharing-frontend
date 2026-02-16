import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Width of the timeline gutter column (icon + dotted line area).
const kTimelineGutterWidth = 32.0;

/// Default height for timeline rows (kMinInteractiveDimension + 8px padding).
const kTimelineRowHeight = 56.0;

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Icon type drawn in the timeline gutter.
enum TimelineIcon { origin, stop, addStop, destination }

/// Position in the timeline — determines which dotted connector lines to draw.
enum TimelinePosition {
  /// First node — draws bottom line only.
  first,

  /// Middle node — draws top and bottom lines.
  middle,

  /// Last node — draws top line only.
  last,

  /// Only node — draws no lines.
  only,
}

// ─────────────────────────────────────────────────────────────────────────────
// TimelineGutterSegment
// ─────────────────────────────────────────────────────────────────────────────

/// Draws a timeline gutter icon with optional dotted connector lines.
///
/// Width is fixed at [kTimelineGutterWidth]. Height is provided by the parent.
class TimelineGutterSegment extends StatelessWidget {
  final TimelineIcon icon;
  final TimelinePosition position;
  final double height;
  final bool hasError;

  const TimelineGutterSegment({
    super.key,
    required this.icon,
    required this.position,
    this.height = kTimelineRowHeight,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: kTimelineGutterWidth,
      height: height,
      child: CustomPaint(
        painter: _GutterPainter(
          icon: icon,
          position: position,
          color: color,
        ),
      ),
    );
  }
}

class _GutterPainter extends CustomPainter {
  final TimelineIcon icon;
  final TimelinePosition position;
  final Color color;

  const _GutterPainter({
    required this.icon,
    required this.position,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ── Dotted connector lines ──────────────────────────────────────────

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2.0;

    const dashLength = 4.0;
    const dashGap = 4.0;
    const iconGap = 8.0;

    final drawTop =
        position == TimelinePosition.middle || position == TimelinePosition.last;
    final drawBottom =
        position == TimelinePosition.middle ||
        position == TimelinePosition.first;

    if (drawTop) {
      var y = 0.0;
      final endY = centerY - iconGap;
      while (y < endY) {
        final segEnd = (y + dashLength).clamp(0.0, endY);
        canvas.drawLine(Offset(centerX, y), Offset(centerX, segEnd), linePaint);
        y += dashLength + dashGap;
      }
    }

    if (drawBottom) {
      var y = centerY + iconGap;
      final endY = size.height;
      while (y < endY) {
        final segEnd = (y + dashLength).clamp(0.0, endY);
        canvas.drawLine(Offset(centerX, y), Offset(centerX, segEnd), linePaint);
        y += dashLength + dashGap;
      }
    }

    // ── Icon ────────────────────────────────────────────────────────────

    final iconPaint = Paint()..color = color;

    switch (icon) {
      case TimelineIcon.origin:
        // Filled circle
        canvas.drawCircle(Offset(centerX, centerY), 6.0, iconPaint);

      case TimelineIcon.stop:
        // Hollow diamond (rotated square)
        iconPaint.style = PaintingStyle.stroke;
        iconPaint.strokeWidth = 2.0;
        const halfSize = 5.0;
        final path = Path()
          ..moveTo(centerX, centerY - halfSize) // top
          ..lineTo(centerX + halfSize, centerY) // right
          ..lineTo(centerX, centerY + halfSize) // bottom
          ..lineTo(centerX - halfSize, centerY) // left
          ..close();
        canvas.drawPath(path, iconPaint);

      case TimelineIcon.addStop:
        // Small + sign
        iconPaint.style = PaintingStyle.stroke;
        iconPaint.strokeWidth = 2.0;
        iconPaint.strokeCap = StrokeCap.round;
        const armLength = 5.0;
        // Horizontal line
        canvas.drawLine(
          Offset(centerX - armLength, centerY),
          Offset(centerX + armLength, centerY),
          iconPaint,
        );
        // Vertical line
        canvas.drawLine(
          Offset(centerX, centerY - armLength),
          Offset(centerX, centerY + armLength),
          iconPaint,
        );

      case TimelineIcon.destination:
        // Filled inverted triangle (pin)
        final path = Path()
          ..moveTo(centerX - 6, centerY - 4)
          ..lineTo(centerX + 6, centerY - 4)
          ..lineTo(centerX, centerY + 6)
          ..close();
        canvas.drawPath(path, iconPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GutterPainter oldDelegate) =>
      icon != oldDelegate.icon ||
      position != oldDelegate.position ||
      color != oldDelegate.color;
}

// ─────────────────────────────────────────────────────────────────────────────
// TimelineLocationRow
// ─────────────────────────────────────────────────────────────────────────────

/// A tappable location row for use in the route timeline.
///
/// Shows label + location name (or placeholder) + chevron.
/// Optionally shows supporting text and error text.
class TimelineLocationRow extends StatelessWidget {
  final String label;
  final String? locationName;
  final String? supportingText;
  final String? errorText;
  final VoidCallback onTap;
  final double height;
  final Widget? trailing;

  const TimelineLocationRow({
    super.key,
    required this.label,
    this.locationName,
    this.supportingText,
    this.errorText,
    required this.onTap,
    this.height = kTimelineRowHeight,
    this.trailing,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          hasValue ? locationName! : 'City, Place...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: hasValue
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (supportingText != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            supportingText!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      Icons.chevron_right,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
