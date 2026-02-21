import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/auth_session_provider.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../data/booking_repository.dart';
import '../../data/dto/booking_response_dto.dart';

part 'ride_booking_providers.g.dart';

/// Viewer's relationship to an offer.
enum OfferRole { driver, passenger, anonymous }

/// Filter for the driver's bookings section.
enum BookingFilter { pending, confirmed, history }

/// Determines the viewer's role relative to an offer.
///
/// Compares the authenticated user's ID with the offer owner's userId.
@riverpod
OfferRole offerRole(Ref ref, OfferKey key) {
  final userId = ref.watch(authSessionKeyProvider);
  if (userId == null) return OfferRole.anonymous;

  final offerAsync = ref.watch(offerDetailProvider(key));
  return switch (offerAsync) {
    AsyncValue(hasValue: true, :final value?) =>
      value.user?.userId == userId ? OfferRole.driver : OfferRole.passenger,
    _ => OfferRole.anonymous,
  };
}

/// Shared data source for the current user's active bookings.
///
/// Single HTTP call, cached by Riverpod. Derived providers
/// ([myBookingForRide], [myBookings]) filter from this without
/// additional network requests.
@riverpod
Future<List<BookingResponseDto>> myBookingDtos(Ref ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyBookings();
}

/// Passenger's active booking for a specific ride.
///
/// Pure derived provider — filters from [myBookingDtos] with no HTTP call.
/// Returns [AsyncValue] to propagate loading/error states and prevent
/// the "Your Booking" card from vanishing during background refreshes.
@riverpod
AsyncValue<BookingResponseDto?> myBookingForRide(Ref ref, int rideId) {
  final asyncDtos = ref.watch(myBookingDtosProvider);
  return asyncDtos.whenData(
    (dtos) =>
        dtos
            .where((b) => b.rideId == rideId && b.status.isActive)
            .firstOrNull,
  );
}

/// All bookings for a ride (driver view).
///
/// Calls `GET /rides/{rideId}/bookings` (driver-only endpoint).
@riverpod
Future<List<BookingResponseDto>> rideBookings(Ref ref, int rideId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingsForRide(rideId);
}

/// Driver's selected filter for the bookings section.
///
/// Family keyed by rideId so each ride's filter state is independent.
/// Defaults to [BookingFilter.pending].
@riverpod
class BookingFilterState extends _$BookingFilterState {
  @override
  BookingFilter build(int rideId) => BookingFilter.pending;

  void setFilter(BookingFilter filter) => state = filter;
}

/// Ticks every minute to force rebuild of relative time labels.
///
/// Watched by [_RelativeTimeLabel] widget so only the timestamp text
/// rebuilds, not the entire bookings section.
@riverpod
Stream<void> minuteTicker(Ref ref) {
  return Stream.periodic(const Duration(minutes: 1));
}
