import 'package:blablafront/core/locations/domain/location.dart';
import 'package:blablafront/shared/widgets/route_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Location makeLocation(String name, int osmId) => Location(
        osmId: osmId,
        name: name,
        latitude: 52.0,
        longitude: 21.0,
      );

  Widget buildTimeline({
    Location? origin,
    Location? destination,
    String? originError,
    String? destinationError,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RouteTimeline(
          origin: origin,
          destination: destination,
          onOriginTap: () {},
          onDestinationTap: () {},
          originError: originError,
          destinationError: destinationError,
        ),
      ),
    );
  }

  group('RouteTimeline', () {
    testWidgets('shows placeholder text when no locations selected',
        (tester) async {
      await tester.pumpWidget(buildTimeline());

      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Choose city'), findsNWidgets(2));
    });

    testWidgets('shows city names when origin and destination selected',
        (tester) async {
      await tester.pumpWidget(buildTimeline(
        origin: makeLocation('Warsaw', 1),
        destination: makeLocation('Kraków', 2),
      ));

      expect(find.text('Warsaw'), findsOneWidget);
      expect(find.text('Kraków'), findsOneWidget);
    });

    testWidgets('shows error text when errors are provided', (tester) async {
      await tester.pumpWidget(buildTimeline(
        originError: 'Select origin',
        destinationError: 'Select destination',
      ));

      expect(find.text('Select origin'), findsOneWidget);
      expect(find.text('Select destination'), findsOneWidget);
    });

    testWidgets('calls onOriginTap when origin tile is tapped',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RouteTimeline(
            origin: null,
            destination: null,
            onOriginTap: () => tapped = true,
            onDestinationTap: () {},
          ),
        ),
      ));

      // Tap the first "Choose city" tile (origin)
      await tester.tap(find.text('Choose city').first);
      expect(tapped, isTrue);
    });

    testWidgets('calls onDestinationTap when destination tile is tapped',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RouteTimeline(
            origin: null,
            destination: null,
            onOriginTap: () {},
            onDestinationTap: () => tapped = true,
          ),
        ),
      ));

      // Tap the second "Choose city" tile (destination)
      await tester.tap(find.text('Choose city').last);
      expect(tapped, isTrue);
    });
  });
}
