import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../../offers/presentation/widgets/offer_card.dart';
import '../../../offers/presentation/widgets/paginated_sliver_list.dart';
import '../../../rides/presentation/widgets/compact_search_capsule.dart';
import '../../../rides/presentation/widgets/date_strip.dart';
import '../../../rides/presentation/widgets/ride_skeleton.dart';
import '../providers/paginated_seats_provider.dart';

/// Screen displaying list of seat requests with pinned sliver header,
/// date strip, and infinite scroll.
class SeatsListScreen extends ConsumerStatefulWidget {
  const SeatsListScreen({super.key});

  @override
  ConsumerState<SeatsListScreen> createState() => _SeatsListScreenState();
}

class _SeatsListScreenState extends ConsumerState<SeatsListScreen> {
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
      ref.read(paginatedSeatsProvider.notifier).loadMore();
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
    final seatsState = ref.watch(paginatedSeatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(paginatedSeatsProvider.notifier).refresh();
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
                  onPressed: null,
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
                items: seatsState.offers,
                isLoading: seatsState.isLoading,
                hasMore: seatsState.hasMore,
                error: seatsState.error,
                onRetry: () {
                  ref.read(paginatedSeatsProvider.notifier).refresh();
                },
                emptyIcon: Icons.people_outline,
                emptyMessage:
                    'No passenger requests found matching your criteria.',
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
