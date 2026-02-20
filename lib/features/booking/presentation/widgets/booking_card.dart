import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../data/dto/booking_enums.dart';
import '../../domain/booking_ui_model.dart';

/// Card displaying a booking in the My Activity → Bookings list.
///
/// Shows board→alight route, status chip, departure time, seat count.
/// Tap navigates to ride detail. Long-press reveals cancel action.
class BookingCard extends StatelessWidget {
  final BookingUiModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: booking.status.isCancellable ? onCancel : null,
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route + status row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${booking.boardStopName} → ${booking.alightStopName}',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.offerDate(booking.departureTime),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status chip
                    _BookingStatusChip(status: booking.status),
                  ],
                ),
                const SizedBox(height: 8),
                // Seat count + cancel hint
                Row(
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.seatCount(booking.seatCount),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (booking.status.isCancellable) ...[
                      const Spacer(),
                      Text(
                        l10n.cancelBooking,
                        style: tt.labelSmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const _BookingStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = _statusDisplay(status, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _statusDisplay(BookingStatus status, dynamic l10n) {
    return switch (status) {
      BookingStatus.pending => (l10n.bookingStatusPending, Colors.amber.shade700),
      BookingStatus.confirmed => (l10n.bookingStatusConfirmed, Colors.green),
      BookingStatus.rejected => (l10n.bookingStatusRejected, Colors.red),
      BookingStatus.cancelledByPassenger => (l10n.bookingStatusCancelled, Colors.grey),
      BookingStatus.cancelledByDriver => (l10n.bookingStatusCancelled, Colors.grey),
      BookingStatus.expired => (l10n.bookingStatusExpired, Colors.grey),
    };
  }
}
