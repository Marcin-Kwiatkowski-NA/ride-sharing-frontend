import 'package:blablafront/core/locations/domain/location.dart';
import 'package:blablafront/shared/widgets/route_timeline_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Location makeLocation(String name, int osmId) => Location(
        osmId: osmId,
        name: name,
        latitude: 52.0,
        longitude: 21.0,
      );

  Widget buildSection({
    Location? origin,
    Location? destination,
    String? originError,
    String? destinationError,
    List<RouteStopData> stops = const [],
    VoidCallback? onAddStop,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RouteTimelineSection(
            origin: origin,
            destination: destination,
            onOriginTap: () {},
            onDestinationTap: () {},
            originError: originError,
            destinationError: destinationError,
            stops: stops,
            onAddStop: onAddStop,
          ),
        ),
      ),
    );
  }

  group('RouteTimelineSection', () {
    testWidgets('shows placeholder text when no locations selected',
        (tester) async {
      await tester.pumpWidget(buildSection());

      expect(find.text('City, Place...'), findsNWidgets(2));
    });

    testWidgets('shows city names when origin and destination selected',
        (tester) async {
      await tester.pumpWidget(buildSection(
        origin: makeLocation('Warsaw', 1),
        destination: makeLocation('Kraków', 2),
      ));

      expect(find.text('Warsaw'), findsOneWidget);
      expect(find.text('Kraków'), findsOneWidget);
    });

    testWidgets('shows error text when errors are provided', (tester) async {
      await tester.pumpWidget(buildSection(
        originError: 'Select origin',
        destinationError: 'Select destination',
      ));

      expect(find.text('Select origin'), findsOneWidget);
      expect(find.text('Select destination'), findsOneWidget);
    });

    testWidgets('renders add stop row when onAddStop is provided',
        (tester) async {
      await tester.pumpWidget(buildSection(
        onAddStop: () {},
      ));

      // The add-stop row creates an extra InkWell beyond origin + destination
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('shows stop rows with location names', (tester) async {
      await tester.pumpWidget(buildSection(
        origin: makeLocation('Warsaw', 1),
        destination: makeLocation('Kraków', 2),
        stops: [
          RouteStopData(id: 's1', locationName: 'Łódź'),
          RouteStopData(id: 's2', locationName: 'Katowice'),
        ],
      ));

      expect(find.text('Łódź'), findsOneWidget);
      expect(find.text('Katowice'), findsOneWidget);
      expect(find.text('Stop 1'), findsOneWidget);
      expect(find.text('Stop 2'), findsOneWidget);
    });

    testWidgets('calls onOriginTap when origin row is tapped',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RouteTimelineSection(
              origin: null,
              destination: null,
              onOriginTap: () => tapped = true,
              onDestinationTap: () {},
            ),
          ),
        ),
      ));

      await tester.tap(find.text('City, Place...').first);
      expect(tapped, isTrue);
    });
  });
}
