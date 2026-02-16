import 'package:flutter/material.dart';

import '../../core/locations/domain/location.dart';
import 'departure_picker_helpers.dart';
import 'timeline_building_blocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route stop data (presentation-only, avoids importing controller models)
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight data for a single intermediate stop in the route timeline.
class RouteStopData {
  final String id;
  final String? locationName;
  final TimeOfDay? departureTime;

  const RouteStopData({
    required this.id,
    this.locationName,
    this.departureTime,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// RouteTimelineSection
// ─────────────────────────────────────────────────────────────────────────────

/// Unified route widget: origin → stops → add-stop → destination.
///
/// Owns all vertical spacing and gutter alignment. Renders a continuous
/// dotted timeline through all nodes.
///
/// For screens without stops (e.g. PostSeatScreen), pass `stops: const []`.
class RouteTimelineSection extends StatelessWidget {
  // Labels (caller provides l10n strings)
  final String originLabel;
  final String destinationLabel;
  final String addStopLabel;

  // Origin / Destination
  final Location? origin;
  final Location? destination;
  final VoidCallback onOriginTap;
  final VoidCallback onDestinationTap;
  final String? originError;
  final String? destinationError;

  // Intermediate stops
  final List<RouteStopData> stops;
  final ValueChanged<int>? onStopTap;
  final ValueChanged<int>? onStopTimeTap;
  final ValueChanged<int>? onStopRemove;
  final void Function(int oldIndex, int newIndex)? onStopReorder;
  final VoidCallback? onAddStop;
  final int maxStops;
  final String? stopsError;

  const RouteTimelineSection({
    super.key,
    this.originLabel = 'From',
    this.destinationLabel = 'To',
    this.addStopLabel = 'Add stop',
    required this.origin,
    required this.destination,
    required this.onOriginTap,
    required this.onDestinationTap,
    this.originError,
    this.destinationError,
    this.stops = const [],
    this.onStopTap,
    this.onStopTimeTap,
    this.onStopRemove,
    this.onStopReorder,
    this.onAddStop,
    this.maxStops = 3,
    this.stopsError,
  });

  bool get _hasStops => stops.isNotEmpty;
  bool get _showAddStop => onAddStop != null && stops.length < maxStops;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Origin ────────────────────────────────────────────────────
        _buildNodeRow(
          context,
          gutter: TimelineGutterSegment(
            icon: TimelineIcon.origin,
            position: TimelinePosition.first,
            hasError: originError != null,
          ),
          child: TimelineLocationRow(
            label: originLabel,
            locationName: origin?.name,
            errorText: originError,
            onTap: onOriginTap,
          ),
        ),

        // ── Intermediate stops (reorderable) ──────────────────────────
        if (_hasStops)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: _proxyDecorator,
            onReorder: onStopReorder ?? (_, __) {},
            itemCount: stops.length,
            itemBuilder: (context, index) => _buildStopRow(context, index),
          ),

        // ── Add stop node ─────────────────────────────────────────────
        if (_showAddStop) _buildAddStopRow(context),

        // ── Destination ───────────────────────────────────────────────
        _buildNodeRow(
          context,
          gutter: TimelineGutterSegment(
            icon: TimelineIcon.destination,
            position: TimelinePosition.last,
            hasError: destinationError != null,
          ),
          child: TimelineLocationRow(
            label: destinationLabel,
            locationName: destination?.name,
            errorText: destinationError,
            onTap: onDestinationTap,
          ),
        ),

        // ── Stops error ───────────────────────────────────────────────
        if (stopsError != null)
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              left: kTimelineGutterWidth + 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                stopsError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildNodeRow(
    BuildContext context, {
    required TimelineGutterSegment gutter,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gutter,
        Expanded(child: child),
      ],
    );
  }

  Widget _buildStopRow(BuildContext context, int index) {
    final stop = stops[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      key: ValueKey(stop.id),
      type: MaterialType.transparency,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TimelineGutterSegment(
            icon: TimelineIcon.stop,
            position: TimelinePosition.middle,
          ),
          Expanded(
            child: SizedBox(
              height: kTimelineRowHeight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Location tap area
                    Expanded(
                      child: InkWell(
                        onTap: onStopTap != null
                            ? () => onStopTap!(index)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Stop ${index + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stop.locationName ?? 'City, Place...',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: stop.locationName != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Time chip
                    if (onStopTimeTap != null)
                      _StopTimeChip(
                        time: stop.departureTime,
                        onTap: () => onStopTimeTap!(index),
                      ),

                    // Drag handle
                    if (onStopReorder != null)
                      ReorderableDragStartListener(
                        index: index,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: kMinInteractiveDimension,
                            minHeight: kMinInteractiveDimension,
                          ),
                          child: Icon(
                            Icons.drag_handle,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                    // Remove
                    if (onStopRemove != null)
                      GestureDetector(
                        onTap: () => onStopRemove!(index),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: kMinInteractiveDimension,
                            minHeight: kMinInteractiveDimension,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStopRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const TimelineGutterSegment(
          icon: TimelineIcon.addStop,
          position: TimelinePosition.middle,
          height: 44,
        ),
        Expanded(
          child: InkWell(
            onTap: onAddStop,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    addStopLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _proxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stop time chip
// ─────────────────────────────────────────────────────────────────────────────

class _StopTimeChip extends StatelessWidget {
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _StopTimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                if (time != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    formatPickedTime(time!),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
