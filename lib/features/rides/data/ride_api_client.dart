import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'dto/ride_response_dto.dart';
import 'dto/search_criteria_dto.dart';

/// API client for ride endpoints.
class RideApiClient {
  final Dio _dio;

  RideApiClient(this._dio);

  /// Search rides with criteria.
  ///
  /// Returns paginated list of rides matching the search criteria.
  Future<List<RideResponseDto>> searchRides(SearchCriteriaDto criteria) async {
    final queryParams = <String, dynamic>{
      'page': criteria.page,
      'size': criteria.size,
      'minSeats': criteria.minSeats,
    };

    if (criteria.origin?.isNotEmpty == true) {
      queryParams['origin'] = criteria.origin;
    }
    if (criteria.destination?.isNotEmpty == true) {
      queryParams['destination'] = criteria.destination;
    }
    if (criteria.departureDate != null) {
      queryParams['departureDate'] =
          criteria.departureDate!.toIso8601String().split('T')[0];
    }
    if (criteria.departureTimeFrom != null) {
      final time = criteria.departureTimeFrom!;
      queryParams['departureTimeFrom'] =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }

    final response = await _dio.get('/rides/search', queryParameters: queryParams);

    final List<dynamic> content = response.data['content'] ?? [];
    return content.map((json) => RideResponseDto.fromJson(json)).toList();
  }

  /// Get all rides with pagination.
  Future<List<RideResponseDto>> getAllRides({int page = 0, int size = 10}) async {
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
final rideApiClientProvider = Provider<RideApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RideApiClient(dio);
});
