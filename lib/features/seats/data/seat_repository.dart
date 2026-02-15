import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../offers/data/offer_search_criteria.dart';
import '../../offers/data/paginated_response.dart';
import 'dto/seat_creation_request_dto.dart';
import 'dto/seat_response_dto.dart';
import 'seat_api_client.dart';

part 'seat_repository.g.dart';

/// Repository layer for seats.
class SeatRepository {
  final SeatApiClient _apiClient;

  SeatRepository(this._apiClient);

  Future<PaginatedResponse<SeatResponseDto>> searchSeats(
    OfferSearchCriteria criteria,
  ) {
    return _apiClient.searchSeats(criteria);
  }

  /// Search seats by proximity (coordinates + radius).
  Future<PaginatedResponse<SeatResponseDto>> searchSeatsNearby(
    OfferSearchCriteria criteria, {
    required double radiusKm,
  }) {
    return _apiClient.searchSeatsNearby(criteria, radiusKm: radiusKm);
  }

  Future<SeatResponseDto> getSeatById(int seatId) {
    return _apiClient.getSeatById(seatId);
  }

  Future<SeatResponseDto> createSeat(SeatCreationRequestDto dto) {
    return _apiClient.createSeat(dto);
  }

  Future<void> deleteSeat(int seatId) {
    return _apiClient.deleteSeat(seatId);
  }

  Future<List<SeatResponseDto>> getMySeats() {
    return _apiClient.getMySeats();
  }
}

@Riverpod(keepAlive: true)
SeatRepository seatRepository(Ref ref) {
  final apiClient = ref.watch(seatApiClientProvider);
  return SeatRepository(apiClient);
}
