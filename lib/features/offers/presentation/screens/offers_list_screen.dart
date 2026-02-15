import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../routes/routes.dart';
import '../../../rides/presentation/providers/paginated_rides_provider.dart';
import '../../../rides/presentation/providers/search_criteria_provider.dart';
import '../../../rides/presentation/providers/search_mode_provider.dart';
import '../../../rides/presentation/widgets/date_strip.dart';
import '../../../rides/presentation/widgets/mode_segment_bar.dart';
import '../../../rides/presentation/widgets/ride_skeleton.dart';
import '../../../rides/presentation/widgets/search_summary_bar.dart';
import '../../../seats/create/domain/seat_prefill.dart';
import '../../../seats/presentation/providers/paginated_seats_provider.dart';
import '../../domain/offer_ui_model.dart';
import '../providers/nearby_offers_provider.dart';
import '../providers/nudge_dismissed_provider.dart';
import '../widgets/expand_search_block.dart';
import '../widgets/nearby_section_header.dart';
import '../widgets/offer_card.dart';
import '../widgets/paginated_sliver_list.dart';
import '../widgets/post_request_nudge_card.dart';
import '../widgets/zero_results_funnel.dart';

/// Unified list screen for both rides and seat requests.
///
/// Uses an inline [ModeSegmentBar] to switch between data sources
/// without navigation. Both providers are eager-loaded for instant switching.
class OffersListScreen extends ConsumerStatefulWidget {
  const OffersListScreen({super.key});

  @override
  ConsumerState<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends ConsumerState<OffersListScreen> {
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
    if (!_isNearBottom) return;
    final mode = ref.read(searchModeProvider);
    if (mode == SearchMode.rides) {
      ref.read(paginatedRidesProvider.notifier).loadMore();
    } else {
      ref.read(paginatedSeatsProvider.notifier).loadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  Future<void> _onRefresh() async {
    final mode = ref.read(searchModeProvider);
    if (mode == SearchMode.rides) {
      await ref.read(paginatedRidesProvider.notifier).refresh();
    } else {
      await ref.read(paginatedSeatsProvider.notifier).refresh();
    }
  }

  void _triggerNearbySearch() {
    final mode = ref.read(searchModeProvider);
    final exactKeys = (mode == SearchMode.rides
            ? ref.read(paginatedRidesProvider).rides
            : ref.read(paginatedSeatsProvider).offers)
        .map((o) => o.offerKey.toRouteParam())
        .toSet();
    ref
        .read(nearbyOffersProvider.notifier)
        .searchNearby(exactOfferKeys: exactKeys);
  }

  void _navigateToPostSeat() {
    final criteria = ref.read(searchCriteriaProvider);
    context.pushNamed(
      RouteNames.postSeat,
      extra: SeatPrefill(
        origin: criteria.origin,
        destination: criteria.destination,
        date: criteria.departureDate,
      ),
    );
  }

  void _navigateToOfferDetails(OfferUiModel offer) {
    context.pushNamed(
      RouteNames.offerDetails,
      pathParameters: {'offerKey': offer.offerKey.toRouteParam()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(searchModeProvider);
    final l10n = context.l10n;

    // Eager-load both providers so counts are available for segment badges.
    final ridesState = ref.watch(paginatedRidesProvider);
    final seatsState = ref.watch(paginatedSeatsProvider);

    // Select data for the active mode.
    final List<OfferUiModel> items;
    final bool isLoading;
    final bool hasMore;
    final Object? error;
    final IconData emptyIcon;
    final String emptyMessage;

    final criteria = ref.watch(searchCriteriaProvider);
    final nudgeDismissed = ref.watch(nudgeDismissedProvider);
    final nearbyState = ref.watch(nearbyOffersProvider);

    if (mode == SearchMode.rides) {
      items = ridesState.rides;
      isLoading = ridesState.isLoading;
      hasMore = ridesState.hasMore;
      error = ridesState.error;
      emptyIcon = Icons.directions_car_outlined;
      emptyMessage = l10n.noRidesFound;
    } else {
      items = seatsState.offers;
      isLoading = seatsState.isLoading;
      hasMore = seatsState.hasMore;
      error = seatsState.error;
      emptyIcon = Icons.people_outline;
      emptyMessage = l10n.noPassengerRequests;
    }

    final isRidesMode = mode == SearchMode.rides;
    final canSearchNearby =
        criteria.origin != null && criteria.destination != null;
    final exactCount = items.length;

    // Show expand sliver after exact items (1-2 results, not in empty state)
    final showExpandSliver = canSearchNearby &&
        exactCount > 0 &&
        exactCount < 3 &&
        !isLoading &&
        nearbyState.status != NearbyStatus.loaded;

    // Nudge card: show when there are items (exact or nearby) in rides mode
    final showNudge = isRidesMode && !nudgeDismissed && items.isNotEmpty;

    // Show nearby results as separate section
    final hasNearbyResults = nearbyState.status == NearbyStatus.loaded &&
        nearbyState.offers.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              title: const SearchSummaryBar(),
              toolbarHeight: 64,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    const ModeSegmentBar(),
                    const SizedBox(height: 4),
                    const DateStrip(),
                  ],
                ),
              ),
            ),

            // Main exact results
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: PaginatedSliverList(
                items: items,
                isLoading: isLoading,
                hasMore: hasMore,
                error: error,
                onRetry: _onRefresh,
                emptyIcon: emptyIcon,
                emptyMessage: emptyMessage,
                loadingWidget: const RideSkeletonList(),
                emptyBuilder: isRidesMode
                    ? (context) => ZeroResultsFunnel(
                          originName: criteria.origin?.name,
                          destinationName: criteria.destination?.name,
                          dateLabel: criteria.departureDate != null
                              ? l10n.dateStripDate(criteria.departureDate!)
                              : null,
                          onPostRequest: _navigateToPostSeat,
                          onExpandSearch:
                              canSearchNearby ? _triggerNearbySearch : null,
                          nearbyStatus: nearbyState.status,
                          isRidesMode: isRidesMode,
                        )
                    : null,
                itemBuilder: (context, offer) {
                  return OfferCard(
                    offer: offer,
                    onTap: () => _navigateToOfferDetails(offer),
                  );
                },
              ),
            ),

            // Expand search block (for 1-2 results case)
            if (showExpandSliver)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpandSearchBlock(
                    status: nearbyState.status,
                    onTap: _triggerNearbySearch,
                    isRidesMode: isRidesMode,
                  ),
                ),
              ),

            // Nearby results section (header + cards)
            if (hasNearbyResults)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: nearbyState.offers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return const NearbySectionHeader();
                    final entry = nearbyState.offers[index - 1];
                    return OfferCard(
                      offer: entry.offer,
                      onTap: () => _navigateToOfferDetails(entry.offer),
                      originDistanceHint: entry.originDistanceKm != null
                          ? l10n.distanceHint(
                              entry.originDistanceKm!.round())
                          : null,
                      destinationDistanceHint:
                          entry.destinationDistanceKm != null
                              ? l10n.distanceHint(
                                  entry.destinationDistanceKm!.round())
                              : null,
                    );
                  },
                ),
              ),

            // Nudge card — always last
            if (showNudge)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PostRequestNudgeCard(
                    originName: criteria.origin?.name,
                    destinationName: criteria.destination?.name,
                    dateLabel: criteria.departureDate != null
                        ? l10n.dateStripDate(criteria.departureDate!)
                        : null,
                    onTap: _navigateToPostSeat,
                    onDismissed: () {
                      ref.read(nudgeDismissedProvider.notifier).dismiss();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
