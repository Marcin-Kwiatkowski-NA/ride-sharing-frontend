import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/booking_failure.dart';
import 'booking_api_client.dart';
import 'dto/book_ride_request_dto.dart';
import 'dto/booking_response_dto.dart';

part 'booking_repository.g.dart';

/// Repository for booking operations.
///
/// Wraps [BookingApiClient] and maps HTTP errors to typed [BookingFailure].
class BookingRepository {
  final BookingApiClient _apiClient;

  BookingRepository(this._apiClient);

  /// Book a ride. Throws [BookingFailure] on known error conditions.
  Future<BookingResponseDto> bookRide(
    int rideId,
    BookRideRequestDto request,
  ) async {
    try {
      return await _apiClient.bookRide(rideId, request);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Get current user's active bookings.
  Future<List<BookingResponseDto>> getMyBookings() {
    return _apiClient.getMyBookings();
  }

  /// Get a specific booking.
  Future<BookingResponseDto> getBooking(int rideId, int bookingId) {
    return _apiClient.getBooking(rideId, bookingId);
  }

  /// Cancel a booking.
  Future<BookingResponseDto> cancelBooking(int rideId, int bookingId) async {
    try {
      return await _apiClient.cancelBooking(rideId, bookingId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Confirm a pending booking (driver only).
  Future<BookingResponseDto> confirmBooking(int rideId, int bookingId) async {
    try {
      return await _apiClient.confirmBooking(rideId, bookingId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Reject a pending booking (driver only).
  Future<BookingResponseDto> rejectBooking(int rideId, int bookingId) async {
    try {
      return await _apiClient.rejectBooking(rideId, bookingId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Get all bookings for a ride (driver only).
  Future<List<BookingResponseDto>> getBookingsForRide(int rideId) async {
    try {
      return await _apiClient.getBookingsForRide(rideId);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Map DioException to typed [BookingFailure] using ProblemDetail.
  BookingFailure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return BookingFailure.network(e.message ?? 'Connection error');
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final type = data['type'] as String? ?? '';
      final detail = data['detail'] as String? ?? '';

      // Match exception class names from ProblemDetail `type` field
      if (type.contains('AlreadyBooked')) {
        return const BookingFailure.alreadyBooked();
      }
      if (type.contains('InsufficientSeats')) {
        return const BookingFailure.insufficientSeats();
      }
      if (type.contains('RideNotBookable')) {
        return const BookingFailure.rideNotBookable();
      }
      if (type.contains('ExternalRideNotBookable')) {
        return const BookingFailure.externalRide();
      }
      if (type.contains('InvalidBookingSegment')) {
        return const BookingFailure.invalidSegment();
      }
      if (type.contains('InvalidBookingTransition')) {
        return BookingFailure.unknown(detail);
      }

      return BookingFailure.unknown(
        detail.isNotEmpty ? detail : 'Unexpected error',
      );
    }

    return BookingFailure.unknown(
      e.message ?? 'An unexpected error occurred',
    );
  }
}

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) {
  final apiClient = ref.watch(bookingApiClientProvider);
  return BookingRepository(apiClient);
}
