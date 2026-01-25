import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/launchers.dart';
import '../../domain/ride_ui_model.dart';
import '../providers/rides_providers.dart';
import '../providers/search_criteria_provider.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_skeleton.dart';
import '../widgets/search_filter_bar.dart';

/// Screen displaying list of rides with search/filter functionality.
///
/// Pure Riverpod - uses ConsumerWidget, no old Provider dependencies.
class RidesListScreen extends ConsumerWidget {
  const RidesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Ride'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            onPressed: () {
              ref.read(searchCriteriaProvider.notifier).clear();
            },
            tooltip: 'Clear filters',
          ),
        ],
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(
            child: ridesAsync.when(
              loading: () => const RideSkeletonList(),
              error: (error, stack) => _buildErrorWidget(context, ref, error),
              data: (rides) => _buildRidesList(context, ref, rides),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(
    BuildContext context,
    WidgetRef ref,
    List<RideUiModel> rides,
  ) {
    if (rides.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No rides found matching your criteria.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ridesSearchProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return RideCard(
            ride: ride,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/rides/details',
                arguments: ride.id,
              );
            },
            onCtaTap: () => _handleCtaAction(context, ride),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading rides',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(ridesSearchProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCtaAction(BuildContext context, RideUiModel ride) {
    if (ride.hasDriverPhone) {
      Launchers.makePhoneCall(ride.driverPhone!);
    } else if (ride.hasExternalUrl) {
      Launchers.openUrl(ride.externalUrl!);
    }
  }
}
