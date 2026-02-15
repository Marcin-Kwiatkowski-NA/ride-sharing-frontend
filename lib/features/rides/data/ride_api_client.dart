import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../offers/data/offer_search_criteria.dart';
import '../../offers/data/paginated_response.dart';
import 'dto/ride_response_dto.dart';

part 'ride_api_client.g.dart';

/// API client for ride endpoints.
class RideApiClient {
  final Dio _dio;

  RideApiClient(this._dio);

  /// Search rides with exact location criteria.
  Future<PaginatedResponse<RideResponseDto>> searchRides(
    OfferSearchCriteria criteria,
  ) async {
    final queryParams = <String, dynamic>{
      'page': criteria.page,
      'size': criteria.size,
      'minAvailableSeats': criteria.minAvailableSeats,
    };

    if (criteria.origin != null) {
      queryParams['originOsmId'] = criteria.origin!.osmId;
    }
    if (criteria.destination != null) {
      queryParams['destinationOsmId'] = criteria.destination!.osmId;
    }
    _addDateTimeParams(queryParams, criteria);

    return _executeSearch(queryParams);
  }

  /// Search rides by proximity (coordinates + radius).
  ///
  /// Requires both origin and destination in [criteria].
  /// Backend may return exact matches too — caller must deduplicate.
  Future<PaginatedResponse<RideResponseDto>> searchRidesNearby(
    OfferSearchCriteria criteria, {
    required double radiusKm,
  }) async {
    final queryParams = <String, dynamic>{
      'page': 0,
      'size': 20,
      'minAvailableSeats': criteria.minAvailableSeats,
      'originLat': criteria.origin!.latitude,
      'originLon': criteria.origin!.longitude,
      'destinationLat': criteria.destination!.latitude,
      'destinationLon': criteria.destination!.longitude,
      'radiusKm': radiusKm,
    };
    _addDateTimeParams(queryParams, criteria);

    return _executeSearch(queryParams);
  }

  Future<PaginatedResponse<RideResponseDto>> _executeSearch(
    Map<String, dynamic> queryParams,
  ) async {
    final response = await _dio.get(
      '/rides/search',
      queryParameters: queryParams,
    );

    final data = response.data;
    final List<dynamic> content = data['content'] ?? [];
    final rides = content
        .map((json) => RideResponseDto.fromJson(json))
        .toList();

    return PaginatedResponse(
      content: rides,
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

  /// Get all rides with pagination.
  Future<List<RideResponseDto>> getAllRides({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/rides',
      queryParameters: {'page': page, 'size': size},
    );

    final List<dynamic> content = response.data['content'] ?? [];
    return content.map((json) => RideResponseDto.fromJson(json)).toList();
  }

  /// Get ride by ID.
  Future<RideResponseDto> getRideById(int rideId) async {
    final response = await _dio.get('/rides/$rideId');
    return RideResponseDto.fromJson(response.data);
  }

  /// Get current user's booked rides.
  Future<List<RideResponseDto>> getMyRides() async {
    final response = await _dio.get<List<dynamic>>('/me/rides');
    return (response.data ?? [])
        .map((json) => RideResponseDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Provider for RideApiClient.
///
/// Uses keepAlive since this is a service that should persist.
@Riverpod(keepAlive: true)
RideApiClient rideApiClient(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  return RideApiClient(dio);
}
