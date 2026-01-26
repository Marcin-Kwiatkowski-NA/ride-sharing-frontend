import 'package:flutter/material.dart';

import '../../domain/ride_ui_model.dart';
import 'source_badge.dart';

/// Card widget displaying ride information.
///
/// Consumes [RideUiModel] for all display values - no formatting logic here.
class RideCard extends StatelessWidget {
  final RideUiModel ride;
  final VoidCallback? onTap;
  final VoidCallback? onCtaTap;

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SourceBadge(
                    text: ride.sourceBadgeText,
                    color: ride.sourceBadgeColor,
                  ),
                  if (ride.isApproximate)
                    Tooltip(
                      message: 'Approximate departure time',
                      child: Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: [
                  Icon(Icons.trip_origin, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.originName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flag, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.destinationName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Date, time, seats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(ride.dateDisplay),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(ride.timeDisplay),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Seats and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 16),
                      const SizedBox(width: 4),
                      Text(ride.seatsDisplay),
                    ],
                  ),
                  Text(
                    ride.priceDisplay,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          ride.hasPrice ? theme.colorScheme.primary : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: ride.ctaEnabled ? onCtaTap : null,
                  icon: Icon(
                    ride.hasDriverPhone ? Icons.phone : Icons.open_in_new,
                    size: 18,
                  ),
                  label: Text(ride.ctaText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
