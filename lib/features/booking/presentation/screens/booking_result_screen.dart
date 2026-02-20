import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../routes/routes.dart';
import '../../data/dto/booking_enums.dart';
import '../../data/dto/booking_response_dto.dart';

/// Result screen shown after a booking is created.
///
/// Two visual variants:
/// - CONFIRMED (instant): green success
/// - PENDING (request): amber pending
///
/// Deep-link safe: accepts bookingId + rideId in route params,
/// with optional BookingResponseDto via extra for instant display.
class BookingResultScreen extends ConsumerWidget {
  final int bookingId;
  final int rideId;
  final BookingResponseDto? initialData;

  const BookingResultScreen({
    super.key,
    required this.bookingId,
    required this.rideId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = initialData;

    // If no data via extra, show a minimal success screen
    if (booking == null) {
      return _MinimalResultScreen(bookingId: bookingId, rideId: rideId);
    }

    final isConfirmed = booking.status == BookingStatus.confirmed;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () => context.go(RoutePaths.myOffers),
        ),
      ),
      body: PageLayout(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusIcon(isConfirmed: isConfirmed),
                const SizedBox(height: 24),
                _StatusTitle(isConfirmed: isConfirmed),
                const SizedBox(height: 8),
                _StatusSubtitle(
                  isConfirmed: isConfirmed,
                  booking: booking,
                ),
                const SizedBox(height: 32),
                _BookingSummaryCard(booking: booking),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go(RoutePaths.myOffers),
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: Text(context.l10n.viewMyBookings),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalResultScreen extends StatelessWidget {
  final int bookingId;
  final int rideId;

  const _MinimalResultScreen({
    required this.bookingId,
    required this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () => context.go(RoutePaths.myOffers),
        ),
      ),
      body: PageLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.youAreBooked,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.myOffers),
                icon: const Icon(Icons.list_alt, size: 18),
                label: Text(l10n.viewMyBookings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isConfirmed;

  const _StatusIcon({required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: (isConfirmed ? Colors.green : Colors.amber)
            .withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isConfirmed ? Icons.check_circle : Icons.hourglass_top,
        size: 56,
        color: isConfirmed ? Colors.green : cs.tertiary,
      ),
    );
  }
}

class _StatusTitle extends StatelessWidget {
  final bool isConfirmed;

  const _StatusTitle({required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Text(
      isConfirmed ? l10n.youAreBooked : l10n.requestSent,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _StatusSubtitle extends StatelessWidget {
  final bool isConfirmed;
  final BookingResponseDto booking;

  const _StatusSubtitle({
    required this.isConfirmed,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Text(
      isConfirmed
          ? '${booking.boardStop.location.name} → ${booking.alightStop.location.name}'
          : l10n.driverWillConfirm,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final BookingResponseDto booking;

  const _BookingSummaryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: AppTokens.elevationLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              icon: Icons.route,
              label: '${booking.boardStop.location.name} → ${booking.alightStop.location.name}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.airline_seat_recline_normal,
              label: l10n.seatCount(booking.seatCount),
            ),
            if (booking.boardStop.departureTime != null) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                icon: Icons.schedule,
                label: l10n.offerDate(booking.boardStop.departureTime!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
