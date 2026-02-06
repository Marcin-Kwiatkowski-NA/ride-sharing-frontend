import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../../../routes/routes.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/search_mode_provider.dart';
import '../widgets/compact_search_capsule.dart';
import '../widgets/date_strip.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_skeleton.dart';

/// Screen displaying list of rides with pinned sliver header, date strip,
/// and infinite scroll.
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

    // Navigate to passengers placeholder when mode switches
    ref.listen(searchModeProvider, (prev, next) {
      if (prev == next) return;
      if (next == SearchMode.passengers && mounted) {
        Future.microtask(() {
          if (mounted) {
            context.goNamed(RouteNames.passengersListPlaceholder);
          }
        });
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(paginatedRidesProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              title: const CompactSearchCapsule(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: null, // Filter placeholder
                  tooltip: 'Filters',
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: DateStrip(),
              ),
            ),
            _buildSliverBody(ridesState),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverBody(PaginatedRidesState state) {
    if (state.isLoading && state.rides.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: RideSkeletonList(),
      );
    }

    if (state.error != null && state.rides.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildErrorWidget(context, state.error!),
      );
    }

    if (!state.isLoading && state.rides.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No rides found matching your criteria.'),
            ],
          ),
        ),
      );
    }

    final rides = state.rides;
    final itemCount = state.hasMore ? rides.length + 1 : rides.length;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList.builder(
        itemCount: itemCount,
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
              context.pushNamed(
                RouteNames.rideDetails,
                pathParameters: {'rideId': '${ride.id}'},
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
