import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// Vertical list of recent searches displayed below the [HeroSearchCard].
///
/// Surface-tinted container styled as a "recent history" dropdown.
class RecentSearchesList extends StatelessWidget {
  const RecentSearchesList({super.key});

  static const _mockSearches = [
    'Warsaw → Krakow',
    'Warsaw → Gdansk',
    'Krakow → Wroclaw',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _mockSearches.length; i++) ...[
            _SearchRow(label: _mockSearches[i]),
            if (i < _mockSearches.length - 1)
              Divider(
                color: colorScheme.outlineVariant,
                height: 1,
                indent: 48,
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final String label;

  const _SearchRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.history, color: colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
