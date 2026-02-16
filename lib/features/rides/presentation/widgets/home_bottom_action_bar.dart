import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routes/routes.dart';
import 'publish_selection_sheet.dart';

/// Floating command capsule at the bottom of the rides home screen.
///
/// Pill-shaped bar housing a "My Offers" shortcut (left)
/// and a universal "Post" action (right) that opens [PublishSelectionSheet].
class HomeBottomActionBar extends StatelessWidget {
  const HomeBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: tokens.overlayBorder),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => context.pushNamed(RouteNames.myOffers),
            icon: const Icon(Icons.directions_car, size: 20),
            label: Text(context.l10n.myOffers),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => showPublishSelectionSheet(context),
            icon: const Icon(Icons.add, size: 20),
            label: Text(context.l10n.post),
            style: tokens.brandCtaStyle,
          ),
        ],
      ),
    );
  }
}
