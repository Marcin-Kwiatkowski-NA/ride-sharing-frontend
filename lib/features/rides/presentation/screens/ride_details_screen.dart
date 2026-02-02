import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/dto/ride_enums.dart';
import '../../domain/part_of_day.dart' show partOfDayIcon;
import '../../domain/ride_ui_model.dart';
import '../providers/rides_providers.dart';
import '../widgets/contact_driver_button.dart';
import '../widgets/source_badge.dart';

/// Screen displaying detailed ride information.
class RideDetailsScreen extends ConsumerWidget {
  final int rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideDetailProvider(rideId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
      ),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(rideDetailProvider(rideId)),
        ),
        data: (ride) => _RideDetailsBody(ride: ride),
      ),
      bottomNavigationBar: rideAsync.whenOrNull(
        data: (ride) => _BottomBar(ride: ride),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final failure = ErrorMapper.map(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(failure.message),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _RideDetailsBody extends StatelessWidget {
  final RideUiModel ride;

  const _RideDetailsBody({required this.ride});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteHeader(ride: ride),
          const SizedBox(height: 24),
          _WhenSection(ride: ride),
          const SizedBox(height: 24),
          _CostSeatsSection(ride: ride),
          if (ride.description != null && ride.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _DescriptionSection(description: ride.description!),
          ],
          const SizedBox(height: 24),
          _DriverSection(ride: ride),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  final RideUiModel ride;

  const _RouteHeader({required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.trip_origin, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.originName,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.destinationName,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date
        Text(
          ride.dateDisplay,
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
              text: ride.sourceBadgeText,
              color: ride.sourceBadgeColor,
            ),
            _StatusChip(status: ride.status, label: ride.statusDisplay),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RideStatus status;
  final String label;

  const _StatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      RideStatus.open => (Colors.green, Icons.check_circle_outline),
      RideStatus.full => (Colors.orange, Icons.block),
      RideStatus.completed => (Colors.blue, Icons.done_all),
      RideStatus.cancelled => (Colors.red, Icons.cancel_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhenSection extends StatelessWidget {
  final RideUiModel ride;

  const _WhenSection({required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _Section(
      title: 'WHEN',
      child: Row(
        children: [
          // Part-of-day chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!ride.isTimeUndefined)
                  Icon(
                    partOfDayIcon(ride.partOfDay),
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                if (!ride.isTimeUndefined) const SizedBox(width: 6),
                Text(
                  ride.partOfDayDisplay,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Exact time (if available)
          if (ride.exactTimeDisplay != null) ...[
            const SizedBox(width: 16),
            Text(
              ride.exactTimeDisplay!,
              style: theme.textTheme.headlineMedium,
            ),
          ] else if (!ride.isTimeUndefined) ...[
            const SizedBox(width: 16),
            Text(
              '(approximate)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CostSeatsSection extends StatelessWidget {
  final RideUiModel ride;

  const _CostSeatsSection({required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _Section(
      title: 'COST & SEATS',
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              icon: Icons.payments_outlined,
              label: 'Price per seat',
              value: ride.priceDisplay,
              valueColor: ride.hasPrice ? colorScheme.primary : null,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: _InfoTile(
              icon: Icons.event_seat_outlined,
              label: 'Available',
              value: ride.seatsDisplay,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Section(
      title: 'DESCRIPTION',
      child: Text(
        description,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  final RideUiModel ride;

  const _DriverSection({required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (ride.driverName == null) {
      return const SizedBox.shrink();
    }

    return _Section(
      title: 'DRIVER',
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (ride.showRating) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ride.driverRating!.toStringAsFixed(1)} (${ride.driverCompletedRides} rides)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final RideUiModel ride;

  const _BottomBar({required this.ride});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ContactDriverButton(ride: ride),
      ),
    );
  }
}
