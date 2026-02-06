import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_criteria_provider.dart';
import 'search_sheet.dart';

/// Hero search capsule displayed on the RidesHomeScreen.
///
/// Watches committed [searchCriteriaProvider] state and displays:
/// - Empty: "Where to go?" + search icon
/// - Partial: "From X" or "To Y" + optional date chip
/// - Full: "X → Y" + swap icon + date/time chip row
class SearchCapsule extends ConsumerWidget {
  const SearchCapsule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final origin = criteria.origin;
    final destination = criteria.destination;
    final hasBoth = origin != null && destination != null;
    final hasAny = origin != null || destination != null;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: const StadiumBorder(),
      elevation: 2,
      child: InkWell(
        onTap: () => showSearchSheet(context),
        customBorder: const StadiumBorder(),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _buildLabel(origin?.name, destination?.name),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: hasAny
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasBoth)
                IconButton(
                  icon: Icon(
                    Icons.swap_horiz,
                    color: colorScheme.primary,
                  ),
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
    );
  }

  String _buildLabel(String? originName, String? destName) {
    if (originName != null && destName != null) {
      return '$originName → $destName';
    } else if (originName != null) {
      return 'From $originName';
    } else if (destName != null) {
      return 'To $destName';
    }
    return 'Where to go?';
  }
}
