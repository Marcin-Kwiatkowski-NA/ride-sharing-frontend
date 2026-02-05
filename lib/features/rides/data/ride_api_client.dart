import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import 'dto/paginated_response.dart';
import 'dto/ride_response_dto.dart';
import 'dto/search_criteria_dto.dart';

part 'ride_api_client.g.dart';

/// API client for ride endpoints.
class RideApiClient {
  final Dio _dio;

  RideApiClient(this._dio);

  /// Search rides with criteria.
  ///
  /// Returns paginated response with rides and pagination metadata.
  Future<PaginatedResponse<RideResponseDto>> searchRides(
    SearchCriteriaDto criteria,
  ) async {
    final queryParams = <String, dynamic>{
      'page': criteria.page,
      'size': criteria.size,
      'minAvailableSeats': criteria.minAvailableSeats,
    };

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
}

/// Provider for RideApiClient.
///
/// Uses keepAlive since this is a service that should persist.
@Riverpod(keepAlive: true)
RideApiClient rideApiClient(Ref ref) {
  final dio = ref.watch(dioProvider);
  return RideApiClient(dio);
}
