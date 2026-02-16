import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/l10n/app_locale_provider.dart';
import '../../../../core/locations/domain/location.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../shared/widgets/departure_picker_helpers.dart';
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
    @Default(1) int count,
    int? priceWillingToPay,
    String? description,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    int? createdSeatId,
    @Default(false) bool hasNavigated,
    @Default(false) bool hasAttemptedSubmit,
  }) = _PostSeatFormState;

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

  String? get countError {
    if (count < 1 || count > 8) return '1-8 passengers allowed';
    return null;
  }

  String? get priceError {
    if (priceWillingToPay != null &&
        (priceWillingToPay! < 1 || priceWillingToPay! > 999)) {
      return 'Budget must be 1-999 PLN';
    }
    return null;
  }

  bool get isValid =>
      originError == null &&
      destinationError == null &&
      dateError == null &&
      timeError == null &&
      countError == null &&
      priceError == null &&
      (description == null || description!.length <= 500);

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
class PostSeatDraft extends _$PostSeatDraft {
  @override
  PostSeatFormState? build() => null;

  void save(PostSeatFormState draft) => state = draft;
  void clear() => state = null;
}

// ── Controller ───────────────────────────────────────────────────────────────

@riverpod
class PostSeatController extends _$PostSeatController {
  @override
  PostSeatFormState build() {
    final draft = ref.read(postSeatDraftProvider);
    if (draft != null) {
      return draft.copyWith(
        isSubmitting: false,
        errorMessage: null,
        createdSeatId: null,
        hasNavigated: false,
        hasAttemptedSubmit: false,
      );
    }
    return const PostSeatFormState();
  }

  void _saveDraft() {
    ref.read(postSeatDraftProvider.notifier).save(state);
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

  void setCount(int count) {
    state = state.copyWith(count: count, errorMessage: null);
    _saveDraft();
  }

  void setPriceWillingToPay(int? price) {
    state = state.copyWith(priceWillingToPay: price, errorMessage: null);
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

  Future<void> submit() async {
    state = state.copyWith(
      hasAttemptedSubmit: true,
      hasNavigated: false,
      createdSeatId: null,
      errorMessage: null,
    );

    if (!state.isValid) return;

    state = state.copyWith(isSubmitting: true);

    try {
      final departureDateTime = state.computedDepartureDateTime!;
      final formattedDepartureTime =
          formatDepartureTimeForApi(departureDateTime);

      final lang = ref.read(effectiveLocaleProvider).languageCode;

      final dto = SeatCreationRequestDto(
        origin: state.origin!.toLocationRefDto(lang: lang),
        destination: state.destination!.toLocationRefDto(lang: lang),
        departureTime: formattedDepartureTime,
        isApproximate: state.isApproximate,
        count: state.count,
        priceWillingToPay: state.priceWillingToPay,
        description: state.description,
      );

      final dio = ref.read(apiDioProvider);
      final response = await dio.post('/seats', data: dto.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final seatId = responseData['id'] as int;
        state = state.copyWith(isSubmitting: false, createdSeatId: seatId);
        ref.read(postSeatDraftProvider.notifier).clear();
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
