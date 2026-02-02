import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blablafront/features/rides/data/dto/ride_response_dto.dart';
import 'package:blablafront/features/rides/data/dto/city_dto.dart';
import 'package:blablafront/features/rides/data/dto/contact_method_dto.dart';
import 'package:blablafront/features/rides/data/dto/driver_dto.dart';
import 'package:blablafront/features/rides/data/dto/ride_enums.dart';
import 'package:blablafront/features/rides/domain/part_of_day.dart';
import 'package:blablafront/features/rides/domain/ride_presentation.dart';

void main() {
  group('RidePresentation', () {
    RideResponseDto createTestRide({
      int id = 1,
      DateTime? departureTime,
      bool isApproximate = false,
      RideSource source = RideSource.internal,
      double? pricePerSeat,
      int availableSeats = 3,
      int seatsTaken = 0,
      RideStatus rideStatus = RideStatus.open,
      List<ContactMethodDto>? contactMethods,
      int? driverId = 1,
      String? driverName,
      double? driverRating,
      int? driverCompletedRides,
      String? description,
    }) {
      return RideResponseDto(
        id: id,
        origin: const CityDto(name: 'Krakow'),
        destination: const CityDto(name: 'Warsaw'),
        departureTime: departureTime ?? DateTime(2025, 1, 15, 14, 30),
        isApproximate: isApproximate,
        source: source,
        availableSeats: availableSeats,
        seatsTaken: seatsTaken,
        pricePerSeat: pricePerSeat,
        rideStatus: rideStatus,
        driver: DriverDto(
          id: driverId,
          name: driverName,
          rating: driverRating,
          completedRides: driverCompletedRides,
        ),
        contactMethods: contactMethods ?? [],
        description: description,
      );
    }

    group('Time formatting with part-of-day', () {
      test('shows exact time and part-of-day for non-approximate', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 14, 30),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.exactTimeDisplay, '14:30');
        expect(uiModel.partOfDay, PartOfDay.afternoon);
        expect(uiModel.partOfDayDisplay, 'Afternoon');
        expect(uiModel.isTimeUndefined, false);
      });

      test('shows only part-of-day for approximate time', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 14, 30),
          isApproximate: true,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.exactTimeDisplay, null);
        expect(uiModel.partOfDay, PartOfDay.afternoon);
        expect(uiModel.partOfDayDisplay, 'Afternoon');
        expect(uiModel.isTimeUndefined, false);
      });

      test('shows "Ask driver" for 23:57 + approximate', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 23, 57),
          isApproximate: true,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.exactTimeDisplay, null);
        expect(uiModel.partOfDayDisplay, 'Ask driver');
        expect(uiModel.isTimeUndefined, true);
      });

      test('classifies morning correctly (05:00-11:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 8, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.morning);
        expect(uiModel.partOfDayDisplay, 'Morning');
      });

      test('classifies evening correctly (17:00-21:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 19, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.evening);
        expect(uiModel.partOfDayDisplay, 'Evening');
      });

      test('classifies night correctly (22:00-04:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 2, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.night);
        expect(uiModel.partOfDayDisplay, 'Night');
      });
    });

    group('Price formatting', () {
      test('shows "Ask driver" when price is null', () {
        final dto = createTestRide(pricePerSeat: null);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, 'Ask driver');
        expect(uiModel.hasPrice, false);
      });

      test('formats price with PLN currency (no decimals)', () {
        final dto = createTestRide(pricePerSeat: 25.50);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, '26 PLN');
        expect(uiModel.hasPrice, true);
      });

      test('formats whole number price', () {
        final dto = createTestRide(pricePerSeat: 30.0);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, '30 PLN');
      });
    });

    group('Source badges', () {
      test('shows "Verified member" badge for INTERNAL source', () {
        final dto = createTestRide(source: RideSource.internal);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.sourceBadgeText, 'Verified member');
        expect(uiModel.isInternal, true);
        expect(uiModel.sourceBadgeColor, Colors.green.shade700);
      });

      test('shows "Community listing" badge for FACEBOOK source', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.facebookLink,
              value: 'https://facebook.com/post/123',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.sourceBadgeText, 'Community listing');
        expect(uiModel.isInternal, false);
        expect(uiModel.sourceBadgeColor, Colors.orange.shade700);
      });
    });

    group('Contact methods', () {
      test('builds contact methods list with correct order', () {
        final dto = createTestRide(
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.email,
              value: 'test@example.com',
            ),
            const ContactMethodDto(
              type: ContactType.phone,
              value: '+48123456789',
            ),
            const ContactMethodDto(
              type: ContactType.facebookLink,
              value: 'https://facebook.com/post/123',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.contactMethods.length, 3);
        expect(uiModel.contactMethods[0].type, ContactType.phone);
        expect(uiModel.contactMethods[1].type, ContactType.facebookLink);
        expect(uiModel.contactMethods[2].type, ContactType.email);
        expect(uiModel.hasAnyContactAction, true);
      });

      test('phone contact has correct properties', () {
        final dto = createTestRide(
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.phone,
              value: '+48123456789',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.contactMethods[0].label, 'Call');
        expect(uiModel.contactMethods[0].preview, '+48123456789');
        expect(uiModel.contactMethods[0].icon, Icons.phone_outlined);
      });

      test('facebook link contact has correct properties', () {
        final dto = createTestRide(
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.facebookLink,
              value: 'https://facebook.com/post/123',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.contactMethods[0].label, 'Open Facebook post');
        expect(uiModel.contactMethods[0].icon, Icons.open_in_new);
      });

      test('email contact has correct properties', () {
        final dto = createTestRide(
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.email,
              value: 'driver@example.com',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.contactMethods[0].label, 'Send email');
        expect(uiModel.contactMethods[0].preview, 'driver@example.com');
        expect(uiModel.contactMethods[0].icon, Icons.email_outlined);
      });

      test('hasAnyContactAction is false when no contacts and no chat', () {
        final dto = createTestRide(contactMethods: [], driverId: null);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.contactMethods, isEmpty);
        expect(uiModel.hasAnyContactAction, false);
      });
    });

    group('Driver rating', () {
      test('showRating is false when completedRides is null', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: null,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.showRating, false);
      });

      test('showRating is false when completedRides is 0', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: 0,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.showRating, false);
      });

      test('showRating is false when rating is null', () {
        final dto = createTestRide(
          driverRating: null,
          driverCompletedRides: 10,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.showRating, false);
      });

      test('showRating is true when completedRides > 0 and rating exists', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: 10,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.showRating, true);
        expect(uiModel.driverRating, 4.5);
        expect(uiModel.driverCompletedRides, 10);
      });
    });

    group('New fields', () {
      test('seatsTaken is passed through', () {
        final dto = createTestRide(seatsTaken: 2);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.seatsTaken, 2);
      });

      test('description is passed through', () {
        final dto = createTestRide(description: 'No smoking please');

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.description, 'No smoking please');
      });

      test('description is null when not provided', () {
        final dto = createTestRide(description: null);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.description, null);
      });
    });

    group('Seats formatting', () {
      test('formats single seat correctly', () {
        final dto = createTestRide(availableSeats: 1);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.seatsDisplay, '1 seat');
      });

      test('formats multiple seats correctly', () {
        final dto = createTestRide(availableSeats: 3);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.seatsDisplay, '3 seats');
      });
    });

    group('Bookable status', () {
      test('is bookable when status is open and seats available', () {
        final dto = createTestRide(
          rideStatus: RideStatus.open,
          availableSeats: 3,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.isBookable, true);
      });

      test('is not bookable when status is full', () {
        final dto = createTestRide(rideStatus: RideStatus.full);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.isBookable, false);
      });

      test('is not bookable when no seats available', () {
        final dto = createTestRide(
          rideStatus: RideStatus.open,
          availableSeats: 0,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.isBookable, false);
      });

      test('is not bookable when cancelled', () {
        final dto = createTestRide(rideStatus: RideStatus.cancelled);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.isBookable, false);
      });
    });

    group('Route display', () {
      test('formats route with arrow', () {
        final dto = createTestRide();

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.routeDisplay, 'Krakow -> Warsaw');
        expect(uiModel.originName, 'Krakow');
        expect(uiModel.destinationName, 'Warsaw');
      });
    });

    group('Status display', () {
      test('formats open status', () {
        final dto = createTestRide(rideStatus: RideStatus.open);
        expect(RidePresentation.toUiModel(dto).statusDisplay, 'Open');
      });

      test('formats full status', () {
        final dto = createTestRide(rideStatus: RideStatus.full);
        expect(RidePresentation.toUiModel(dto).statusDisplay, 'Full');
      });

      test('formats completed status', () {
        final dto = createTestRide(rideStatus: RideStatus.completed);
        expect(RidePresentation.toUiModel(dto).statusDisplay, 'Completed');
      });

      test('formats cancelled status', () {
        final dto = createTestRide(rideStatus: RideStatus.cancelled);
        expect(RidePresentation.toUiModel(dto).statusDisplay, 'Cancelled');
      });
    });

    group('toUiModels', () {
      test('converts list of DTOs', () {
        final dtos = [
          createTestRide(id: 1),
          createTestRide(id: 2),
          createTestRide(id: 3),
        ];

        final uiModels = RidePresentation.toUiModels(dtos);

        expect(uiModels.length, 3);
        expect(uiModels[0].id, 1);
        expect(uiModels[1].id, 2);
        expect(uiModels[2].id, 3);
      });

      test('returns empty list for empty input', () {
        final uiModels = RidePresentation.toUiModels([]);

        expect(uiModels, isEmpty);
      });
    });
  });
}
