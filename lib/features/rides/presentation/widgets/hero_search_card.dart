import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_criteria_provider.dart';
import 'search_label.dart';
import 'search_sheet.dart';

/// Large hero search surface displayed at the center of [RidesHomeScreen].
///
/// Watches [searchCriteriaProvider] and shows a dynamic label:
/// - Empty: "Where to?"
/// - Partial: "From X" or "To Y"
/// - Full: "X → Y" with a swap icon
///
/// Tapping anywhere opens the search sheet.
class HeroSearchCard extends ConsumerWidget {
  const HeroSearchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final origin = criteria.origin;
    final destination = criteria.destination;
    final hasBoth = origin != null && destination != null;
    final hasAny = origin != null || destination != null;

    final label = buildSearchLabel(
      originName: origin?.name,
      destinationName: destination?.name,
    );

    return Semantics(
      button: true,
      label: 'Search for rides. $label',
      child: Material(
        color: colorScheme.surface,
        elevation: 10,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () => showSearchSheet(context),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.search, color: colorScheme.primary, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: hasAny
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasBoth)
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: colorScheme.primary),
                    onPressed: () {
                      ref
                          .read(searchCriteriaProvider.notifier)
                          .swapOriginDestination();
                    },
                    tooltip: 'Swap origin and destination',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
