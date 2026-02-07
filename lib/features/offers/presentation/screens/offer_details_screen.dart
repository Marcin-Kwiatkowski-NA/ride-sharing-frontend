import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../domain/offer_ui_model.dart';
import '../providers/offer_detail_provider.dart';
import '../widgets/offer_bottom_bar.dart';
import '../widgets/offer_description_section.dart';
import '../widgets/offer_money_count_section.dart';
import '../widgets/offer_route_header.dart';
import '../widgets/offer_user_section.dart';
import '../widgets/offer_when_section.dart';

/// Unified details screen for any offer kind (ride or seat).
class OfferDetailsScreen extends ConsumerWidget {
  final OfferKey offerKey;

  const OfferDetailsScreen({super.key, required this.offerKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(offerKey));

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: offerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(offerDetailProvider(offerKey)),
        ),
        data: (offer) => _OfferDetailsBody(offer: offer),
      ),
      bottomNavigationBar: offerAsync.whenOrNull(
        data: (offer) => OfferBottomBar(offer: offer),
      ),
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
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfferRouteHeader(offer: offer),
          const SizedBox(height: 24),
          OfferWhenSection(offer: offer),
          const SizedBox(height: 24),
          OfferMoneyCountSection(offer: offer),
          if (offer.description != null && offer.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            OfferDescriptionSection(description: offer.description!),
          ],
          if (offer.user != null) ...[
            const SizedBox(height: 24),
            OfferUserSection(user: offer.user!),
          ],
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
}
