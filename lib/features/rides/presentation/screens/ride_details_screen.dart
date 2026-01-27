import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/launchers.dart';
import '../../domain/ride_ui_model.dart';
import '../providers/rides_providers.dart';
import '../widgets/source_badge.dart';

/// Screen displaying detailed ride information.
///
/// Pure Riverpod - uses ConsumerWidget, no old Provider dependencies.
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
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(rideDetailProvider(rideId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (ride) => _buildDetails(context, ride),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, RideUiModel ride) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Source Badge
          Center(
            child: SourceBadge(
              text: ride.sourceBadgeText,
              color: ride.sourceBadgeColor,
            ),
          ),
          const SizedBox(height: 16),

          // Route Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildRouteRow(
                    icon: Icons.trip_origin,
                    label: 'From',
                    value: ride.originName,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildRouteRow(
                    icon: Icons.flag,
                    label: 'To',
                    value: ride.destinationName,
                    color: theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time and Date Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(Icons.calendar_today, 'Date', ride.dateDisplay),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    ride.timeDisplay,
                    subtitle: ride.isApproximate ? '(approximate)' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                      Icons.event_seat, 'Available Seats', ride.seatsDisplay),
                  const Divider(height: 24),
                  _buildInfoRow(
                      Icons.payments, 'Price per Seat', ride.priceDisplay),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.info_outline, 'Status', ride.statusDisplay),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Driver Info Card
          if (ride.driverName != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driver', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.person, 'Name', ride.driverName!),
                    if (ride.hasDriverPhone) ...[
                      const Divider(height: 24),
                      _buildInfoRow(Icons.phone, 'Phone', ride.driverPhone!),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // CTA Button
          ElevatedButton.icon(
            onPressed: ride.ctaEnabled
                ? () => _handleCtaAction(context, ride)
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
            ),
            icon: Icon(ride.ctaType == CtaType.phone ? Icons.phone : Icons.open_in_new),
            label: Text(ride.ctaText),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {String? subtitle}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  void _handleCtaAction(BuildContext context, RideUiModel ride) {
    switch (ride.ctaType) {
      case CtaType.phone:
        Launchers.makePhoneCall(ride.driverPhone!);
      case CtaType.link:
        Launchers.openUrl(ride.sourceUrl!);
      case CtaType.disabled:
        break; // should not reach here if button is disabled
    }
  }
}
