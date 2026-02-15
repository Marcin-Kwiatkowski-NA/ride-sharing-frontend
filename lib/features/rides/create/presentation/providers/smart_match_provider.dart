import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/locations/domain/location.dart';
import '../../../../offers/data/offer_search_criteria.dart';
import '../../../../offers/domain/offer_ui_model.dart';
import '../../../../seats/data/seat_repository.dart';
import '../../../../seats/domain/seat_presentation.dart';

part 'smart_match_provider.g.dart';

/// Fetches seat requests matching a newly published ride's route and date.
@riverpod
Future<List<OfferUiModel>> smartMatch(
  Ref ref, {
  required Location origin,
  required Location destination,
  required DateTime departureDate,
}) async {
  final repository = ref.read(seatRepositoryProvider);
  final criteria = OfferSearchCriteria(
    origin: origin,
    destination: destination,
    departureDate: departureDate,
  );
  final response = await repository.searchSeats(criteria);
  return SeatPresentation.toUiModels(response.content);
}
