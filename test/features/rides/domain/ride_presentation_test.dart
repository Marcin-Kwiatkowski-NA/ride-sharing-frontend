import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blablafront/features/rides/data/dto/ride_response_dto.dart';
import 'package:blablafront/features/rides/data/dto/city_dto.dart';
import 'package:blablafront/features/rides/data/dto/contact_method_dto.dart';
import 'package:blablafront/features/rides/data/dto/driver_dto.dart';
import 'package:blablafront/features/rides/data/dto/ride_enums.dart';
import 'package:blablafront/features/rides/domain/ride_presentation.dart';
import 'package:blablafront/features/rides/domain/ride_ui_model.dart';

void main() {
  group('RidePresentation', () {
    RideResponseDto createTestRide({
      int id = 1,
      bool isApproximate = false,
      RideSource source = RideSource.internal,
      double? pricePerSeat,
      int availableSeats = 3,
      int seatsTaken = 0,
      RideStatus rideStatus = RideStatus.open,
      List<ContactMethodDto>? contactMethods,
      String? driverName,
      double? driverRating,
      int? driverCompletedRides,
      String? description,
    }) {
      return RideResponseDto(
        id: id,
        origin: const CityDto(name: 'Krakow'),
        destination: const CityDto(name: 'Warsaw'),
        departureTime: DateTime(2025, 1, 15, 14, 30),
        isApproximate: isApproximate,
        source: source,
        availableSeats: availableSeats,
        seatsTaken: seatsTaken,
        pricePerSeat: pricePerSeat,
        rideStatus: rideStatus,
        driver: DriverDto(
          name: driverName,
          rating: driverRating,
          completedRides: driverCompletedRides,
        ),
        contactMethods: contactMethods ?? [],
        description: description,
      );
    }

    group('Time formatting', () {
      test('formats exact time without tilde', () {
        final dto = createTestRide(isApproximate: false);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.timeDisplay, '14:30');
        expect(uiModel.isApproximate, false);
      });

      test('formats approximate time with tilde', () {
        final dto = createTestRide(isApproximate: true);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.timeDisplay, '~14:30');
        expect(uiModel.isApproximate, true);
      });
    });

    group('Price formatting', () {
      test('shows "Ask driver" when price is null', () {
        final dto = createTestRide(pricePerSeat: null);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, 'Ask driver');
        expect(uiModel.hasPrice, false);
      });

      test('formats price with PLN currency', () {
        final dto = createTestRide(pricePerSeat: 25.50);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, '25.50 PLN');
        expect(uiModel.hasPrice, true);
      });

      test('formats price with two decimal places', () {
        final dto = createTestRide(pricePerSeat: 30.0);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.priceDisplay, '30.00 PLN');
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

    group('CTA logic', () {
      test('sets CTA to "Call driver" when phone contact exists', () {
        final dto = createTestRide(
          contactMethods: [
            const ContactMethodDto(
              type: ContactType.phone,
              value: '+48123456789',
            ),
          ],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'Call driver');
        expect(uiModel.ctaEnabled, true);
        expect(uiModel.ctaType, CtaType.phone);
        expect(uiModel.hasDriverPhone, true);
        expect(uiModel.driverPhone, '+48123456789');
      });

      test('sets CTA to "View original post" for Facebook ride with link', () {
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

        expect(uiModel.ctaText, 'View original post');
        expect(uiModel.ctaEnabled, true);
        expect(uiModel.ctaType, CtaType.link);
        expect(uiModel.hasExternalUrl, true);
        expect(uiModel.sourceUrl, 'https://facebook.com/post/123');
      });

      test('prefers phone over external URL when both exist', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          contactMethods: [
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

        expect(uiModel.ctaText, 'Call driver');
        expect(uiModel.ctaEnabled, true);
        expect(uiModel.ctaType, CtaType.phone);
      });

      test('disables CTA for internal ride without phone', () {
        final dto = createTestRide(
          source: RideSource.internal,
          contactMethods: [],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'No phone available');
        expect(uiModel.ctaEnabled, false);
        expect(uiModel.ctaType, CtaType.disabled);
      });

      test('disables CTA for Facebook ride without contact methods', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          contactMethods: [],
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'Link unavailable');
        expect(uiModel.ctaEnabled, false);
        expect(uiModel.ctaType, CtaType.disabled);
      });

      test('CTA disabled when contactMethods is empty', () {
        final dto = createTestRide(contactMethods: []);

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaEnabled, false);
        expect(uiModel.ctaType, CtaType.disabled);
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

        expect(uiModel.routeDisplay, 'Krakow → Warsaw');
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
