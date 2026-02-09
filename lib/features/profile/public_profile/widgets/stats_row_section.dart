import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../domain/public_profile_data.dart';

class StatsRowSection extends StatelessWidget {
  final PublicProfileData profile;

  const StatsRowSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final totalRides = profile.ridesGiven + profile.ridesTaken;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        ),
        child: Row(
          children: [
            _StatColumn(
              value: totalRides.toString(),
              label: 'Rides',
              icon: Icons.directions_car,
              iconColor: cs.primary,
              textTheme: tt,
              colorScheme: cs,
            ),
            _divider(cs),
            _StatColumn(
              value: profile.ratingCount > 0
                  ? profile.ratingAvg!.toStringAsFixed(1)
                  : '-',
              label: 'Rating',
              icon: Icons.star,
              iconColor: cs.tertiary,
              textTheme: tt,
              colorScheme: cs,
            ),
            _divider(cs),
            _StatColumn(
              value: profile.ratingCount.toString(),
              label: 'Reviews',
              icon: Icons.reviews,
              iconColor: cs.primary,
              textTheme: tt,
              colorScheme: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        width: 1,
        color: cs.outlineVariant,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
