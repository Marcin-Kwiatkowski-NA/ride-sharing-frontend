import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import 'publish_selection_sheet.dart';

/// Floating command capsule at the bottom of the rides home screen.
///
/// Pill-shaped glassmorphism bar housing a "My Rides" shortcut (left)
/// and a universal "Post" action (right) that opens [PublishSelectionSheet].
class HomeBottomActionBar extends StatelessWidget {
  const HomeBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => context.pushNamed(RouteNames.myOffers),
                icon: const Icon(Icons.directions_car, size: 20),
                label: const Text('My Rides'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showPublishSelectionSheet(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Post'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
