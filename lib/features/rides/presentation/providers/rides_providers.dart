import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/ride_repository.dart';
import '../../domain/ride_presentation.dart';
import '../../domain/ride_ui_model.dart';
import 'search_criteria_provider.dart';

part 'rides_providers.g.dart';

/// Provider for searching rides based on criteria.
///
/// Uses AsyncValue for proper loading/error/data states.
/// Auto-disposes when no longer used (default in codegen).
/// Note: For infinite scroll, use paginatedRidesProvider instead.
@riverpod
Future<List<RideUiModel>> ridesSearch(Ref ref) async {
  final criteria = ref.watch(searchCriteriaProvider);
  final repository = ref.watch(rideRepositoryProvider);

  final response = await repository.searchRides(criteria);
  return RidePresentation.toUiModels(response.content);
}

/// Provider for a single ride by ID.
///
/// Uses function parameter for ride ID (replaces .family modifier).
/// Auto-disposes when no longer used.
@riverpod
Future<RideUiModel> rideDetail(Ref ref, int rideId) async {
  final repository = ref.watch(rideRepositoryProvider);

  final dto = await repository.getRideById(rideId);
  return RidePresentation.toUiModel(dto);
}

/// Provider for all rides (no filter).
///
/// Auto-disposes when no longer used.
@riverpod
Future<List<RideUiModel>> allRides(Ref ref) async {
  final repository = ref.watch(rideRepositoryProvider);

  final dtos = await repository.getAllRides();
  return RidePresentation.toUiModels(dtos);
}
