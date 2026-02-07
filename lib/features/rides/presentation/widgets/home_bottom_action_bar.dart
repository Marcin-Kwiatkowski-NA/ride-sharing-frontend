import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import 'publish_selection_sheet.dart';

/// Glassmorphism bottom action bar for the rides home screen.
///
/// Houses a "My Rides" shortcut (left) and a universal "Post" action
/// (right) that opens [PublishSelectionSheet] for driver/passenger choice.
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
                onPressed: () => showPublishSelectionSheet(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Post'),
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
