import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/locations/data/location_ref_dto.dart';

part 'intermediate_stop_dto.freezed.dart';
part 'intermediate_stop_dto.g.dart';

/// Request DTO for an intermediate stop in ride creation.
@freezed
sealed class IntermediateStopDto with _$IntermediateStopDto {
  const factory IntermediateStopDto({
    required LocationRefDto location,
    required String departureTime,
  }) = _IntermediateStopDto;

  factory IntermediateStopDto.fromJson(Map<String, dynamic> json) =>
      _$IntermediateStopDtoFromJson(json);
}
