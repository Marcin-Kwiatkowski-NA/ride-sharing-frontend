import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../offers/data/offer_search_criteria.dart';
import 'recent_search_snapshot.dart';

part 'draft_search_criteria.freezed.dart';

@freezed
sealed class DraftSearchCriteria with _$DraftSearchCriteria {
  const factory DraftSearchCriteria({
    City? origin,
    City? destination,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    @Default(true) bool anyTime,
  }) = _DraftSearchCriteria;

  /// Create a draft from committed search criteria.
  factory DraftSearchCriteria.fromCommitted(OfferSearchCriteria dto) {
    return DraftSearchCriteria(
      origin: dto.origin,
      destination: dto.destination,
      departureDate:
          dto.departureDate != null ? normalizeDate(dto.departureDate!) : null,
      departureTime: dto.departureTimeFrom,
      anyTime: dto.departureTimeFrom == null,
    );
  }

  /// Restore a draft from a recent search snapshot.
  factory DraftSearchCriteria.fromSnapshot(RecentSearchSnapshot snapshot) {
    return DraftSearchCriteria(
      origin: snapshot.origin,
      destination: snapshot.destination,
      departureDate: snapshot.departureDate != null
          ? normalizeDate(snapshot.departureDate!)
          : null,
      departureTime: snapshot.departureTimeHour != null
          ? TimeOfDay(
              hour: snapshot.departureTimeHour!,
              minute: snapshot.departureTimeMinute ?? 0,
            )
          : null,
      anyTime: snapshot.anyTime,
    );
  }
}
