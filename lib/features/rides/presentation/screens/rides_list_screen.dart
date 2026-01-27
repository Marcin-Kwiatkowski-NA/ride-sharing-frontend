import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/launchers.dart';
import '../../domain/ride_ui_model.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/search_criteria_provider.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_skeleton.dart';
import '../widgets/search_filter_bar.dart';

/// Screen displaying list of rides with search/filter and infinite scroll.
class RidesListScreen extends ConsumerStatefulWidget {
  const RidesListScreen({super.key});

  @override
  ConsumerState<RidesListScreen> createState() => _RidesListScreenState();
}

class _RidesListScreenState extends ConsumerState<RidesListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref.read(paginatedRidesProvider.notifier).loadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger when 200px from bottom
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    final ridesState = ref.watch(paginatedRidesProvider);

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
            child: _buildBody(context, ridesState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PaginatedRidesState state) {
    // Show skeleton only on initial load
    if (state.isLoading && state.rides.isEmpty) {
      return const RideSkeletonList();
    }

    // Show error with retry
    if (state.error != null && state.rides.isEmpty) {
      return _buildErrorWidget(context, state.error!);
    }

    // Show empty state
    if (!state.isLoading && state.rides.isEmpty) {
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

    return _buildRidesList(context, state);
  }

  Widget _buildRidesList(BuildContext context, PaginatedRidesState state) {
    final rides = state.rides;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(paginatedRidesProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        // Add 1 for loading indicator when loading more
        itemCount: state.hasMore ? rides.length + 1 : rides.length,
        itemBuilder: (context, index) {
          // Loading indicator at the bottom
          if (index >= rides.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

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

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
                ref.read(paginatedRidesProvider.notifier).refresh();
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
    switch (ride.ctaType) {
      case CtaType.phone:
        Launchers.makePhoneCall(ride.driverPhone!);
      case CtaType.link:
        Launchers.openUrl(ride.sourceUrl!);
      case CtaType.disabled:
        break; // should not reach here if button is disabled
    }
  }
}
