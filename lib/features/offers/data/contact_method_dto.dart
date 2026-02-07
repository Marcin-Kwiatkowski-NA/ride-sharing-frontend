import 'package:freezed_annotation/freezed_annotation.dart';

import 'offer_enums.dart';

part 'contact_method_dto.freezed.dart';
part 'contact_method_dto.g.dart';

@freezed
sealed class ContactMethodDto with _$ContactMethodDto {
  const factory ContactMethodDto({
    required ContactType type,
    required String value,
  }) = _ContactMethodDto;

  factory ContactMethodDto.fromJson(Map<String, dynamic> json) =>
      _$ContactMethodDtoFromJson(json);
}
