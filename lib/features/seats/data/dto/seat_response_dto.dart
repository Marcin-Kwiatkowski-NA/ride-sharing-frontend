import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../offers/data/city_dto.dart';
import '../../../offers/data/contact_method_dto.dart';
import '../../../offers/data/offer_enums.dart';
import '../../../rides/data/dto/user_card_dto.dart';
import 'seat_enums.dart';

part 'seat_response_dto.freezed.dart';
part 'seat_response_dto.g.dart';

@freezed
sealed class SeatResponseDto with _$SeatResponseDto {
  const factory SeatResponseDto({
    required int id,
    @Default(RideSource.internal) RideSource source,
    required CityDto origin,
    required CityDto destination,
    required DateTime departureTime,
    @Default(false) bool isApproximate,
    required int count,
    double? priceWillingToPay,
    String? description,
    UserCardDto? passenger,
    @Default([]) List<ContactMethodDto> contactMethods,
    @Default(SeatStatus.searching) SeatStatus seatStatus,
  }) = _SeatResponseDto;

  factory SeatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SeatResponseDtoFromJson(json);
}
