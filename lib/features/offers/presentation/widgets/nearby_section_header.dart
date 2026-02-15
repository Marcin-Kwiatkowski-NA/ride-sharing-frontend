import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';

/// Section header for the nearby/approximate results section.
///
/// Renders as: ── Approximate matches ──
class NearbySectionHeader extends StatelessWidget {
  const NearbySectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: colorScheme.outlineVariant),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              context.l10n.approximateMatchesHeader,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}
