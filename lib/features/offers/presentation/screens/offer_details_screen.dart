import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../booking/presentation/widgets/booking_sheet.dart';
import '../../../rides/details/presentation/widgets/smart_matches_section.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';
import '../providers/offer_detail_provider.dart';
import '../widgets/offer_bottom_bar.dart';
import '../widgets/offer_master_card.dart';
import '../widgets/offer_person_section.dart';

/// Unified details screen for any offer kind (ride or seat).
class OfferDetailsScreen extends ConsumerWidget {
  final OfferKey offerKey;
  final bool showSmartMatches;

  const OfferDetailsScreen({
    super.key,
    required this.offerKey,
    this.showSmartMatches = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(offerKey));

    return offerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(offerDetailProvider(offerKey)),
        ),
      ),
      data: (offer) {
        final strings = OfferDetailsStrings(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.screenTitle(offer.offerKey.kind)),
          ),
          body: PageLayout(
            child: _OfferDetailsBody(
              offer: offer,
              showSmartMatches: showSmartMatches,
            ),
          ),
          bottomNavigationBar: offer.user != null
              ? OfferBottomBar(
                  offer: offer,
                  onBookTap: () => showBookingSheet(
                    context,
                    offer: offer,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final failure = ErrorMapper.map(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(failure.message),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _OfferDetailsBody extends StatelessWidget {
  final OfferUiModel offer;
  final bool showSmartMatches;

  const _OfferDetailsBody({
    required this.offer,
    this.showSmartMatches = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.list(
            children: [
              OfferMasterCard(offer: offer),
              if (offer.user != null) ...[
                const SizedBox(height: 16),
                OfferPersonSection(
                  user: offer.user!,
                  description: offer.description,
                  offerKind: offer.offerKey.kind,
                  isExternalSource: offer.isExternalSource,
                ),
              ],
              if (showSmartMatches && offer.offerKey.kind == OfferKind.ride) ...[
                const SizedBox(height: 16),
                SmartMatchesSection(rideId: offer.offerKey.id),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
