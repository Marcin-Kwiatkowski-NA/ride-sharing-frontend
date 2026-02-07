import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../domain/offer_ui_model.dart';
import '../providers/my_offers_provider.dart';
import '../widgets/offer_card.dart';

enum _OfferFilter { all, rides, passengers }

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  _OfferFilter _filter = _OfferFilter.all;

  List<OfferUiModel> _applyFilter(List<OfferUiModel> offers) {
    return switch (_filter) {
      _OfferFilter.all => offers,
      _OfferFilter.rides =>
        offers.where((o) => o.offerKey.kind == OfferKind.ride).toList(),
      _OfferFilter.passengers =>
        offers.where((o) => o.offerKey.kind == OfferKind.seat).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offersAsync = ref.watch(myOffersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<_OfferFilter>(
              segments: const [
                ButtonSegment(
                  value: _OfferFilter.all,
                  label: Text('All'),
                ),
                ButtonSegment(
                  value: _OfferFilter.rides,
                  label: Text('Rides'),
                  icon: Icon(Icons.directions_car_outlined),
                ),
                ButtonSegment(
                  value: _OfferFilter.passengers,
                  label: Text('Passengers'),
                  icon: Icon(Icons.people_outline),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selected) {
                setState(() => _filter = selected.first);
              },
            ),
          ),

          // List
          Expanded(
            child: offersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load offers',
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => ref.invalidate(myOffersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (allOffers) {
                final filtered = _applyFilter(allOffers);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No offers yet',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(myOffersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final offer = filtered[index];
                      return OfferCard(
                        offer: offer,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.offerDetails,
                            pathParameters: {
                              'offerKey': offer.offerKey.toRouteParam(),
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
