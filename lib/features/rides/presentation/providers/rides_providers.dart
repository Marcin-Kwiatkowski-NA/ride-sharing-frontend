import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../offers/domain/offer_ui_model.dart';
import '../../data/ride_repository.dart';
import '../../domain/ride_presentation.dart';
import 'search_criteria_provider.dart';

part 'rides_providers.g.dart';

/// Provider for searching rides based on criteria.
///
/// Uses AsyncValue for proper loading/error/data states.
/// Auto-disposes when no longer used (default in codegen).
/// Note: For infinite scroll, use paginatedRidesProvider instead.
@riverpod
Future<List<OfferUiModel>> ridesSearch(Ref ref) async {
  final criteria = ref.watch(searchCriteriaProvider);
  final repository = ref.watch(rideRepositoryProvider);

  final response = await repository.searchRides(criteria);
  return RidePresentation.toUiModels(response.content);
}

/// Provider for all rides (no filter).
///
/// Auto-disposes when no longer used.
@riverpod
Future<List<OfferUiModel>> allRides(Ref ref) async {
  final repository = ref.watch(rideRepositoryProvider);

  final dtos = await repository.getAllRides();
  return RidePresentation.toUiModels(dtos);
}
