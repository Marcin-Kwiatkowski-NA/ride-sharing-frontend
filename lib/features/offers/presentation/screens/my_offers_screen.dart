import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routes/routes.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/booking_failure.dart';
import '../../../booking/domain/booking_ui_model.dart';
import '../../../booking/presentation/providers/my_bookings_provider.dart';
import '../../../booking/presentation/widgets/booking_card.dart';
import '../../../rides/presentation/widgets/publish_selection_sheet.dart';
import '../../domain/offer_ui_model.dart';
import '../../../../core/widgets/page_layout.dart';
import '../providers/my_offers_provider.dart';
import '../widgets/offer_card.dart';

enum _ActivitySegment { rides, passengers, bookings }

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  _ActivitySegment _segment = _ActivitySegment.rides;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navMyActivity)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FilledButton.icon(
        onPressed: () => showPublishSelectionSheet(context),
        icon: const Icon(Icons.add, size: 20),
        label: Text(context.l10n.post),
        style: tokens.brandCtaStyle,
      ),
      body: PageLayout(
        child: Column(
          children: [
            // Segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<_ActivitySegment>(
                segments: [
                  ButtonSegment(
                    value: _ActivitySegment.rides,
                    label: Text(context.l10n.segmentRides),
                    icon: const Icon(Icons.directions_car_outlined),
                  ),
                  ButtonSegment(
                    value: _ActivitySegment.passengers,
                    label: Text(context.l10n.segmentPassengers),
                    icon: const Icon(Icons.people_outline),
                  ),
                  ButtonSegment(
                    value: _ActivitySegment.bookings,
                    label: Text(context.l10n.segmentBookings),
                    icon: const Icon(Icons.bookmark_outline),
                  ),
                ],
                selected: {_segment},
                onSelectionChanged: (selected) {
                  setState(() => _segment = selected.first);
                },
              ),
            ),

            // Content — IndexedStack preserves scroll positions
            Expanded(
              child: IndexedStack(
                index: _segment.index,
                children: [
                  _RidesSegment(key: const PageStorageKey('my-rides')),
                  _PassengersSegment(
                    key: const PageStorageKey('my-passengers'),
                  ),
                  _BookingsSegment(
                    key: const PageStorageKey('my-bookings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rides Segment ────────────────────────────────────────────────────────────

class _RidesSegment extends ConsumerWidget {
  const _RidesSegment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);

    return offersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorBody(
        onRetry: () => ref.invalidate(myOffersProvider),
      ),
      data: (allOffers) {
        final rides = allOffers
            .where((o) => o.offerKey.kind == OfferKind.ride)
            .toList();

        if (rides.isEmpty) {
          return _EmptyBody(
            icon: Icons.directions_car_outlined,
            message: context.l10n.noOffersYet,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myOffersProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final offer = rides[index];
              return OfferCard(
                offer: offer,
                onTap: () {
                  context.pushNamed(
                    RouteNames.myOfferDetails,
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
    );
  }
}

// ── Passengers Segment ───────────────────────────────────────────────────────

class _PassengersSegment extends ConsumerWidget {
  const _PassengersSegment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);

    return offersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorBody(
        onRetry: () => ref.invalidate(myOffersProvider),
      ),
      data: (allOffers) {
        final seats = allOffers
            .where((o) => o.offerKey.kind == OfferKind.seat)
            .toList();

        if (seats.isEmpty) {
          return _EmptyBody(
            icon: Icons.people_outline,
            message: context.l10n.noOffersYet,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myOffersProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: seats.length,
            itemBuilder: (context, index) {
              final offer = seats[index];
              return OfferCard(
                offer: offer,
                onTap: () {
                  context.pushNamed(
                    RouteNames.myOfferDetails,
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
    );
  }
}

// ── Bookings Segment ─────────────────────────────────────────────────────────

class _BookingsSegment extends ConsumerWidget {
  const _BookingsSegment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorBody(
        onRetry: () => ref.invalidate(myBookingsProvider),
      ),
      data: (bookings) {
        if (bookings.isEmpty) {
          return _EmptyBody(
            icon: Icons.bookmark_outline,
            message: context.l10n.noBookingsYet,
            subtitle: context.l10n.noBookingsYetMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myBookingsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(
                booking: booking,
                onTap: () {
                  context.pushNamed(
                    RouteNames.offerDetails,
                    pathParameters: {
                      'offerKey':
                          OfferKey(OfferKind.ride, booking.rideId)
                              .toRouteParam(),
                    },
                  );
                },
                onCancel: () => _showCancelDialog(context, ref, booking),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    BookingUiModel booking,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelBooking),
        content: Text(l10n.cancelBookingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelBooking),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.cancelBooking(booking.rideId, booking.bookingId);
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is BookingFailure ? e.toString() : l10n.rideNotBookableError,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Shared Helpers ───────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const _EmptyBody({
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(context.l10n.failedToLoadOffers,
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
