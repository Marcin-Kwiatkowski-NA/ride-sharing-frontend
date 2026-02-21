import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../booking/data/dto/booking_enums.dart';
import '../../../booking/data/dto/booking_response_dto.dart';
import '../../../booking/presentation/providers/booking_action_controller.dart';
import '../../../booking/presentation/providers/booking_event_handler.dart';
import '../../../booking/presentation/providers/ride_booking_providers.dart';
import '../../../booking/presentation/widgets/booking_sheet.dart';
import '../../../booking/presentation/widgets/bookings_section.dart';
import '../../../booking/presentation/widgets/your_booking_card.dart';
import '../../../rides/details/presentation/widgets/smart_matches_section.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';
import '../providers/offer_detail_provider.dart';
import '../widgets/offer_bottom_bar.dart';
import '../widgets/offer_master_card.dart';
import '../widgets/offer_person_section.dart';
import '../widgets/contact_user_sheet.dart';

/// Unified details screen for any offer kind (ride or seat).
class OfferDetailsScreen extends ConsumerWidget {
  final OfferKey offerKey;
  final bool showSmartMatches;

  const OfferDetailsScreen({
    super.key,
    required this.offerKey,
    this.showSmartMatches = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(offerKey));

    // Show contextual snackbar on STOMP booking events for this ride
    ref.listen(bookingEventHandlerProvider, (prev, next) {
      if (next == null || prev == next) return;
      if (next.rideId != offerKey.id) return;
      if (offerKey.kind != OfferKind.ride) return;

      final l10n = context.l10n;
      final message = switch (next.eventType) {
        'REQUESTED' =>
          l10n.newBookingRequest(next.counterpartyName ?? ''),
        'CONFIRMED' => l10n.bookingAccepted,
        'REJECTED' => l10n.bookingDeclined,
        'CANCELLED' => l10n.bookingCancelled,
        _ => null,
      };

      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return offerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(offerDetailProvider(offerKey)),
        ),
      ),
      data: (offer) {
        final strings = OfferDetailsStrings(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.screenTitle(offer.offerKey.kind)),
          ),
          body: PageLayout(
            child: _OfferDetailsBody(
              offer: offer,
              showSmartMatches: showSmartMatches,
            ),
          ),
          bottomNavigationBar: offer.user != null
              ? _BottomBarWithRole(offer: offer, offerKey: offerKey)
              : null,
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final failure = ErrorMapper.map(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(failure.message),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _OfferDetailsBody extends ConsumerWidget {
  final OfferUiModel offer;
  final bool showSmartMatches;

  const _OfferDetailsBody({
    required this.offer,
    this.showSmartMatches = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(offerRoleProvider(offer.offerKey));
    final isRide = offer.offerKey.kind == OfferKind.ride;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.list(
            children: [
              OfferMasterCard(offer: offer),

              // Passenger: show "Your Booking" card if they have one
              if (role == OfferRole.passenger && isRide) ...[
                const SizedBox(height: 16),
                _PassengerBookingSection(rideId: offer.offerKey.id),
              ],

              // Driver: show booking management section
              if (role == OfferRole.driver && isRide) ...[
                const SizedBox(height: 16),
                BookingsSection(rideId: offer.offerKey.id),
              ],

              if (offer.user != null) ...[
                const SizedBox(height: 16),
                OfferPersonSection(
                  user: offer.user!,
                  description: offer.description,
                  offerKind: offer.offerKey.kind,
                  isExternalSource: offer.isExternalSource,
                ),
              ],
              if (showSmartMatches && isRide) ...[
                const SizedBox(height: 16),
                SmartMatchesSection(rideId: offer.offerKey.id),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Watches [myBookingForRideProvider] and renders [YourBookingCard] or nothing.
class _PassengerBookingSection extends ConsumerWidget {
  final int rideId;

  const _PassengerBookingSection({required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(myBookingForRideProvider(rideId));
    return switch (bookingAsync) {
      // Has data (even if refreshing) with a non-null booking
      AsyncValue(hasValue: true, value: final booking?) =>
        YourBookingCard(booking: booking),
      // Successfully fetched but no booking for this ride, or loading/error
      _ => const SizedBox.shrink(),
    };
  }
}

/// Role-aware bottom bar for the offer details screen.
///
/// - Driver: no bottom bar (actions are inline in BookingsSection)
/// - Passenger with booking: state-driven Cancel/Message bar
/// - Passenger without booking: original Book/Contact bar
/// - Anonymous/external/seat: original bar
class _BottomBarWithRole extends ConsumerWidget {
  final OfferUiModel offer;
  final OfferKey offerKey;

  const _BottomBarWithRole({
    required this.offer,
    required this.offerKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(offerRoleProvider(offerKey));

    // Driver: actions are inline in BookingsSection
    if (role == OfferRole.driver) return const SizedBox.shrink();

    // Passenger with ride: check for existing booking
    if (role == OfferRole.passenger && offerKey.kind == OfferKind.ride) {
      final bookingAsync = ref.watch(myBookingForRideProvider(offerKey.id));
      return switch (bookingAsync) {
        AsyncValue(hasValue: true, value: final booking?) =>
          _BookingStateBar(offer: offer, booking: booking),
        _ => OfferBottomBar(
          offer: offer,
          onBookTap: () => showBookingSheet(context, offer: offer),
        ),
      };
    }

    // Anonymous/external/seat: original bar
    return OfferBottomBar(
      offer: offer,
      onBookTap: () => showBookingSheet(context, offer: offer),
    );
  }
}

/// State-driven bottom bar for passengers with an existing booking.
class _BookingStateBar extends ConsumerWidget {
  final OfferUiModel offer;
  final BookingResponseDto booking;

  const _BookingStateBar({
    required this.offer,
    required this.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // Listen for action errors
    ref.listen(bookingActionControllerProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return SafeArea(
      maintainBottomViewPadding: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: switch (booking.status) {
          BookingStatus.pending => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      showContactUserSheet(context, offer.user!),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: Text(l10n.contactDriver),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showCancelDialog(context, ref),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(l10n.cancelRequest),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.error,
                  ),
                ),
              ),
            ],
          ),
          BookingStatus.confirmed => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, ref),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(l10n.cancelBooking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      showContactUserSheet(context, offer.user!),
                  icon: const Icon(Icons.chat, size: 18),
                  label: Text(l10n.messageDriver),
                ),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelBooking),
        content: Text(l10n.cancelBookingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.cancelBooking),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(bookingActionControllerProvider.notifier)
          .cancelBooking(booking.rideId, booking.id);
    }
  }
}
