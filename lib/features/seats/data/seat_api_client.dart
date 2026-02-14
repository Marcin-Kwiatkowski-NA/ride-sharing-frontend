import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../offers/data/offer_search_criteria.dart';
import '../../offers/data/paginated_response.dart';
import 'dto/seat_creation_request_dto.dart';
import 'dto/seat_response_dto.dart';

part 'seat_api_client.g.dart';

/// API client for seat endpoints.
class SeatApiClient {
  final Dio _dio;

  SeatApiClient(this._dio);

  /// Search seats with criteria.
  ///
  /// Maps OfferSearchCriteria to seat-specific query params.
  /// Note: `minAvailableSeats` maps to `availableSeatsInCar` on the backend.
  Future<PaginatedResponse<SeatResponseDto>> searchSeats(
    OfferSearchCriteria criteria,
  ) async {
    final queryParams = <String, dynamic>{
      'page': criteria.page,
      'size': criteria.size,
    };

    if (criteria.minAvailableSeats > 0) {
      queryParams['availableSeatsInCar'] = criteria.minAvailableSeats;
    }
    if (criteria.origin != null) {
      queryParams['originPlaceId'] = criteria.origin!.placeId;
    }
    if (criteria.destination != null) {
      queryParams['destinationPlaceId'] = criteria.destination!.placeId;
    }
    if (criteria.departureDate != null) {
      queryParams['departureDate'] = criteria.departureDate!
          .toIso8601String()
          .split('T')[0];
    }
    if (criteria.departureDateTo != null) {
      queryParams['departureDateTo'] = criteria.departureDateTo!
          .toIso8601String()
          .split('T')[0];
    }
    if (criteria.departureTimeFrom != null) {
      final time = criteria.departureTimeFrom!;
      queryParams['departureTimeFrom'] =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }

    final response = await _dio.get(
      '/seats/search',
      queryParameters: queryParams,
    );

    final data = response.data;
    final List<dynamic> content = data['content'] ?? [];
    final seats = content
        .map((json) => SeatResponseDto.fromJson(json as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      content: seats,
      totalElements: data['totalElements'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['number'] ?? 0,
      last: data['last'] ?? true,
    );
  }

  /// Get seat by ID.
  Future<SeatResponseDto> getSeatById(int seatId) async {
    final response = await _dio.get('/seats/$seatId');
    return SeatResponseDto.fromJson(response.data);
  }

  /// Create a new seat request.
  Future<SeatResponseDto> createSeat(SeatCreationRequestDto dto) async {
    final response = await _dio.post('/seats', data: dto.toJson());
    return SeatResponseDto.fromJson(response.data);
  }

  /// Delete a seat request.
  Future<void> deleteSeat(int seatId) async {
    await _dio.delete('/seats/$seatId');
  }

  /// Get current user's seat requests.
  Future<List<SeatResponseDto>> getMySeats() async {
    final response = await _dio.get<List<dynamic>>('/me/seats');
    return (response.data ?? [])
        .map((json) => SeatResponseDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

@Riverpod(keepAlive: true)
SeatApiClient seatApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  return SeatApiClient(dio);
}
