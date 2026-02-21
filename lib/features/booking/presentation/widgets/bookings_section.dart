import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../offers/domain/offer_models.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/widgets/contact_user_sheet.dart';
import '../../../rides/data/dto/user_card_dto.dart';
import '../../data/dto/booking_enums.dart';
import '../../data/dto/booking_response_dto.dart';
import '../providers/booking_action_controller.dart';
import '../providers/ride_booking_providers.dart';
import 'booking_card.dart';

/// Driver's booking management section in ride details.
///
/// Shows a segmented filter (Pending/Confirmed/History) and a list of
/// booking tiles with inline Accept/Decline/Message actions.
class BookingsSection extends ConsumerWidget {
  final int rideId;

  const BookingsSection({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final filter = ref.watch(bookingFilterStateProvider(rideId));
    final bookingsAsync = ref.watch(rideBookingsProvider(rideId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with relative time label
        Row(
          children: [
            Text(
              l10n.bookingsSection,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            switch (bookingsAsync) {
              AsyncValue(hasValue: true) =>
                _RelativeTimeLabel(DateTime.now()),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
        const SizedBox(height: 12),

        // Segmented filter
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<BookingFilter>(
            segments: [
              ButtonSegment(
                value: BookingFilter.pending,
                label: Text(l10n.filterPending),
              ),
              ButtonSegment(
                value: BookingFilter.confirmed,
                label: Text(l10n.filterConfirmed),
              ),
              ButtonSegment(
                value: BookingFilter.history,
                label: Text(l10n.filterHistory),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (selected) {
              ref
                  .read(bookingFilterStateProvider(rideId).notifier)
                  .setFilter(selected.first);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Booking list
        switch (bookingsAsync) {
          AsyncValue(hasValue: true, :final value!) =>
            _BookingList(
              bookings: _filterBookings(value, filter),
              rideId: rideId,
              filter: filter,
            ),
          AsyncError(:final error) => _ErrorState(
            error: error,
            onRetry: () => ref.invalidate(rideBookingsProvider(rideId)),
          ),
          _ => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        },
      ],
    );
  }

  List<BookingResponseDto> _filterBookings(
    List<BookingResponseDto> bookings,
    BookingFilter filter,
  ) {
    return switch (filter) {
      BookingFilter.pending =>
        bookings.where((b) => b.status == BookingStatus.pending).toList(),
      BookingFilter.confirmed =>
        bookings.where((b) => b.status == BookingStatus.confirmed).toList(),
      BookingFilter.history =>
        bookings.where((b) => b.status.isTerminal).toList(),
    };
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingResponseDto> bookings;
  final int rideId;
  final BookingFilter filter;

  const _BookingList({
    required this.bookings,
    required this.rideId,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.l10n.noBookingsInCategory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final booking in bookings) ...[
          _DriverBookingTile(booking: booking, rideId: rideId),
          if (booking != bookings.last)
            Divider(
              height: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
            ),
        ],
      ],
    );
  }
}

class _DriverBookingTile extends ConsumerWidget {
  final BookingResponseDto booking;
  final int rideId;

  const _DriverBookingTile({
    required this.booking,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final actionState = ref.watch(bookingActionControllerProvider);
    final isActioning = actionState.isLoading;
    final isTerminal = booking.status.isTerminal;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger info + status
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    booking.passenger.name.isNotEmpty
                        ? booking.passenger.name[0].toUpperCase()
                        : '?',
                    style: tt.titleSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passenger.name,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isTerminal ? cs.onSurfaceVariant : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${booking.boardStop.location.name} → ${booking.alightStop.location.name}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BookingStatusChip(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),

            // Seat count
            Row(
              children: [
                Icon(
                  Icons.airline_seat_recline_normal,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.seatCount(booking.seatCount),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (booking.proposedPrice != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.proposedPrice!.toStringAsFixed(0)} zł',
                    style:
                        tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),

            // Actions
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  // Message icon
                  IconButton(
                    onPressed: () => _openChat(context, ref),
                    icon: Icon(
                      Icons.chat_outlined,
                      size: 20,
                      color: cs.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.messagePassenger,
                  ),
                  const Spacer(),
                  // Decline
                  OutlinedButton(
                    onPressed: isActioning
                        ? null
                        : () => _showDeclineDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(l10n.declineBooking),
                  ),
                  const SizedBox(width: 8),
                  // Accept
                  FilledButton.tonal(
                    onPressed: isActioning
                        ? null
                        : () => ref
                            .read(bookingActionControllerProvider.notifier)
                            .confirmBooking(rideId, booking.id),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: isActioning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.acceptBooking),
                  ),
                ],
              ),
            ],

            if (booking.status == BookingStatus.confirmed) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openChat(context, ref),
                  icon: const Icon(Icons.chat, size: 18),
                  label: Text(l10n.messagePassenger),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, WidgetRef ref) {
    final passengerContact = _buildPassengerContact(
      booking.passenger,
      OfferKey(OfferKind.ride, rideId),
    );
    showContactUserSheet(context, passengerContact);
  }

  Future<void> _showDeclineDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.declineBooking),
        content: Text(l10n.declineBookingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: ctx.theme.colorScheme.error),
            child: Text(l10n.declineBooking),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(bookingActionControllerProvider.notifier)
          .rejectBooking(rideId, booking.id);
    }
  }
}

/// Builds an [OfferUserUi] from a passenger's [UserCardDto] for in-app chat.
OfferUserUi _buildPassengerContact(UserCardDto passenger, OfferKey rideKey) {
  return OfferUserUi(
    displayName: passenger.name,
    rating: passenger.rating,
    completedTrips: passenger.completedRides,
    showRating: passenger.rating != null,
    userId: passenger.id,
    canUseInAppChat: true,
    chatContext: ChatContext(rideKey.kind, rideKey.id),
    contactMethods: const [],
  );
}

/// Auto-ticking relative time label.
///
/// Watches [minuteTickerProvider] so only this widget rebuilds each minute.
class _RelativeTimeLabel extends ConsumerWidget {
  final DateTime lastUpdated;

  const _RelativeTimeLabel(this.lastUpdated);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force rebuild every minute
    ref.watch(minuteTickerProvider);

    final diff = DateTime.now().difference(lastUpdated);
    final l10n = context.l10n;
    final text = diff.inMinutes < 1
        ? l10n.updatedJustNow
        : l10n.updatedMinutesAgo(diff.inMinutes);

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
