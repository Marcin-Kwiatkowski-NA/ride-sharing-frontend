import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../data/booking_repository.dart';
import 'ride_booking_providers.dart';

part 'booking_action_controller.g.dart';

/// Controller for driver/passenger booking actions.
///
/// Each method performs the API call and invalidates only the
/// providers that are actually affected by the state change.
@riverpod
class BookingActionController extends _$BookingActionController {
  @override
  FutureOr<void> build() {}

  /// Driver confirms a pending booking.
  Future<void> confirmBooking(int rideId, int bookingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.confirmBooking(rideId, bookingId);
      ref.invalidate(rideBookingsProvider(rideId));
      ref.invalidate(
        offerDetailProvider(OfferKey(OfferKind.ride, rideId)),
      );
    });
  }

  /// Driver rejects a pending booking.
  Future<void> rejectBooking(int rideId, int bookingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.rejectBooking(rideId, bookingId);
      ref.invalidate(rideBookingsProvider(rideId));
      ref.invalidate(
        offerDetailProvider(OfferKey(OfferKind.ride, rideId)),
      );
    });
  }

  /// Passenger or driver cancels a booking.
  Future<void> cancelBooking(int rideId, int bookingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.cancelBooking(rideId, bookingId);
      ref.invalidate(myBookingDtosProvider);
      ref.invalidate(rideBookingsProvider(rideId));
      ref.invalidate(
        offerDetailProvider(OfferKey(OfferKind.ride, rideId)),
      );
    });
  }
}
