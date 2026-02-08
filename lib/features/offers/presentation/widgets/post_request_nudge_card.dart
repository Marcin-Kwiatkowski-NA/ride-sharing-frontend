import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// Nudge card shown at the end of ride search results, prompting users
/// to post a seat request when existing results don't fit.
///
/// Wrapped in [Dismissible] — swipe horizontally to permanently hide
/// for the session.
class PostRequestNudgeCard extends StatelessWidget {
  final String? originName;
  final String? destinationName;
  final String? dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const PostRequestNudgeCard({
    super.key,
    this.originName,
    this.destinationName,
    this.dateLabel,
    required this.onTap,
    required this.onDismissed,
  });

  String _buildCopy() {
    final hasOrigin = originName != null && originName!.isNotEmpty;
    final hasDestination = destinationName != null && destinationName!.isNotEmpty;
    final hasDate = dateLabel != null && dateLabel!.isNotEmpty;

    if (hasOrigin && hasDestination) {
      return 'Need a different time for $originName \u2192 $destinationName?';
    }
    if (hasDate) {
      return 'Nothing on $dateLabel? Post your own request.';
    }
    return 'Not finding what you need? Post a request and let drivers come to you.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: const ValueKey('post_request_nudge'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
          side: BorderSide(
            color: colorScheme.tertiary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.only(top: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  color: colorScheme.tertiary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _buildCopy(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Post a request',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
