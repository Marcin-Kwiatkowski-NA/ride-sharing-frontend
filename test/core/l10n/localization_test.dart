import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vamigo/l10n/generated/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('English locale returns English strings', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(l10n.appTitle, 'Vamos Ride Sharing');
      expect(l10n.loginTitle, 'Login');
      expect(l10n.navRides, 'Rides');
      expect(l10n.navPackages, 'Packages');
      expect(l10n.navProfile, 'Profile');
      expect(l10n.navMessages, 'Messages');
    });

    test('Polish locale returns Polish strings', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('pl'));

      expect(l10n.navRides, 'Przejazdy');
      expect(l10n.navProfile, 'Profil');
      expect(l10n.loginTitle, 'Logowanie');
    });

    test('unsupported locale is not supported by delegate', () {
      // German is not in supportedLocales — fallback is handled by
      // MaterialApp's localeResolutionCallback, not the delegate itself.
      expect(
        AppLocalizations.supportedLocales.any((l) => l.languageCode == 'de'),
        false,
      );
      // English is the first supported locale (fallback)
      expect(AppLocalizations.supportedLocales.first.languageCode, 'en');
    });

    group('English plurals', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('en'));
      });

      test('seatCount singular', () {
        expect(l10n.seatCount(1), '1 seat');
      });

      test('seatCount plural', () {
        expect(l10n.seatCount(3), '3 seats');
      });

      test('passengerCount singular', () {
        expect(l10n.passengerCount(1), '1 passenger');
      });

      test('passengerCount plural', () {
        expect(l10n.passengerCount(5), '5 passengers');
      });
    });

    group('Polish plurals', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('pl'));
      });

      test('seatCount one', () {
        expect(l10n.seatCount(1), '1 miejsce');
      });

      test('seatCount few (2-4)', () {
        expect(l10n.seatCount(3), '3 miejsca');
      });

      test('seatCount many (5+)', () {
        expect(l10n.seatCount(5), '5 miejsc');
      });
    });

    group('Parameterized strings', () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(const Locale('en'));
      });

      test('formattedPrice', () {
        expect(l10n.formattedPrice(30), '30 PLN');
      });

      test('searchRoute', () {
        expect(l10n.searchRoute('Krakow', 'Warsaw'), 'Krakow → Warsaw');
      });

      test('searchFromCity', () {
        expect(l10n.searchFromCity('Krakow'), 'From Krakow');
      });

      test('contactUser', () {
        expect(l10n.contactUser('Jan'), 'Contact Jan');
      });

      test('comingSoon', () {
        expect(l10n.comingSoon('Bookings'), 'Bookings coming soon!');
      });
    });
  });
}
