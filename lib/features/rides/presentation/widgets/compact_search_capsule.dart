import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_criteria_provider.dart';
import 'search_sheet.dart';

/// Compact single-line search capsule for the rides list header.
///
/// Watches committed [searchCriteriaProvider] and displays a summary label.
/// Tapping opens the [SearchSheet].
class CompactSearchCapsule extends ConsumerWidget {
  const CompactSearchCapsule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(searchCriteriaProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => showSearchSheet(context),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _buildLabel(
                    criteria.origin?.name,
                    criteria.destination?.name,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
    return 'All rides';
  }
}
