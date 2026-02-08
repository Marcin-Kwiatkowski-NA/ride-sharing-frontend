import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../widgets/offer_card.dart';
import '../providers/nudge_dismissed_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(searchModeProvider);

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

    if (mode == SearchMode.rides) {
      items = ridesState.rides;
      isLoading = ridesState.isLoading;
      hasMore = ridesState.hasMore;
      error = ridesState.error;
      emptyIcon = Icons.directions_car_outlined;
      emptyMessage = 'No rides found matching your criteria.';
    } else {
      items = seatsState.offers;
      isLoading = seatsState.isLoading;
      hasMore = seatsState.hasMore;
      error = seatsState.error;
      emptyIcon = Icons.people_outline;
      emptyMessage = 'No passenger requests found matching your criteria.';
    }

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
                trailingWidget: mode == SearchMode.rides && !nudgeDismissed
                    ? PostRequestNudgeCard(
                        originName: criteria.origin?.name,
                        destinationName: criteria.destination?.name,
                        dateLabel: criteria.departureDate != null
                            ? DateFormat('EEE, d MMM')
                                .format(criteria.departureDate!)
                            : null,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.postSeat,
                            extra: SeatPrefill(
                              origin: criteria.origin,
                              destination: criteria.destination,
                              date: criteria.departureDate,
                            ),
                          );
                        },
                        onDismissed: () {
                          ref
                              .read(nudgeDismissedProvider.notifier)
                              .dismiss();
                        },
                      )
                    : null,
                emptyBuilder: mode == SearchMode.rides
                    ? (context) => ZeroResultsFunnel(
                          originName: criteria.origin?.name,
                          destinationName: criteria.destination?.name,
                          dateLabel: criteria.departureDate != null
                              ? DateFormat('EEE, d MMM')
                                  .format(criteria.departureDate!)
                              : null,
                          onPostRequest: () {
                            context.pushNamed(
                              RouteNames.postSeat,
                              extra: SeatPrefill(
                                origin: criteria.origin,
                                destination: criteria.destination,
                                date: criteria.departureDate,
                              ),
                            );
                          },
                        )
                    : null,
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
