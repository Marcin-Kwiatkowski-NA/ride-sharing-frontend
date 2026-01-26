import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blablafront/shared/widgets/city_autocomplete_field.dart';
import 'package:blablafront/models/City.dart';

void main() {
  group('City Model', () {
    test('fromJson parses GeoJSON correctly', () {
      final json = {
        'properties': {
          'name': 'Warsaw',
          'osm_id': 12345,
        }
      };

      final city = City.fromJson(json);

      expect(city.name, 'Warsaw');
      expect(city.osmId, 12345);
    });

    test('fromJson handles missing name', () {
      final json = {
        'properties': {
          'osm_id': 12345,
        }
      };

      final city = City.fromJson(json);

      expect(city.name, 'Unknown City');
      expect(city.osmId, 12345);
    });

    test('displayName returns formatted string', () {
      final city = City(name: 'Krakow', osmId: 67890);

      expect(city.displayName, 'Krakow, 67890');
    });
  });

  group('CityAutocompleteField Widget', () {
    testWidgets('displays label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityAutocompleteField(
              controller: TextEditingController(),
              labelText: 'Origin City',
              prefixIcon: Icons.location_on,
              onCitySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Origin City'), findsOneWidget);
    });

    testWidgets('displays prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityAutocompleteField(
              controller: TextEditingController(),
              labelText: 'Origin City',
              prefixIcon: Icons.trip_origin,
              onCitySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trip_origin), findsOneWidget);
    });

    testWidgets('validator is called on form validation', (WidgetTester tester) async {
      bool validatorCalled = false;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CityAutocompleteField(
                controller: TextEditingController(),
                labelText: 'Origin City',
                prefixIcon: Icons.location_on,
                onCitySelected: (_) {},
                validator: (value) {
                  validatorCalled = true;
                  if (value == null || value.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(validatorCalled, isTrue);
      expect(find.text('City is required'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityAutocompleteField(
              controller: controller,
              labelText: 'Destination',
              prefixIcon: Icons.flag,
              onCitySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'War');
      await tester.pump();

      // The internal field controller should have the text
      expect(find.text('War'), findsOneWidget);
    });

    testWidgets('does not show options initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityAutocompleteField(
              controller: TextEditingController(),
              labelText: 'City',
              prefixIcon: Icons.location_city,
              onCitySelected: (_) {},
            ),
          ),
        ),
      );

      // No ListView should be visible initially
      expect(find.byType(ListView), findsNothing);
    });
  });
}
