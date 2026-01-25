import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dto/ride_response_dto.dart';
import 'dto/search_criteria_dto.dart';
import 'ride_api_client.dart';

/// Repository layer for rides.
///
/// Provides a clean interface for accessing ride data.
/// Can be extended with caching or offline support.
class RideRepository {
  final RideApiClient _apiClient;

  RideRepository(this._apiClient);

  /// Search rides with criteria.
  Future<List<RideResponseDto>> searchRides(SearchCriteriaDto criteria) {
    return _apiClient.searchRides(criteria);
  }

  /// Get all rides with pagination.
  Future<List<RideResponseDto>> getAllRides({int page = 0, int size = 10}) {
    return _apiClient.getAllRides(page: page, size: size);
  }

  /// Get ride by ID.
  Future<RideResponseDto> getRideById(int rideId) {
    return _apiClient.getRideById(rideId);
  }
}

/// Provider for RideRepository.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  final apiClient = ref.watch(rideApiClientProvider);
  return RideRepository(apiClient);
});
