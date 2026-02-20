import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_ride_request_dto.freezed.dart';
part 'book_ride_request_dto.g.dart';

@freezed
sealed class BookRideRequestDto with _$BookRideRequestDto {
  const factory BookRideRequestDto({
    required int boardStopOsmId,
    required int alightStopOsmId,
    @Default(1) int seatCount,
  }) = _BookRideRequestDto;

  factory BookRideRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BookRideRequestDtoFromJson(json);
}
