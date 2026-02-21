import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/geo_utils.dart';
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
  final _priceController = TextEditingController();

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

    _updateSuggestedPrice();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  RideStopDto? _findStopByOsmId(int? osmId) {
    if (osmId == null) return null;
    return _sortedStops
        .where((s) => s.location.osmId == osmId)
        .firstOrNull;
  }

  bool get _isSegmentValid =>
      _boardStop.stopOrder < _alightStop.stopOrder;

  bool get _isSegmentBooking =>
      _boardStop.stopOrder != _sortedStops.first.stopOrder ||
      _alightStop.stopOrder != _sortedStops.last.stopOrder;

  bool get _canSubmit =>
      _isSegmentValid && _seatCount <= widget.offer.count && _seatCount >= 1;

  void _updateSuggestedPrice() {
    if (!_isSegmentBooking || widget.offer.moneyAmount == null) {
      _priceController.clear();
      return;
    }
    final suggested = _calculateSuggestedPrice();
    if (suggested != null) {
      _priceController.text = suggested.toString();
    }
  }

  int? _calculateSuggestedPrice() {
    final amount = widget.offer.moneyAmount;
    if (amount == null) return null;

    // Total route distance (sum of consecutive stop distances)
    var totalDistance = 0.0;
    for (var i = 0; i < _sortedStops.length - 1; i++) {
      totalDistance += _distanceBetweenStops(_sortedStops[i], _sortedStops[i + 1]);
    }
    if (totalDistance == 0) return null;

    // Segment distance (board to alight)
    var segmentDistance = 0.0;
    final boardIdx = _sortedStops.indexWhere(
        (s) => s.stopOrder == _boardStop.stopOrder);
    final alightIdx = _sortedStops.indexWhere(
        (s) => s.stopOrder == _alightStop.stopOrder);
    if (boardIdx < 0 || alightIdx < 0 || boardIdx >= alightIdx) return null;
    for (var i = boardIdx; i < alightIdx; i++) {
      segmentDistance += _distanceBetweenStops(_sortedStops[i], _sortedStops[i + 1]);
    }

    final raw = amount * segmentDistance / totalDistance;
    // Round up to nearest 5, minimum 10 PLN
    final rounded = (raw / 5).ceil() * 5;
    return max(10, rounded);
  }

  static double _distanceBetweenStops(RideStopDto a, RideStopDto b) {
    final aLoc = a.location, bLoc = b.location;
    if (aLoc.latitude == null || aLoc.longitude == null ||
        bLoc.latitude == null || bLoc.longitude == null) {
      return 0;
    }
    return haversineKm(aLoc.latitude!, aLoc.longitude!,
        bLoc.latitude!, bLoc.longitude!);
  }

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
              onChanged: (stop) => setState(() {
                _boardStop = stop;
                _updateSuggestedPrice();
              }),
            ),
            const SizedBox(height: 8),
            _StopDropdown(
              label: l10n.alightAt,
              stops: _sortedStops,
              selectedStop: _alightStop,
              onChanged: (stop) => setState(() {
                _alightStop = stop;
                _updateSuggestedPrice();
              }),
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

          // Price section
          if (offer.moneyAmount != null) ...[
            const SizedBox(height: 8),
            if (_isSegmentBooking) ...[
              // Segment booking: show full route price as reference + editable proposal
              Text(
                l10n.fullRoutePrice(offer.moneyAmount!.toInt()),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: l10n.proposedPriceLabel,
                  suffixText: 'PLN',
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                ),
              ),
            ] else ...[
              // Full route: show fixed price summary
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
                        proposedPrice: _isSegmentBooking
                            ? int.tryParse(_priceController.text)
                            : null,
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
