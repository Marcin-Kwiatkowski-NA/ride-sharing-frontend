import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/utils/date_utils.dart';
import '../../presentation/providers/search_mode_provider.dart';
import 'draft_search_criteria.dart';

part 'recent_search_snapshot.freezed.dart';

@freezed
sealed class RecentSearchSnapshot with _$RecentSearchSnapshot {
  const RecentSearchSnapshot._();

  const factory RecentSearchSnapshot({
    City? origin,
    City? destination,
    DateTime? departureDate,
    int? departureTimeHour,
    int? departureTimeMinute,
    @Default(true) bool anyTime,
    @Default(SearchMode.rides) SearchMode mode,
  }) = _RecentSearchSnapshot;

  /// Create from a draft + current search mode.
  factory RecentSearchSnapshot.fromDraft(
    DraftSearchCriteria draft,
    SearchMode mode,
  ) {
    return RecentSearchSnapshot(
      origin: draft.origin,
      destination: draft.destination,
      departureDate: draft.departureDate != null
          ? normalizeDate(draft.departureDate!)
          : null,
      departureTimeHour: draft.departureTime?.hour,
      departureTimeMinute: draft.departureTime?.minute,
      anyTime: draft.anyTime,
      mode: mode,
    );
  }

  /// Human-readable label for display in the recent searches list.
  String get displayLabel {
    final o = origin?.name;
    final d = destination?.name;
    if (o != null && d != null) return '$o \u2192 $d';
    if (o != null) return 'from $o';
    if (d != null) return 'to $d';
    return 'Search';
  }

  /// Stable equality for deduplication (not Dart ==).
  /// Compares: origin placeId + destination placeId + normalized date +
  /// anyTime + (time hour/min if !anyTime) + mode.
  bool isSameSearch(RecentSearchSnapshot other) {
    if (origin?.placeId != other.origin?.placeId) return false;
    if (destination?.placeId != other.destination?.placeId) return false;
    if (mode != other.mode) return false;
    if (anyTime != other.anyTime) return false;

    // Compare normalized dates
    final d1 = departureDate != null ? normalizeDate(departureDate!) : null;
    final d2 = other.departureDate != null
        ? normalizeDate(other.departureDate!)
        : null;
    if (d1 != d2) return false;

    // Compare time only when not anyTime
    if (!anyTime) {
      if (departureTimeHour != other.departureTimeHour) return false;
      if (departureTimeMinute != other.departureTimeMinute) return false;
    }

    return true;
  }

  /// Serialize for SharedPreferences storage.
  Map<String, dynamic> toStorageJson() {
    return {
      if (origin != null) 'origin': origin!.toStorageJson(),
      if (destination != null) 'destination': destination!.toStorageJson(),
      if (departureDate != null)
        'departureDate': departureDate!.toIso8601String(),
      if (departureTimeHour != null) 'departureTimeHour': departureTimeHour,
      if (departureTimeMinute != null)
        'departureTimeMinute': departureTimeMinute,
      'anyTime': anyTime,
      'mode': mode.name,
    };
  }

  /// Deserialize from SharedPreferences storage.
  /// Throws if data is corrupt — caller should catch and discard.
  static RecentSearchSnapshot fromStorageJson(Map<String, dynamic> json) {
    return RecentSearchSnapshot(
      origin: json['origin'] != null
          ? City.fromStorageJson(json['origin'] as Map<String, dynamic>)
          : null,
      destination: json['destination'] != null
          ? City.fromStorageJson(json['destination'] as Map<String, dynamic>)
          : null,
      departureDate: json['departureDate'] != null
          ? DateTime.parse(json['departureDate'] as String)
          : null,
      departureTimeHour: json['departureTimeHour'] as int?,
      departureTimeMinute: json['departureTimeMinute'] as int?,
      anyTime: json['anyTime'] as bool? ?? true,
      mode: SearchMode.values.byName(
        json['mode'] as String? ?? 'rides',
      ),
    );
  }
}
