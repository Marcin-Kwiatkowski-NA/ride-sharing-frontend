import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../../offers/presentation/widgets/offer_card.dart';
import '../../../offers/presentation/widgets/paginated_sliver_list.dart';
import '../providers/paginated_rides_provider.dart';
import '../widgets/compact_search_capsule.dart';
import '../widgets/date_strip.dart';
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: PaginatedSliverList(
                items: ridesState.rides,
                isLoading: ridesState.isLoading,
                hasMore: ridesState.hasMore,
                error: ridesState.error,
                onRetry: () {
                  ref.read(paginatedRidesProvider.notifier).refresh();
                },
                emptyIcon: Icons.directions_car_outlined,
                emptyMessage: 'No rides found matching your criteria.',
                loadingWidget: const RideSkeletonList(),
                itemBuilder: (context, offer) {
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
            ),
          ],
        ),
      ),
    );
  }
}
