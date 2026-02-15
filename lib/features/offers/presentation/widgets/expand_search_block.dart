import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../providers/nearby_offers_provider.dart';

/// Block that offers to expand the search to nearby locations.
///
/// Renders as an [OutlinedButton] when idle, a loading spinner when
/// searching, or a muted "no results" message when the nearby search
/// returned nothing.
class ExpandSearchBlock extends StatelessWidget {
  final NearbyStatus status;
  final VoidCallback? onTap;
  final bool isRidesMode;

  const ExpandSearchBlock({
    super.key,
    required this.status,
    required this.onTap,
    this.isRidesMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          switch (status) {
            NearbyStatus.idle => _buildIdleState(theme, colorScheme, l10n),
            NearbyStatus.loading => _buildLoadingState(theme, colorScheme, l10n),
            NearbyStatus.loaded => _buildEmptyState(theme, colorScheme, l10n),
            NearbyStatus.error => _buildErrorState(theme, colorScheme, l10n),
          },
        ],
      ),
    );
  }

  Widget _buildIdleState(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.near_me, size: 18),
            label: Text(l10n.expandSearch),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.expandSearchHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null,
        icon: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        label: Text(l10n.expandSearch),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          isRidesMode
              ? l10n.noNearbyRidesFound
              : l10n.noNearbyRequestsFound,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.retry,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onTap,
          child: Text(l10n.retry),
        ),
      ],
    );
  }
}
