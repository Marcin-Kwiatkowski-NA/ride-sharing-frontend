import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../rides/data/ride_repository.dart';
import '../../../rides/domain/ride_presentation.dart';
import '../../../seats/data/seat_repository.dart';
import '../../../seats/domain/seat_presentation.dart';
import '../../domain/offer_ui_model.dart';

part 'my_offers_provider.g.dart';

/// Provider for the current user's offers (rides + seats combined).
///
/// Fetches both /me/rides and /me/seats in parallel, maps to OfferUiModel,
/// and merges into a single list.
@riverpod
Future<List<OfferUiModel>> myOffers(Ref ref) async {
  final rideRepo = ref.watch(rideRepositoryProvider);
  final seatRepo = ref.watch(seatRepositoryProvider);

  final (rideDtos, seatDtos) = await (
    rideRepo.getMyRides(),
    seatRepo.getMySeats(),
  ).wait;

  final rideOffers = RidePresentation.toUiModels(rideDtos);
  final seatOffers = SeatPresentation.toUiModels(seatDtos);

  return [...rideOffers, ...seatOffers];
}
