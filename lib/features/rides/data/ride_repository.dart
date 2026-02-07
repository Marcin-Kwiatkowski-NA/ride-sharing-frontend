import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../offers/data/offer_search_criteria.dart';
import '../../offers/data/paginated_response.dart';
import 'dto/ride_response_dto.dart';
import 'ride_api_client.dart';

part 'ride_repository.g.dart';

/// Repository layer for rides.
///
/// Provides a clean interface for accessing ride data.
/// Can be extended with caching or offline support.
class RideRepository {
  final RideApiClient _apiClient;

  RideRepository(this._apiClient);

  /// Search rides with criteria.
  Future<PaginatedResponse<RideResponseDto>> searchRides(
    OfferSearchCriteria criteria,
  ) {
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

  /// Get current user's booked rides.
  Future<List<RideResponseDto>> getMyRides() {
    return _apiClient.getMyRides();
  }
}

/// Provider for RideRepository.
///
/// Uses keepAlive since this is a service that should persist.
@Riverpod(keepAlive: true)
RideRepository rideRepository(Ref ref) {
  final apiClient = ref.watch(rideApiClientProvider);
  return RideRepository(apiClient);
}
