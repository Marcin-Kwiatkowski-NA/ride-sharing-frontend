import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/l10n/app_locale_provider.dart';
import '../../../../core/locations/domain/location.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../shared/widgets/departure_picker_helpers.dart';
import '../../../offers/domain/part_of_day.dart';
import '../data/dto/intermediate_stop_dto.dart';
import '../data/dto/ride_creation_request_dto.dart';

part 'post_ride_controller.freezed.dart';
part 'post_ride_controller.g.dart';

const _uuid = Uuid();

/// An intermediate stop entry in the ride creation form.
@freezed
sealed class IntermediateStopEntry with _$IntermediateStopEntry {
  const factory IntermediateStopEntry({
    required String id,
    Location? location,
    TimeOfDay? departureTime,
  }) = _IntermediateStopEntry;
}

/// State for the post ride form.
@freezed
sealed class PostRideFormState with _$PostRideFormState {
  const PostRideFormState._();

  const factory PostRideFormState({
    Location? origin,
    Location? destination,
    DateTime? selectedDate,
    TimeOfDay? exactTime,
    PartOfDay? partOfDay,
    @Default(false) bool isApproximate,
    @Default(1) int availableSeats,
    int? pricePerSeat,
    String? description,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    int? createdRideId,
    @Default(false) bool hasNavigated,
    @Default([]) List<IntermediateStopEntry> intermediateStops,
    @Default(false) bool isNegotiablePrice,
    @Default(false) bool hasAttemptedSubmit,
    @Default(true) bool autoApprove,
  }) = _PostRideFormState;

  // ── Field-level validation errors ──────────────────────────────────────

  String? get originError =>
      origin == null ? 'Select origin from suggestions' : null;

  String? get destinationError {
    if (destination == null) return 'Select destination from suggestions';
    if (origin != null && origin!.osmId == destination!.osmId) {
      return 'Destination must differ from origin';
    }
    return null;
  }

  String? get dateError =>
      selectedDate == null ? 'Select departure date' : null;

  String? get timeError {
    if (isApproximate && partOfDay == null) return 'Select time of day';
    if (!isApproximate && exactTime == null) return 'Select departure time';
    final dt = computedDepartureDateTime;
    if (dt != null) {
      final minDeparture = DateTime.now().add(const Duration(minutes: 30));
      if (dt.isBefore(minDeparture)) {
        return 'Departure must be at least 30 minutes from now';
      }
    }
    return null;
  }

  String? get seatsError {
    if (availableSeats < 1 || availableSeats > 8) return '1-8 seats allowed';
    return null;
  }

  String? get priceError {
    if (isNegotiablePrice) return null;
    if (pricePerSeat == null || pricePerSeat! < 1 || pricePerSeat! > 999) {
      return '1-999 PLN';
    }
    return null;
  }

  String? get stopsError {
    final allOsmIds = <int>{};
    if (origin != null) allOsmIds.add(origin!.osmId);
    if (destination != null) allOsmIds.add(destination!.osmId);
    for (final stop in intermediateStops) {
      if (stop.location == null) return 'Select location for each stop';
      if (stop.departureTime == null) return 'Select time for each stop';
      if (!allOsmIds.add(stop.location!.osmId)) {
        return 'Duplicate stop location';
      }
    }
    return null;
  }

  /// True if all fields are valid.
  bool get isValid =>
      originError == null &&
      destinationError == null &&
      dateError == null &&
      timeError == null &&
      seatsError == null &&
      priceError == null &&
      stopsError == null &&
      (description == null || description!.length <= 500);

  /// Compute the departure DateTime from date and time/partOfDay.
  DateTime? get computedDepartureDateTime {
    if (selectedDate == null) return null;

    if (isApproximate) {
      if (partOfDay == null) return null;
      final hour = switch (partOfDay!) {
        PartOfDay.morning => 8,
        PartOfDay.afternoon => 13,
        PartOfDay.evening => 18,
        PartOfDay.night => 22,
      };
      return DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        hour,
        0,
      );
    } else {
      if (exactTime == null) return null;
      return DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        exactTime!.hour,
        exactTime!.minute,
      );
    }
  }
}

// ── Draft persistence ────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class PostRideDraft extends _$PostRideDraft {
  @override
  PostRideFormState? build() => null;

  void save(PostRideFormState draft) => state = draft;
  void clear() => state = null;
}

// ── Controller ───────────────────────────────────────────────────────────────

@riverpod
class PostRideController extends _$PostRideController {
  @override
  PostRideFormState build() {
    // Restore draft if available
    final draft = ref.read(postRideDraftProvider);
    if (draft != null) {
      // Clear transient fields
      return draft.copyWith(
        isSubmitting: false,
        errorMessage: null,
        createdRideId: null,
        hasNavigated: false,
        hasAttemptedSubmit: false,
      );
    }
    return const PostRideFormState();
  }

  void _saveDraft() {
    ref.read(postRideDraftProvider.notifier).save(state);
  }

  void setOrigin(Location location) {
    state = state.copyWith(origin: location, errorMessage: null);
    _saveDraft();
  }

  void clearOrigin() {
    state = state.copyWith(origin: null, errorMessage: null);
    _saveDraft();
  }

  void setDestination(Location location) {
    state = state.copyWith(destination: location, errorMessage: null);
    _saveDraft();
  }

  void clearDestination() {
    state = state.copyWith(destination: null, errorMessage: null);
    _saveDraft();
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date, errorMessage: null);
    _saveDraft();
  }

  void setExactTime(TimeOfDay time) {
    state = state.copyWith(exactTime: time, errorMessage: null);
    _saveDraft();
  }

  void setPartOfDay(PartOfDay pod) {
    state = state.copyWith(partOfDay: pod, errorMessage: null);
    _saveDraft();
  }

  void setIsApproximate(bool value) {
    state = state.copyWith(
      isApproximate: value,
      exactTime: value ? null : state.exactTime,
      partOfDay: value ? state.partOfDay : null,
      errorMessage: null,
    );
    _saveDraft();
  }

  void setAvailableSeats(int seats) {
    state = state.copyWith(availableSeats: seats, errorMessage: null);
    _saveDraft();
  }

  void setPricePerSeat(int? price) {
    state = state.copyWith(pricePerSeat: price, errorMessage: null);
    _saveDraft();
  }

  void setDescription(String? description) {
    final trimmed = description?.trim();
    state = state.copyWith(
      description: (trimmed?.isEmpty ?? true) ? null : trimmed,
      errorMessage: null,
    );
    _saveDraft();
  }

  void markNavigated() {
    state = state.copyWith(hasNavigated: true);
  }

  void setNegotiablePrice(bool value) {
    state = state.copyWith(isNegotiablePrice: value, errorMessage: null);
    _saveDraft();
  }

  void setAutoApprove(bool value) {
    state = state.copyWith(autoApprove: value, errorMessage: null);
    _saveDraft();
  }

  // ── Intermediate stops ─────────────────────────────────────────────────

  void addIntermediateStop() {
    if (state.intermediateStops.length >= 3) return;
    state = state.copyWith(
      intermediateStops: [
        ...state.intermediateStops,
        IntermediateStopEntry(id: _uuid.v4()),
      ],
      errorMessage: null,
    );
    _saveDraft();
  }

  void removeIntermediateStop(int index) {
    final stops = [...state.intermediateStops]..removeAt(index);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
    _saveDraft();
  }

  void reorderStops(int oldIndex, int newIndex) {
    final stops = [...state.intermediateStops];
    if (newIndex > oldIndex) newIndex--;
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
    _saveDraft();
  }

  void setIntermediateStopLocation(int index, Location location) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(location: location);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
    _saveDraft();
  }

  void clearIntermediateStopLocation(int index) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(location: null);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
    _saveDraft();
  }

  void setIntermediateStopTime(int index, TimeOfDay time) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(departureTime: time);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
    _saveDraft();
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> submit() async {
    state = state.copyWith(
      hasAttemptedSubmit: true,
      hasNavigated: false,
      createdRideId: null,
      errorMessage: null,
    );

    if (!state.isValid) return;

    state = state.copyWith(isSubmitting: true);

    try {
      final departureDateTime = state.computedDepartureDateTime!;
      final formattedDepartureTime =
          formatDepartureTimeForApi(departureDateTime);

      final lang = ref.read(effectiveLocaleProvider).languageCode;

      // Build intermediate stops
      List<IntermediateStopDto>? intermediateStops;

      if (state.intermediateStops.isNotEmpty) {
        DateTime currentBaseDate = state.selectedDate!;
        TimeOfDay previousTime = state.isApproximate
            ? TimeOfDay(hour: departureDateTime.hour, minute: 0)
            : state.exactTime!;

        intermediateStops = [];

        for (final stop in state.intermediateStops) {
          final stopTime = stop.departureTime!;

          // If stop time is "earlier" than previous, it crossed midnight
          if (stopTime.hour < previousTime.hour ||
              (stopTime.hour == previousTime.hour &&
                  stopTime.minute <= previousTime.minute)) {
            currentBaseDate = currentBaseDate.add(const Duration(days: 1));
          }

          final fullDateTime = DateTime(
            currentBaseDate.year,
            currentBaseDate.month,
            currentBaseDate.day,
            stopTime.hour,
            stopTime.minute,
          );

          intermediateStops.add(
            IntermediateStopDto(
              location: stop.location!.toLocationRefDto(lang: lang),
              departureTime: formatDepartureTimeForApi(fullDateTime),
            ),
          );
          previousTime = stopTime;
        }
      }

      final dto = RideCreationRequestDto(
        origin: state.origin!.toLocationRefDto(lang: lang),
        destination: state.destination!.toLocationRefDto(lang: lang),
        departureTime: formattedDepartureTime,
        isApproximate: state.isApproximate,
        availableSeats: state.availableSeats,
        pricePerSeat: state.isNegotiablePrice ? null : state.pricePerSeat,
        vehicleId: null,
        description: state.description,
        intermediateStops:
            intermediateStops?.isNotEmpty == true ? intermediateStops : null,
        autoApprove: state.autoApprove,
      );

      final dio = ref.read(apiDioProvider);
      final response = await dio.post('/rides', data: dto.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final rideId = responseData['id'] as int;

        state = state.copyWith(isSubmitting: false, createdRideId: rideId);
        ref.read(postRideDraftProvider.notifier).clear();
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unexpected response: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Network error. Check your connection.';
      } else {
        errorMessage =
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Failed to create ride';
      }
      state = state.copyWith(isSubmitting: false, errorMessage: errorMessage);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'An error occurred: $e',
      );
    }
  }
}
