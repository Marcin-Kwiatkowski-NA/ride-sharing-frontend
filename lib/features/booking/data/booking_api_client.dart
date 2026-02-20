import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import 'dto/book_ride_request_dto.dart';
import 'dto/booking_response_dto.dart';

part 'booking_api_client.g.dart';

/// HTTP client for booking endpoints.
class BookingApiClient {
  final Dio _dio;

  BookingApiClient(this._dio);

  /// Create a new booking on a ride.
  Future<BookingResponseDto> bookRide(
    int rideId,
    BookRideRequestDto request,
  ) async {
    final response = await _dio.post(
      '/rides/$rideId/bookings',
      data: request.toJson(),
    );
    return BookingResponseDto.fromJson(response.data);
  }

  /// Get current user's active bookings.
  Future<List<BookingResponseDto>> getMyBookings() async {
    final response = await _dio.get<List<dynamic>>('/me/bookings');
    return (response.data ?? [])
        .map((json) =>
            BookingResponseDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific booking by id.
  Future<BookingResponseDto> getBooking(int rideId, int bookingId) async {
    final response =
        await _dio.get('/rides/$rideId/bookings/$bookingId');
    return BookingResponseDto.fromJson(response.data);
  }

  /// Cancel a booking (by driver or passenger).
  Future<BookingResponseDto> cancelBooking(int rideId, int bookingId) async {
    final response =
        await _dio.post('/rides/$rideId/bookings/$bookingId/cancel');
    return BookingResponseDto.fromJson(response.data);
  }

  /// Confirm a pending booking (driver only).
  Future<BookingResponseDto> confirmBooking(int rideId, int bookingId) async {
    final response =
        await _dio.post('/rides/$rideId/bookings/$bookingId/confirm');
    return BookingResponseDto.fromJson(response.data);
  }

  /// Reject a pending booking (driver only).
  Future<BookingResponseDto> rejectBooking(int rideId, int bookingId) async {
    final response =
        await _dio.post('/rides/$rideId/bookings/$bookingId/reject');
    return BookingResponseDto.fromJson(response.data);
  }
}

@Riverpod(keepAlive: true)
BookingApiClient bookingApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  return BookingApiClient(dio);
}
