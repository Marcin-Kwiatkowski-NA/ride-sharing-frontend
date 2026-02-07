import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';

/// Opens the publish selection sheet as a modal bottom sheet.
void showPublishSelectionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => const PublishSelectionSheet(),
  );
}

/// Bottom sheet letting users choose between posting a ride offer (driver)
/// or a ride request (passenger).
class PublishSelectionSheet extends StatelessWidget {
  const PublishSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What are you posting?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _PublishOption(
              icon: Icons.directions_car,
              iconColor: colorScheme.primary,
              title: 'Offer a Ride',
              subtitle: "I'm driving and have empty seats.",
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(RouteNames.postRide);
              },
            ),
            const SizedBox(height: 12),
            _PublishOption(
              icon: Icons.hail,
              iconColor: colorScheme.tertiary,
              title: 'Request a Ride',
              subtitle: 'I need a driver for a specific date.',
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(RouteNames.postSeat);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PublishOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
