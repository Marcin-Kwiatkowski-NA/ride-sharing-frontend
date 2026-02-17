import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vamigo/features/rides/data/dto/ride_response_dto.dart';
import 'package:vamigo/features/offers/data/location_dto.dart';
import 'package:vamigo/features/offers/data/contact_method_dto.dart';
import 'package:vamigo/features/rides/data/dto/user_card_dto.dart';
import 'package:vamigo/features/rides/data/dto/ride_enums.dart';
import 'package:vamigo/features/offers/data/offer_enums.dart';
import 'package:vamigo/features/offers/domain/offer_ui_model.dart';
import 'package:vamigo/features/offers/domain/part_of_day.dart';
import 'package:vamigo/features/rides/domain/ride_presentation.dart';

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
      int driverId = 1,
      String driverName = 'Test Driver',
      double? driverRating,
      int? driverCompletedRides,
      String? description,
    }) {
      return RideResponseDto(
        id: id,
        origin: const LocationDto(osmId: 3094802, name: 'Krakow'),
        destination: const LocationDto(osmId: 756135, name: 'Warsaw'),
        departureTime: departureTime ?? DateTime(2025, 1, 15, 14, 30),
        isApproximate: isApproximate,
        source: source,
        availableSeats: availableSeats,
        seatsTaken: seatsTaken,
        pricePerSeat: pricePerSeat,
        rideStatus: rideStatus,
        driver: UserCardDto(
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
        expect(uiModel.isTimeUndefined, false);
      });

      test('marks as undefined for 23:57 + approximate', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 23, 57),
          isApproximate: true,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.exactTimeDisplay, null);
        expect(uiModel.isTimeUndefined, true);
      });

      test('classifies morning correctly (05:00-11:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 8, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.morning);
      });

      test('classifies evening correctly (17:00-21:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 19, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.evening);
      });

      test('classifies night correctly (22:00-04:59)', () {
        final dto = createTestRide(
          departureTime: DateTime(2025, 1, 15, 2, 0),
          isApproximate: false,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.partOfDay, PartOfDay.night);
      });
    });

    group('Price data', () {
      test('moneyAmount is null when price is null', () {
        final dto = createTestRide(pricePerSeat: null);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.moneyAmount, null);
        expect(uiModel.hasMoneyAmount, false);
      });

      test('moneyAmount carries raw price value', () {
        final dto = createTestRide(pricePerSeat: 25.50);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.moneyAmount, 25.50);
        expect(uiModel.hasMoneyAmount, true);
      });

      test('moneyLabelKind is pricePerSeat for rides', () {
        final dto = createTestRide(pricePerSeat: 30.0);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.moneyLabelKind, MoneyLabelKind.pricePerSeat);
      });
    });

    group('Source data', () {
      test('isExternalSource is false for INTERNAL source', () {
        final dto = createTestRide(source: RideSource.internal);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.isExternalSource, false);
      });

      test('isExternalSource is true for FACEBOOK source', () {
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

        expect(uiModel.isExternalSource, true);
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
        final contacts = uiModel.user!.contactMethods;

        expect(contacts.length, 3);
        expect(contacts[0].type, ContactType.phone);
        expect(contacts[1].type, ContactType.facebookLink);
        expect(contacts[2].type, ContactType.email);
        expect(uiModel.user!.hasAnyContactAction, true);
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
        final contacts = uiModel.user!.contactMethods;

        expect(contacts[0].type, ContactType.phone);
        expect(contacts[0].preview, '+48123456789');
        expect(contacts[0].icon, Icons.phone_outlined);
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
        final contacts = uiModel.user!.contactMethods;

        expect(contacts[0].type, ContactType.facebookLink);
        expect(contacts[0].icon, Icons.open_in_new);
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
        final contacts = uiModel.user!.contactMethods;

        expect(contacts[0].type, ContactType.email);
        expect(contacts[0].preview, 'driver@example.com');
        expect(contacts[0].icon, Icons.email_outlined);
      });

      test('hasAnyContactAction is false when no contacts and no chat', () {
        final dto = createTestRide(
          contactMethods: [],
          source: RideSource.facebook,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.user!.contactMethods, isEmpty);
        expect(uiModel.user!.hasAnyContactAction, false);
      });
    });

    group('Driver rating', () {
      test('showRating is false when completedRides is null', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: null,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.user!.showRating, false);
      });

      test('showRating is false when completedRides is 0', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: 0,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.user!.showRating, false);
      });

      test('showRating is false when rating is null', () {
        final dto = createTestRide(
          driverRating: null,
          driverCompletedRides: 10,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.user!.showRating, false);
      });

      test('showRating is true when completedRides > 0 and rating exists', () {
        final dto = createTestRide(
          driverRating: 4.5,
          driverCompletedRides: 10,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.user!.showRating, true);
        expect(uiModel.user!.rating, 4.5);
        expect(uiModel.user!.completedTrips, 10);
      });
    });

    group('New fields', () {
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

    group('Capacity raw data', () {
      test('carries raw count for single seat', () {
        final dto = createTestRide(availableSeats: 1);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.count, 1);
        expect(uiModel.countLabelKind, CountLabelKind.availableSeats);
      });

      test('carries raw count for multiple seats', () {
        final dto = createTestRide(availableSeats: 3);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.count, 3);
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

    group('Status enum mapping', () {
      test('maps open status', () {
        final dto = createTestRide(rideStatus: RideStatus.open);
        expect(RidePresentation.toUiModel(dto).status, OfferStatus.open);
      });

      test('maps full status', () {
        final dto = createTestRide(rideStatus: RideStatus.full);
        expect(RidePresentation.toUiModel(dto).status, OfferStatus.full);
      });

      test('maps completed status', () {
        final dto = createTestRide(rideStatus: RideStatus.completed);
        expect(RidePresentation.toUiModel(dto).status, OfferStatus.completed);
      });

      test('maps cancelled status', () {
        final dto = createTestRide(rideStatus: RideStatus.cancelled);
        expect(RidePresentation.toUiModel(dto).status, OfferStatus.cancelled);
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
        expect(uiModels[0].offerKey.id, 1);
        expect(uiModels[1].offerKey.id, 2);
        expect(uiModels[2].offerKey.id, 3);
      });

      test('returns empty list for empty input', () {
        final uiModels = RidePresentation.toUiModels([]);

        expect(uiModels, isEmpty);
      });
    });
  });
}
