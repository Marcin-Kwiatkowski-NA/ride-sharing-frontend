import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/dto/search_criteria_dto.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/search_criteria_provider.dart';
import '../widgets/day_switcher.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_skeleton.dart';

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
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    final ridesState = ref.watch(paginatedRidesProvider);
    final criteria = ref.watch(searchCriteriaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_buildTitle(criteria)),
      ),
      body: Column(
        children: [
          const DaySwitcher(),
          Expanded(
            child: _buildBody(context, ridesState),
          ),
        ],
      ),
    );
  }

  String _buildTitle(SearchCriteriaDto criteria) {
    final origin = criteria.originCityName;
    final dest = criteria.destinationCityName;

    if (origin?.isNotEmpty == true && dest?.isNotEmpty == true) {
      return '$origin -> $dest';
    } else if (origin?.isNotEmpty == true) {
      return 'From $origin';
    } else if (dest?.isNotEmpty == true) {
      return 'To $dest';
    }
    return 'All rides';
  }

  Widget _buildBody(BuildContext context, PaginatedRidesState state) {
    if (state.isLoading && state.rides.isEmpty) {
      return const RideSkeletonList();
    }

    if (state.error != null && state.rides.isEmpty) {
      return _buildErrorWidget(context, state.error!);
    }

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
        itemCount: state.hasMore ? rides.length + 1 : rides.length,
        itemBuilder: (context, index) {
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
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    final failure = ErrorMapper.map(error);
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
              failure.message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
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
}
