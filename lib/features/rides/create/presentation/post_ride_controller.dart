import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../offers/domain/part_of_day.dart';
import '../data/dto/ride_creation_request_dto.dart';

part 'post_ride_controller.freezed.dart';
part 'post_ride_controller.g.dart';

/// An intermediate stop entry in the ride creation form.
@freezed
sealed class IntermediateStopEntry with _$IntermediateStopEntry {
  const factory IntermediateStopEntry({
    City? city,
    TimeOfDay? departureTime,
  }) = _IntermediateStopEntry;
}

/// State for the post ride form.
@freezed
sealed class PostRideFormState with _$PostRideFormState {
  const PostRideFormState._();

  const factory PostRideFormState({
    City? origin,
    City? destination,
    DateTime? selectedDate,
    TimeOfDay? exactTime,
    PartOfDay? partOfDay,
    @Default(false) bool isApproximate,
    int? availableSeats,
    int? pricePerSeat,
    String? description,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    int? createdRideId,
    @Default(false) bool hasNavigated,
    @Default([]) List<IntermediateStopEntry> intermediateStops,
    @Default(false) bool isNegotiablePrice,
  }) = _PostRideFormState;

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

/// Controller for the post ride form using Riverpod code generation.
@riverpod
class PostRideController extends _$PostRideController {
  @override
  PostRideFormState build() {
    return const PostRideFormState();
  }

  void setOrigin(City city) {
    state = state.copyWith(origin: city, errorMessage: null);
  }

  void clearOrigin() {
    state = state.copyWith(origin: null, errorMessage: null);
  }

  void setDestination(City city) {
    state = state.copyWith(destination: city, errorMessage: null);
  }

  void clearDestination() {
    state = state.copyWith(destination: null, errorMessage: null);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date, errorMessage: null);
  }

  void setExactTime(TimeOfDay time) {
    state = state.copyWith(exactTime: time, errorMessage: null);
  }

  void setPartOfDay(PartOfDay pod) {
    state = state.copyWith(partOfDay: pod, errorMessage: null);
  }

  void setIsApproximate(bool value) {
    state = state.copyWith(
      isApproximate: value,
      // Clear the other time field when switching modes
      exactTime: value ? null : state.exactTime,
      partOfDay: value ? state.partOfDay : null,
      errorMessage: null,
    );
  }

  void setAvailableSeats(int? seats) {
    state = state.copyWith(availableSeats: seats, errorMessage: null);
  }

  void setPricePerSeat(int? price) {
    state = state.copyWith(pricePerSeat: price, errorMessage: null);
  }

  void setDescription(String? description) {
    final trimmed = description?.trim();
    state = state.copyWith(
      description: (trimmed?.isEmpty ?? true) ? null : trimmed,
      errorMessage: null,
    );
  }

  void markNavigated() {
    state = state.copyWith(hasNavigated: true);
  }

  void addIntermediateStop() {
    if (state.intermediateStops.length >= 3) return;
    state = state.copyWith(
      intermediateStops: [...state.intermediateStops, const IntermediateStopEntry()],
      errorMessage: null,
    );
  }

  void removeIntermediateStop(int index) {
    final stops = [...state.intermediateStops]..removeAt(index);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
  }

  void setIntermediateStopCity(int index, City city) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(city: city);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
  }

  void clearIntermediateStopCity(int index) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(city: null);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
  }

  void setIntermediateStopTime(int index, TimeOfDay time) {
    final stops = [...state.intermediateStops];
    stops[index] = stops[index].copyWith(departureTime: time);
    state = state.copyWith(intermediateStops: stops, errorMessage: null);
  }

  void setNegotiablePrice(bool value) {
    state = state.copyWith(isNegotiablePrice: value, errorMessage: null);
  }

  /// Validate the form and return error message if invalid.
  String? validate() {
    if (state.origin == null) {
      return 'Select origin from suggestions';
    }
    if (state.destination == null) {
      return 'Select destination from suggestions';
    }
    if (state.origin!.placeId == state.destination!.placeId) {
      return 'Destination must differ from origin';
    }
    if (state.selectedDate == null) {
      return 'Select departure date';
    }
    if (state.isApproximate && state.partOfDay == null) {
      return 'Select departure time';
    }
    if (!state.isApproximate && state.exactTime == null) {
      return 'Select departure time';
    }

    final departureDateTime = state.computedDepartureDateTime;
    if (departureDateTime == null) {
      return 'Select departure time';
    }

    final minDeparture = DateTime.now().add(const Duration(minutes: 30));
    if (departureDateTime.isBefore(minDeparture)) {
      return 'Departure must be at least 30 minutes from now';
    }

    if (state.availableSeats == null ||
        state.availableSeats! < 1 ||
        state.availableSeats! > 8) {
      return '1-8 seats allowed';
    }
    if (!state.isNegotiablePrice &&
        (state.pricePerSeat == null ||
            state.pricePerSeat! < 1 ||
            state.pricePerSeat! > 999)) {
      return '1-999 PLN';
    }

    // Validate intermediate stops
    final allPlaceIds = <int>{};
    if (state.origin != null) allPlaceIds.add(state.origin!.placeId);
    if (state.destination != null) allPlaceIds.add(state.destination!.placeId);

    for (final stop in state.intermediateStops) {
      if (stop.city == null) return 'Select city for each stop';
      if (stop.departureTime == null) return 'Select time for each stop';
      if (!allPlaceIds.add(stop.city!.placeId)) {
        return 'Duplicate stop city';
      }
    }

    if (state.description != null && state.description!.length > 500) {
      return 'Max 500 characters';
    }

    return null;
  }

  /// Submit the ride creation request.
  Future<void> submit() async {
    // Reset navigation state FIRST to allow re-navigation on retry
    state = state.copyWith(
      hasNavigated: false,
      createdRideId: null,
      errorMessage: null,
    );

    // Validate
    final validationError = validate();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return;
    }

    // Get driver ID from auth
    final authState = ref.read(authProvider);
    final driverId = authState.currentUser?.id;
    if (driverId == null) {
      state = state.copyWith(errorMessage: 'Not authenticated');
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final departureDateTime = state.computedDepartureDateTime!;
      final formattedDepartureTime = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
      ).format(departureDateTime);

      // Build intermediate stop ISO times with midnight-crossing detection
      final List<int> stopPlaceIds = [];
      final List<String> stopDepartureTimes = [];

      if (state.intermediateStops.isNotEmpty) {
        DateTime currentBaseDate = state.selectedDate!;
        TimeOfDay previousTime = state.isApproximate
            ? TimeOfDay(hour: departureDateTime.hour, minute: 0)
            : state.exactTime!;

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

          stopPlaceIds.add(stop.city!.placeId);
          stopDepartureTimes.add(
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(fullDateTime),
          );
          previousTime = stopTime;
        }
      }

      final dto = RideCreationRequestDto(
        driverId: driverId,
        originPlaceId: state.origin!.placeId,
        destinationPlaceId: state.destination!.placeId,
        departureTime: formattedDepartureTime,
        isApproximate: state.isApproximate,
        availableSeats: state.availableSeats!,
        pricePerSeat: state.isNegotiablePrice ? null : state.pricePerSeat,
        vehicleId: null,
        description: state.description,
        intermediateStopPlaceIds:
            stopPlaceIds.isNotEmpty ? stopPlaceIds : null,
        intermediateStopDepartureTimes:
            stopDepartureTimes.isNotEmpty ? stopDepartureTimes : null,
      );

      final dio = ref.read(apiDioProvider);
      final response = await dio.post('/rides', data: dto.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final rideId = responseData['id'] as int;

        state = state.copyWith(isSubmitting: false, createdRideId: rideId);
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
