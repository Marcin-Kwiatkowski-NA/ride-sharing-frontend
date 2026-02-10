import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../providers/search_criteria_provider.dart';
import 'search_label.dart';
import 'search_sheet.dart';

/// Full-width search bar that displays the route direction summary
/// and opens the [SearchSheet] on tap.
///
/// Built as a custom tappable surface (not a real input field) so no
/// cursor or keyboard ever appears.
class SearchSummaryBar extends ConsumerWidget {
  const SearchSummaryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final label = buildSearchLabel(
      originName: criteria.origin?.name,
      destinationName: criteria.destination?.name,
      l10n: context.l10n,
      emptyLabelOverride: context.l10n.whereAreYouGoing,
    );
    final hasRoute = criteria.origin != null || criteria.destination != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => showSearchSheet(context),
      child: Material(
        elevation: 6,
        color: colorScheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: hasRoute
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.tune, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
