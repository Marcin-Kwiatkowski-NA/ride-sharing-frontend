import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// Conversion funnel shown when ride search returns zero results.
///
/// Displays a secondary "no rides found" message plus a prominent card
/// that nudges the user to post a seat request pre-filled with their
/// search criteria.
class ZeroResultsFunnel extends StatelessWidget {
  final String? originName;
  final String? destinationName;
  final String? dateLabel;
  final VoidCallback onPostRequest;

  const ZeroResultsFunnel({
    super.key,
    this.originName,
    this.destinationName,
    this.dateLabel,
    required this.onPostRequest,
  });

  String _buildSubtext() {
    final hasOrigin = originName != null && originName!.isNotEmpty;
    final hasDestination = destinationName != null && destinationName!.isNotEmpty;
    final hasDate = dateLabel != null && dateLabel!.isNotEmpty;

    if (hasOrigin && hasDestination && hasDate) {
      return 'Post a request for $originName to $destinationName on $dateLabel.';
    }
    if (hasOrigin && hasDestination) {
      return 'Post a request for $originName to $destinationName.';
    }
    if (hasOrigin && hasDate) {
      return 'Post a request from $originName on $dateLabel.';
    }
    if (hasOrigin) {
      return 'Post a request from $originName and let drivers find you.';
    }
    return 'Post a request for your route and let drivers find you.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No rides found',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: AppTokens.elevationLow,
              color: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLG),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't wait. Let drivers find you.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _buildSubtext(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onPostRequest,
                        style: tokens.brandCtaStyle,
                        child: const Text('Post Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
