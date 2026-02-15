import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../providers/nearby_offers_provider.dart';
import 'expand_search_block.dart';

/// Conversion funnel shown when ride search returns zero results.
///
/// Displays a secondary "no rides found" message plus a prominent card
/// that nudges the user to post a seat request pre-filled with their
/// search criteria. Optionally shows an "Expand search" block as a
/// secondary action when proximity search is available.
class ZeroResultsFunnel extends StatelessWidget {
  final String? originName;
  final String? destinationName;
  final String? dateLabel;
  final VoidCallback onPostRequest;
  final VoidCallback? onExpandSearch;
  final NearbyStatus nearbyStatus;
  final bool isRidesMode;

  const ZeroResultsFunnel({
    super.key,
    this.originName,
    this.destinationName,
    this.dateLabel,
    required this.onPostRequest,
    this.onExpandSearch,
    this.nearbyStatus = NearbyStatus.idle,
    this.isRidesMode = true,
  });

  String _buildSubtext(BuildContext context) {
    final hasOrigin = originName != null && originName!.isNotEmpty;
    final hasDestination = destinationName != null && destinationName!.isNotEmpty;
    final hasDate = dateLabel != null && dateLabel!.isNotEmpty;

    if (hasOrigin && hasDestination && hasDate) {
      return context.l10n.zeroResultsRouteDate(originName!, destinationName!, dateLabel!);
    }
    if (hasOrigin && hasDestination) {
      return context.l10n.zeroResultsRoute(originName!, destinationName!);
    }
    if (hasOrigin && hasDate) {
      return context.l10n.zeroResultsOriginDate(originName!, dateLabel!);
    }
    if (hasOrigin) {
      return context.l10n.zeroResultsOrigin(originName!);
    }
    return context.l10n.zeroResultsGeneric;
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
              context.l10n.noRidesFoundShort,
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
                      context.l10n.zeroResultsHeadline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _buildSubtext(context),
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
                        child: Text(context.l10n.postRequest),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onExpandSearch != null) ...[
              const SizedBox(height: 24),
              ExpandSearchBlock(
                status: nearbyStatus,
                onTap: onExpandSearch,
                isRidesMode: isRidesMode,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
