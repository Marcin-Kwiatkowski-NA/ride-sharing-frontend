import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../core/locations/domain/location.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../routes/routes.dart';
import '../../../../offers/domain/offer_ui_model.dart';
import '../../../../offers/presentation/widgets/offer_card.dart';
import '../providers/smart_match_provider.dart';

/// Shows the Smart Match sheet after a driver publishes a ride.
///
/// Call via [showSmartMatchSheet] which wraps this in a modal bottom sheet.
/// Returns the [OfferKey] of a tapped match, or `null` if dismissed.
void showSmartMatchSheet(
  BuildContext context, {
  required List<Location> stops,
  required DateTime departureDate,
  required int createdRideId,
}) {
  showModalBottomSheet<OfferKey>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SmartMatchWrapper(
      stops: stops,
      departureDate: departureDate,
      createdRideId: createdRideId,
    ),
  ).then((selectedMatch) {
    if (!context.mounted) return;

    // Navigate to the tapped match or fall back to the new ride.
    final targetKey = selectedMatch ??
        OfferKey(OfferKind.ride, createdRideId);
    context.goNamed(
      RouteNames.offerDetails,
      pathParameters: {'offerKey': targetKey.toRouteParam()},
    );
  });
}

class _SmartMatchWrapper extends StatelessWidget {
  final List<Location> stops;
  final DateTime departureDate;
  final int createdRideId;

  const _SmartMatchWrapper({
    required this.stops,
    required this.departureDate,
    required this.createdRideId,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return _SmartMatchContent(
          scrollController: scrollController,
          stops: stops,
          departureDate: departureDate,
          createdRideId: createdRideId,
        );
      },
    );
  }
}

class _SmartMatchContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final List<Location> stops;
  final DateTime departureDate;
  final int createdRideId;

  const _SmartMatchContent({
    required this.scrollController,
    required this.stops,
    required this.departureDate,
    required this.createdRideId,
  });

  @override
  ConsumerState<_SmartMatchContent> createState() => _SmartMatchContentState();
}

class _SmartMatchContentState extends ConsumerState<_SmartMatchContent> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final l10n = context.l10n;

    final matchesAsync = ref.watch(smartMatchProvider(
      stops: widget.stops,
      departureDate: widget.departureDate,
    ));

    final dateLabel = DateFormat('EEE, d MMM').format(widget.departureDate);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusXL),
        ),
        border: Border(
          top: BorderSide(color: tokens.overlayBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.overlayScrim,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.overlayDragHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Success header
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.smartMatchRideLive,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route summary
          Text(
            l10n.smartMatchRouteSummary(
              widget.stops.map((s) => s.name).join(' \u2192 '),
              dateLabel,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Subheading
          Text(
            l10n.smartMatchHeading,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Matches content
          matchesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.smartMatchError,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            data: (matches) {
              if (matches.isEmpty) {
                return _buildEmptyMatches(theme, colorScheme, l10n);
              }
              return _buildMatchesList(matches, theme, colorScheme, l10n);
            },
          ),

          const SizedBox(height: 24),

          // Footer CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.smartMatchViewRide),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
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
    List<OfferUiModel> matches,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final displayCount = _showAll ? matches.length : matches.length.clamp(0, 3);
    final hasMore = matches.length > 3 && !_showAll;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayCount; i++)
          OfferCard(
            offer: matches[i],
            onTap: () {
              Navigator.of(context).pop(matches[i].offerKey);
            },
          ),
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