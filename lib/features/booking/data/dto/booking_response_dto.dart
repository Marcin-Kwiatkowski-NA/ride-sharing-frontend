import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../rides/data/dto/ride_stop_dto.dart';
import '../../../rides/data/dto/user_card_dto.dart';
import 'booking_enums.dart';

part 'booking_response_dto.freezed.dart';
part 'booking_response_dto.g.dart';

@freezed
sealed class BookingResponseDto with _$BookingResponseDto {
  const factory BookingResponseDto({
    required int id,
    required int rideId,
    required BookingStatus status,
    @Default(1) int seatCount,
    required RideStopDto boardStop,
    required RideStopDto alightStop,
    required UserCardDto passenger,
    required DateTime bookedAt,
    DateTime? resolvedAt,
  }) = _BookingResponseDto;

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseDtoFromJson(json);
}
