import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../data/booking_repository.dart';
import '../../data/dto/book_ride_request_dto.dart';
import '../../data/dto/booking_response_dto.dart';
import 'my_bookings_provider.dart';

part 'booking_controller.g.dart';

/// Async notifier for submitting a booking.
///
/// State starts as `AsyncData(null)`. On submit, transitions to
/// `AsyncLoading`, then `AsyncData(booking)` or `AsyncError(failure)`.
///
/// The error will be a [BookingFailure] from the repository layer.
@riverpod
class BookingSubmit extends _$BookingSubmit {
  @override
  Future<BookingResponseDto?> build() async => null;

  Future<void> submit({
    required int rideId,
    required int boardStopOsmId,
    required int alightStopOsmId,
    required int seatCount,
    int? proposedPrice,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.bookRide(
        rideId,
        BookRideRequestDto(
          boardStopOsmId: boardStopOsmId,
          alightStopOsmId: alightStopOsmId,
          seatCount: seatCount,
          proposedPrice: proposedPrice,
        ),
      );

      // Invalidate related providers so UI refreshes
      ref.invalidate(myBookingsProvider);
      ref.invalidate(
        offerDetailProvider(OfferKey(OfferKind.ride, rideId)),
      );

      return result;
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}
