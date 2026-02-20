import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routes/routes.dart';
import '../../../../shared/widgets/number_stepper.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../rides/data/dto/ride_stop_dto.dart';
import '../../domain/booking_failure.dart';
import '../../domain/booking_mode.dart';
import '../providers/booking_controller.dart';

/// Shows the booking bottom sheet for a ride.
///
/// The sheet allows segment selection (if intermediate stops exist),
/// seat count, price summary, and submit.
Future<void> showBookingSheet(
  BuildContext context, {
  required OfferUiModel offer,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _BookingSheetContent(offer: offer),
  );
}

class _BookingSheetContent extends ConsumerStatefulWidget {
  final OfferUiModel offer;

  const _BookingSheetContent({required this.offer});

  @override
  ConsumerState<_BookingSheetContent> createState() =>
      _BookingSheetContentState();
}

class _BookingSheetContentState extends ConsumerState<_BookingSheetContent> {
  late List<RideStopDto> _sortedStops;
  late RideStopDto _boardStop;
  late RideStopDto _alightStop;
  int _seatCount = 1;

  @override
  void initState() {
    super.initState();
    _sortedStops = [...widget.offer.stops]
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    // Default: first and last stop (full route), or search context if available
    _boardStop = _findStopByOsmId(widget.offer.searchOriginOsmId)
        ?? _sortedStops.first;
    _alightStop = _findStopByOsmId(widget.offer.searchDestinationOsmId)
        ?? _sortedStops.last;
  }

  RideStopDto? _findStopByOsmId(int? osmId) {
    if (osmId == null) return null;
    return _sortedStops
        .where((s) => s.location.osmId == osmId)
        .firstOrNull;
  }

  bool get _isSegmentValid =>
      _boardStop.stopOrder < _alightStop.stopOrder;

  bool get _canSubmit =>
      _isSegmentValid && _seatCount <= widget.offer.count && _seatCount >= 1;

  String _localizeFailure(BookingFailure failure) {
    final l10n = context.l10n;
    return switch (failure) {
      AlreadyBooked() => l10n.alreadyBookedError,
      InsufficientSeats() => l10n.insufficientSeatsError,
      RideNotBookable() => l10n.rideNotBookableError,
      ExternalRide() => l10n.externalRideError,
      InvalidSegment() => l10n.invalidSegmentError,
      NetworkFailure(:final message) => message,
      UnknownFailure(:final message) => message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final offer = widget.offer;
    final hasMultipleStops = _sortedStops.length > 2;
    final isInstant = offer.bookingMode == BookingMode.instant;

    // Listen for submit result
    ref.listen(bookingSubmitProvider, (prev, next) {
      switch (next) {
        case AsyncData(:final value) when value != null:
          Navigator.pop(context);
          context.pushNamed(
            RouteNames.bookingResult,
            pathParameters: {
              'bookingId': value.id.toString(),
            },
            queryParameters: {
              'rideId': value.rideId.toString(),
            },
            extra: value,
          );
        case AsyncError(:final error):
          final message = error is BookingFailure
              ? _localizeFailure(error)
              : error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(bookingSubmitProvider.notifier).reset();
        default:
          break;
      }
    });

    final submitState = ref.watch(bookingSubmitProvider);
    final isSubmitting = submitState is AsyncLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isInstant ? l10n.bookRide : l10n.requestToBook,
            style: tt.titleLarge,
          ),
          const SizedBox(height: 4),

          // Booking mode chip
          _BookingModeIndicator(bookingMode: offer.bookingMode),
          const SizedBox(height: 16),

          // Segment selection (only if multi-stop route)
          if (hasMultipleStops) ...[
            _StopDropdown(
              label: l10n.boardAt,
              stops: _sortedStops,
              selectedStop: _boardStop,
              onChanged: (stop) => setState(() => _boardStop = stop),
            ),
            const SizedBox(height: 8),
            _StopDropdown(
              label: l10n.alightAt,
              stops: _sortedStops,
              selectedStop: _alightStop,
              onChanged: (stop) => setState(() => _alightStop = stop),
            ),
            if (!_isSegmentValid)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  l10n.invalidSegmentError,
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Seat count
          NumberStepper(
            value: _seatCount,
            min: 1,
            max: offer.count,
            onChanged: (v) => setState(() => _seatCount = v),
            label: l10n.seatCountLabel,
          ),

          // Price summary
          if (offer.moneyAmount != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              ),
              child: Text(
                l10n.priceSummary(
                  _seatCount,
                  offer.moneyAmount!.toInt(),
                  (_seatCount * offer.moneyAmount!).toInt(),
                ),
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canSubmit && !isSubmitting
                  ? () => ref.read(bookingSubmitProvider.notifier).submit(
                        rideId: offer.offerKey.id,
                        boardStopOsmId: _boardStop.location.osmId,
                        alightStopOsmId: _alightStop.location.osmId,
                        seatCount: _seatCount,
                      )
                  : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isInstant ? Icons.bolt : Icons.send,
                      size: 18,
                    ),
              label: Text(
                isInstant ? l10n.bookInstantly : l10n.sendRequest,
              ),
            ),
          ),

          SafeArea(
            maintainBottomViewPadding: true,
            child: const SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}

class _BookingModeIndicator extends StatelessWidget {
  final BookingMode bookingMode;

  const _BookingModeIndicator({required this.bookingMode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isInstant = bookingMode == BookingMode.instant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: isInstant ? cs.primaryContainer : cs.tertiaryContainer,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInstant ? Icons.bolt : Icons.hourglass_top,
            size: 14,
            color: isInstant
                ? cs.onPrimaryContainer
                : cs.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            isInstant
                ? l10n.bookingModeInstant
                : l10n.bookingModeRequest,
            style: tt.labelSmall?.copyWith(
              color: isInstant
                  ? cs.onPrimaryContainer
                  : cs.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopDropdown extends StatelessWidget {
  final String label;
  final List<RideStopDto> stops;
  final RideStopDto selectedStop;
  final ValueChanged<RideStopDto> onChanged;

  const _StopDropdown({
    required this.label,
    required this.stops,
    required this.selectedStop,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: cs.surfaceContainerLow,
      ),
      initialValue: selectedStop.stopOrder,
      items: stops.map((stop) {
        return DropdownMenuItem(
          value: stop.stopOrder,
          child: Text(stop.location.name),
        );
      }).toList(),
      onChanged: (stopOrder) {
        if (stopOrder == null) return;
        final stop = stops.firstWhere((s) => s.stopOrder == stopOrder);
        onChanged(stop);
      },
    );
  }
}
