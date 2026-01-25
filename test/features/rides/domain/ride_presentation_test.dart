import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blablafront/features/rides/data/dto/ride_response_dto.dart';
import 'package:blablafront/features/rides/data/dto/city_dto.dart';
import 'package:blablafront/features/rides/data/dto/driver_profile_dto.dart';
import 'package:blablafront/features/rides/data/dto/ride_enums.dart';
import 'package:blablafront/features/rides/domain/ride_presentation.dart';

void main() {
  group('RidePresentation', () {
    RideResponseDto createTestRide({
      int id = 1,
      bool isApproximate = false,
      RideSource source = RideSource.internal,
      double? pricePerSeat,
      int availableSeats = 3,
      RideStatus rideStatus = RideStatus.open,
      String? phoneNumber,
      String? externalUrl,
      String? driverName,
    }) {
      return RideResponseDto(
        id: id,
        origin: const CityDto(name: 'Krakow'),
        destination: const CityDto(name: 'Warsaw'),
        departureTime: DateTime(2025, 1, 15, 14, 30),
        isApproximate: isApproximate,
        source: source,
        availableSeats: availableSeats,
        pricePerSeat: pricePerSeat,
        rideStatus: rideStatus,
        driver: DriverProfileDto(
          id: 1,
          name: driverName,
          phoneNumber: phoneNumber,
        ),
        externalUrl: externalUrl,
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
          externalUrl: 'https://facebook.com/post/123',
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.sourceBadgeText, 'Community listing');
        expect(uiModel.isInternal, false);
        expect(uiModel.sourceBadgeColor, Colors.orange.shade700);
      });
    });

    group('CTA logic', () {
      test('sets CTA to "Call driver" when phone exists', () {
        final dto = createTestRide(phoneNumber: '+48123456789');

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'Call driver');
        expect(uiModel.ctaEnabled, true);
        expect(uiModel.hasDriverPhone, true);
      });

      test('sets CTA to "View original post" for Facebook ride with URL', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          externalUrl: 'https://facebook.com/post/123',
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'View original post');
        expect(uiModel.ctaEnabled, true);
        expect(uiModel.hasExternalUrl, true);
      });

      test('prefers phone over external URL when both exist', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          phoneNumber: '+48123456789',
          externalUrl: 'https://facebook.com/post/123',
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'Call driver');
        expect(uiModel.ctaEnabled, true);
      });

      test('disables CTA for internal ride without phone', () {
        final dto = createTestRide(
          source: RideSource.internal,
          phoneNumber: null,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'No phone available');
        expect(uiModel.ctaEnabled, false);
      });

      test('disables CTA for Facebook ride without URL', () {
        final dto = createTestRide(
          source: RideSource.facebook,
          phoneNumber: null,
          externalUrl: null,
        );

        final uiModel = RidePresentation.toUiModel(dto);

        expect(uiModel.ctaText, 'Link unavailable');
        expect(uiModel.ctaEnabled, false);
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
