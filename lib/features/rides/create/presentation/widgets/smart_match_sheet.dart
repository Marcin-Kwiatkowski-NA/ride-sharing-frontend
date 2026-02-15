import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/locations/domain/location.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../routes/routes.dart';
import '../../../../offers/domain/offer_ui_model.dart';
import '../../../../offers/presentation/widgets/offer_card.dart';
import '../providers/smart_match_provider.dart';

/// Shows the Smart Match sheet after a driver publishes a ride.
///
/// Call via [showSmartMatchSheet] which wraps this in a modal bottom sheet.
void showSmartMatchSheet(
  BuildContext context, {
  required Location origin,
  required Location destination,
  required DateTime departureDate,
  required int createdRideId,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SmartMatchWrapper(
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      createdRideId: createdRideId,
    ),
  ).then((_) {
    if (context.mounted) {
      final offerKey = OfferKey(OfferKind.ride, createdRideId);
      context.goNamed(
        RouteNames.offerDetails,
        pathParameters: {'offerKey': offerKey.toRouteParam()},
      );
    }
  });
}

class _SmartMatchWrapper extends StatelessWidget {
  final Location origin;
  final Location destination;
  final DateTime departureDate;
  final int createdRideId;

  const _SmartMatchWrapper({
    required this.origin,
    required this.destination,
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
          origin: origin,
          destination: destination,
          departureDate: departureDate,
          createdRideId: createdRideId,
        );
      },
    );
  }
}

class _SmartMatchContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Location origin;
  final Location destination;
  final DateTime departureDate;
  final int createdRideId;

  const _SmartMatchContent({
    required this.scrollController,
    required this.origin,
    required this.destination,
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

    final matchesAsync = ref.watch(smartMatchProvider(
      origin: widget.origin,
      destination: widget.destination,
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
                'Your ride is live!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route summary
          Text(
            '${widget.origin.name} \u2192 ${widget.destination.name} on $dateLabel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Subheading
          Text(
            'Matching passenger requests',
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
                'Could not load matching requests.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            data: (matches) {
              if (matches.isEmpty) {
                return _buildEmptyMatches(theme, colorScheme);
              }
              return _buildMatchesList(matches, theme, colorScheme);
            },
          ),

          const SizedBox(height: 24),

          // Footer CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('View your ride'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches(ThemeData theme, ColorScheme colorScheme) {
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
            'No passengers looking for this route yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Check back on your ride details later.',
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
              Navigator.of(context).pop();
              context.pushNamed(
                RouteNames.offerDetails,
                pathParameters: {
                  'offerKey': matches[i].offerKey.toRouteParam(),
                },
              );
            },
          ),
        if (hasMore)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showAll = true),
              child: Text('See all ${matches.length} requests'),
            ),
          ),
      ],
    );
  }
}
