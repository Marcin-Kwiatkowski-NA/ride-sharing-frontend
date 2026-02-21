import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../routes/routes.dart';
import '../../data/dto/draft_search_criteria.dart';
import '../../data/dto/recent_search_snapshot.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_criteria_provider.dart';
import '../providers/search_mode_provider.dart';
import '../../../seats/presentation/providers/paginated_seats_provider.dart';

/// Vertical list of recent searches displayed below the [HeroSearchCard].
///
/// Watches [recentSearchesProvider] for persisted history.
/// Hidden when empty (new user / no searches yet).
class RecentSearchesList extends ConsumerWidget {
  const RecentSearchesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSearches = ref.watch(recentSearchesProvider);

    return asyncSearches.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (searches) {
        if (searches.isEmpty) return const SizedBox.shrink();

        final visible = searches.take(3).toList();
        final colorScheme = Theme.of(context).colorScheme;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < visible.length; i++) ...[
                _SearchRow(snapshot: visible[i]),
                if (i < visible.length - 1)
                  Divider(
                    color: colorScheme.outlineVariant,
                    height: 1,
                    indent: 48,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchRow extends ConsumerWidget {
  final RecentSearchSnapshot snapshot;

  const _SearchRow({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _onTap(context, ref),
      borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.history, color: colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                snapshot.displayLabel,
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

  void _onTap(BuildContext context, WidgetRef ref) {
    final draft = DraftSearchCriteria.fromSnapshot(snapshot);
    ref.read(searchCriteriaProvider.notifier).commitDraft(draft);
    ref.invalidate(paginatedRidesProvider);
    ref.invalidate(paginatedSeatsProvider);
    ref.read(searchModeProvider.notifier).setMode(snapshot.mode);
    ref.read(recentSearchesProvider.notifier).addSearch(snapshot);
    context.goNamed(RouteNames.ridesList);
  }
}
