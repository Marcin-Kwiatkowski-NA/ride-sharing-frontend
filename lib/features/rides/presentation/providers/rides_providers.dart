import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ride_repository.dart';
import '../../domain/ride_presentation.dart';
import '../../domain/ride_ui_model.dart';
import 'search_criteria_provider.dart';

/// Provider for searching rides based on criteria.
///
/// Uses AsyncValue for proper loading/error/data states.
/// Auto-disposes when no longer used.
final ridesSearchProvider =
    FutureProvider.autoDispose<List<RideUiModel>>((ref) async {
  final criteria = ref.watch(searchCriteriaProvider);
  final repository = ref.watch(rideRepositoryProvider);

  final dtos = await repository.searchRides(criteria);
  return RidePresentation.toUiModels(dtos);
});

/// Provider for a single ride by ID.
///
/// Uses family modifier for parameterized access.
final rideDetailProvider =
    FutureProvider.family.autoDispose<RideUiModel, int>((ref, rideId) async {
  final repository = ref.watch(rideRepositoryProvider);

  final dto = await repository.getRideById(rideId);
  return RidePresentation.toUiModel(dto);
});

/// Provider for all rides (no filter).
final allRidesProvider =
    FutureProvider.autoDispose<List<RideUiModel>>((ref) async {
  final repository = ref.watch(rideRepositoryProvider);

  final dtos = await repository.getAllRides();
  return RidePresentation.toUiModels(dtos);
});
