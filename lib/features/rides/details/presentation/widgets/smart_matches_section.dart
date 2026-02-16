import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../routes/routes.dart';
import '../../../../offers/presentation/widgets/offer_card.dart';
import '../../domain/smart_match_entry.dart';
import '../../providers/smart_matches_provider.dart';

/// Persistent section showing matched passenger requests for a driver's ride.
///
/// Embedded in [OfferDetailsScreen] below the ride info. Uses progressive
/// disclosure: shows top 3 matches with "See all" expansion.
class SmartMatchesSection extends ConsumerStatefulWidget {
  final int rideId;

  const SmartMatchesSection({super.key, required this.rideId});

  @override
  ConsumerState<SmartMatchesSection> createState() =>
      _SmartMatchesSectionState();
}

class _SmartMatchesSectionState extends ConsumerState<SmartMatchesSection> {
  bool _showAll = false;
  DateTime _lastChecked = DateTime.now();

  void _refresh() {
    ref.invalidate(smartMatchesProvider(widget.rideId));
    setState(() => _lastChecked = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final matchesAsync = ref.watch(smartMatchesProvider(widget.rideId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),

        // Header
        _buildHeader(theme, colorScheme, l10n, matchesAsync),
        const SizedBox(height: 12),

        // Body
        matchesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _buildError(theme, colorScheme, l10n),
          data: (matches) => matches.isEmpty
              ? _buildEmpty(theme, colorScheme, l10n)
              : _buildMatchesList(matches, theme, colorScheme, l10n),
        ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
    AsyncValue<List<SmartMatchEntry>> matchesAsync,
  ) {
    final minutesAgo =
        DateTime.now().difference(_lastChecked).inMinutes.clamp(0, 999);

    final count = matchesAsync.value?.length;
    final subtitle = matchesAsync.isLoading
        ? l10n.smartMatchHeading
        : count != null && count > 0
            ? l10n.smartMatchSubtitle(count)
            : l10n.smartMatchEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.smartMatchHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              if (!matchesAsync.isLoading && count != null && count > 0)
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: l10n.smartMatchRefreshTooltip,
              onPressed: _refresh,
              visualDensity: VisualDensity.compact,
            ),
            Text(
              l10n.smartMatchLastChecked(minutesAgo),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.smartMatchError,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: _refresh,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.smartMatchEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.smartMatchEmptyHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(
    List<SmartMatchEntry> matches,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    final displayCount =
        _showAll ? matches.length : matches.length.clamp(0, 3);
    final hasMore = matches.length > 3 && !_showAll;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayCount; i++) ...[
          _MatchCard(
            entry: matches[i],
            onTap: () {
              context.pushNamed(
                RouteNames.offerDetails,
                pathParameters: {
                  'offerKey': matches[i].offer.offerKey.toRouteParam(),
                },
              );
            },
          ),
        ],
        if (hasMore)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showAll = true),
              child: Text(l10n.smartMatchSeeAll(matches.length)),
            ),
          ),
      ],
    );
  }
}

/// A single match card with match-type chip and distance-annotated offer card.
class _MatchCard extends StatelessWidget {
  final SmartMatchEntry entry;
  final VoidCallback? onTap;

  const _MatchCard({required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: _MatchTypeChip(matchType: entry.matchType),
        ),
        OfferCard(
          offer: entry.offer,
          onTap: onTap,
          originDistanceHint: _formatDistanceHint(entry.originDistanceKm, l10n),
          destinationDistanceHint:
              _formatDistanceHint(entry.destinationDistanceKm, l10n),
        ),
      ],
    );
  }

  String? _formatDistanceHint(double? km, dynamic l10n) {
    if (km == null) return null;
    return l10n.smartMatchDistanceHint(km.round());
  }
}

/// Material 3 chip showing match type (Exact route vs Nearby).
class _MatchTypeChip extends StatelessWidget {
  final SmartMatchType matchType;

  const _MatchTypeChip({required this.matchType});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFullRoute = matchType == SmartMatchType.fullRoute;

    return ActionChip(
      label: Text(
        isFullRoute ? l10n.smartMatchExactRoute : l10n.smartMatchNearby,
      ),
      avatar: Icon(
        isFullRoute ? Icons.check_circle_outline : Icons.near_me_outlined,
        size: 16,
      ),
      onPressed: null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
