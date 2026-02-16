import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/l10n/app_locale_provider.dart';
import '../../../../core/locations/domain/location.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../offers/domain/part_of_day.dart';
import '../../data/dto/seat_creation_request_dto.dart';

part 'post_seat_controller.freezed.dart';
part 'post_seat_controller.g.dart';

@freezed
sealed class PostSeatFormState with _$PostSeatFormState {
  const PostSeatFormState._();

  const factory PostSeatFormState({
    Location? origin,
    Location? destination,
    DateTime? selectedDate,
    TimeOfDay? exactTime,
    PartOfDay? partOfDay,
    @Default(false) bool isApproximate,
    int? count,
    int? priceWillingToPay,
    String? description,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    int? createdSeatId,
    @Default(false) bool hasNavigated,
  }) = _PostSeatFormState;

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

@riverpod
class PostSeatController extends _$PostSeatController {
  @override
  PostSeatFormState build() {
    return const PostSeatFormState();
  }

  void setOrigin(Location location) {
    state = state.copyWith(origin: location, errorMessage: null);
  }

  void clearOrigin() {
    state = state.copyWith(origin: null, errorMessage: null);
  }

  void setDestination(Location location) {
    state = state.copyWith(destination: location, errorMessage: null);
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
      exactTime: value ? null : state.exactTime,
      partOfDay: value ? state.partOfDay : null,
      errorMessage: null,
    );
  }

  void setCount(int? count) {
    state = state.copyWith(count: count, errorMessage: null);
  }

  void setPriceWillingToPay(int? price) {
    state = state.copyWith(priceWillingToPay: price, errorMessage: null);
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

  String? validate() {
    if (state.origin == null) return 'Select origin from suggestions';
    if (state.destination == null) return 'Select destination from suggestions';
    if (state.origin!.osmId == state.destination!.osmId) {
      return 'Destination must differ from origin';
    }
    if (state.selectedDate == null) return 'Select departure date';
    if (state.isApproximate && state.partOfDay == null) {
      return 'Select departure time';
    }
    if (!state.isApproximate && state.exactTime == null) {
      return 'Select departure time';
    }

    final departureDateTime = state.computedDepartureDateTime;
    if (departureDateTime == null) return 'Select departure time';

    final minDeparture = DateTime.now().add(const Duration(minutes: 30));
    if (departureDateTime.isBefore(minDeparture)) {
      return 'Departure must be at least 30 minutes from now';
    }

    if (state.count == null || state.count! < 1 || state.count! > 8) {
      return '1-8 passengers allowed';
    }
    if (state.priceWillingToPay != null &&
        (state.priceWillingToPay! < 1 || state.priceWillingToPay! > 999)) {
      return 'Budget must be 1-999 PLN';
    }
    if (state.description != null && state.description!.length > 500) {
      return 'Max 500 characters';
    }

    return null;
  }

  Future<void> submit() async {
    state = state.copyWith(
      hasNavigated: false,
      createdSeatId: null,
      errorMessage: null,
    );

    final validationError = validate();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final departureDateTime = state.computedDepartureDateTime!;
      final formattedDepartureTime = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
      ).format(departureDateTime);

      final lang = ref.read(effectiveLocaleProvider).languageCode;

      final dto = SeatCreationRequestDto(
        origin: state.origin!.toLocationRefDto(lang: lang),
        destination: state.destination!.toLocationRefDto(lang: lang),
        departureTime: formattedDepartureTime,
        isApproximate: state.isApproximate,
        count: state.count!,
        priceWillingToPay: state.priceWillingToPay,
        description: state.description,
      );

      final dio = ref.read(apiDioProvider);
      final response = await dio.post('/seats', data: dto.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final seatId = responseData['id'] as int;
        state = state.copyWith(isSubmitting: false, createdSeatId: seatId);
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
            'Failed to create seat request';
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
