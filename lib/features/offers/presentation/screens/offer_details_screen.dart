import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';
import '../providers/offer_detail_provider.dart';
import '../widgets/offer_bottom_bar.dart';
import '../widgets/offer_master_card.dart';
import '../widgets/offer_person_section.dart';

/// Unified details screen for any offer kind (ride or seat).
class OfferDetailsScreen extends ConsumerWidget {
  final OfferKey offerKey;

  const OfferDetailsScreen({super.key, required this.offerKey});

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
          body: _OfferDetailsBody(offer: offer),
          bottomNavigationBar: offer.user != null
              ? OfferBottomBar(offer: offer)
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
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _OfferDetailsBody extends StatelessWidget {
  final OfferUiModel offer;

  const _OfferDetailsBody({required this.offer});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OfferMasterCard(offer: offer),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        if (offer.user != null)
          SliverToBoxAdapter(
            child: OfferPersonSection(
              user: offer.user!,
              description: offer.description,
              offerKind: offer.offerKey.kind,
              isExternalSource: offer.isExternalSource,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
}
