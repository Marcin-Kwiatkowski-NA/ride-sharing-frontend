import '../data/dto/booking_response_dto.dart';
import 'booking_ui_model.dart';

/// Maps [BookingResponseDto] to [BookingUiModel] for display.
class BookingPresentation {
  static BookingUiModel toUiModel(BookingResponseDto dto) {
    return BookingUiModel(
      bookingId: dto.id,
      rideId: dto.rideId,
      status: dto.status,
      seatCount: dto.seatCount,
      boardStopName: dto.boardStop.location.name,
      alightStopName: dto.alightStop.location.name,
      departureTime: dto.boardStop.departureTime ?? dto.bookedAt,
      bookedAt: dto.bookedAt,
      resolvedAt: dto.resolvedAt,
    );
  }

  static List<BookingUiModel> toUiModels(List<BookingResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }
}
