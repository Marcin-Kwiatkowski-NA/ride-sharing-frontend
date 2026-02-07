import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';

/// Glassmorphism bottom action bar for the rides home screen.
///
/// Houses a "My Rides" shortcut (left) and the primary "Offer Ride"
/// driver action (right), replacing the old floating driver conversion tile.
class HomeBottomActionBar extends StatelessWidget {
  const HomeBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80 + bottomPadding,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            border: const Border(
              top: BorderSide(color: Colors.white12),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => context.pushNamed(RouteNames.myOffers),
                icon: const Icon(Icons.directions_car, size: 20),
                label: const Text('My Rides'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.postRide),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Offer Ride'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
