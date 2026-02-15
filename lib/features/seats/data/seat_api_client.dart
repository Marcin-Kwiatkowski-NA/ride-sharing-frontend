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

  /// Search seats with exact location criteria.
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
      queryParams['originOsmId'] = criteria.origin!.osmId;
    }
    if (criteria.destination != null) {
      queryParams['destinationOsmId'] = criteria.destination!.osmId;
    }
    _addDateTimeParams(queryParams, criteria);

    return _executeSearch(queryParams);
  }

  /// Search seats by proximity (coordinates + radius).
  ///
  /// Requires both origin and destination in [criteria].
  /// Backend may return exact matches too — caller must deduplicate.
  Future<PaginatedResponse<SeatResponseDto>> searchSeatsNearby(
    OfferSearchCriteria criteria, {
    required double radiusKm,
  }) async {
    final queryParams = <String, dynamic>{
      'page': 0,
      'size': 20,
      'originLat': criteria.origin!.latitude,
      'originLon': criteria.origin!.longitude,
      'destinationLat': criteria.destination!.latitude,
      'destinationLon': criteria.destination!.longitude,
      'radiusKm': radiusKm,
    };

    if (criteria.minAvailableSeats > 0) {
      queryParams['availableSeatsInCar'] = criteria.minAvailableSeats;
    }
    _addDateTimeParams(queryParams, criteria);

    return _executeSearch(queryParams);
  }

  Future<PaginatedResponse<SeatResponseDto>> _executeSearch(
    Map<String, dynamic> queryParams,
  ) async {
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

  void _addDateTimeParams(
    Map<String, dynamic> params,
    OfferSearchCriteria criteria,
  ) {
    if (criteria.departureDate != null) {
      params['departureDate'] = criteria.departureDate!
          .toIso8601String()
          .split('T')[0];
    }
    if (criteria.departureDateTo != null) {
      params['departureDateTo'] = criteria.departureDateTo!
          .toIso8601String()
          .split('T')[0];
    }
    if (criteria.departureTimeFrom != null) {
      final time = criteria.departureTimeFrom!;
      params['departureTimeFrom'] =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }
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
