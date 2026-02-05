import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blablafront/core/cities/domain/city.dart';
import 'package:blablafront/core/cities/widgets/city_autocomplete_field.dart';
import 'package:blablafront/core/cities/providers/city_providers.dart';
import 'package:blablafront/core/cities/repository/city_repository.dart';
import 'package:blablafront/core/cities/data/city_search_client.dart';
import 'package:dio/dio.dart';

/// Mock implementation of CitySearchClient for testing
class MockCitySearchClient implements CitySearchClient {
  final List<City> mockResults;

  MockCitySearchClient({this.mockResults = const []});

  @override
  String get baseUrl => 'http://test.example.com';

  @override
  Future<List<City>> searchCities({
    required String query,
    required String lang,
    int limit = 10,
    CancelToken? cancelToken,
  }) async {
    return mockResults
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();
  }
}

void main() {
  // Setup SharedPreferences mock for all tests
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      if (methodCall.method == 'setString') {
        return true;
      }
      if (methodCall.method == 'remove') {
        return true;
      }
      return null;
    });
  });

  group('City Model', () {
    test('fromPhotonJson parses GeoJSON correctly', () {
      final json = {
        'properties': {
          'name': 'Warsaw',
          'geonameid': 12345,
          'country_code': 'PL',
          'population': 1700000,
        }
      };

      final city = City.fromPhotonJson(json);

      expect(city.name, 'Warsaw');
      expect(city.placeId, 12345);
      expect(city.countryCode, 'PL');
      expect(city.population, 1700000);
    });

    test('fromPhotonJson handles missing optional fields', () {
      final json = {
        'properties': {
          'name': 'SmallTown',
          'geonameid': 67890,
        }
      };

      final city = City.fromPhotonJson(json);

      expect(city.name, 'SmallTown');
      expect(city.placeId, 67890);
      expect(city.countryCode, isNull);
      expect(city.population, isNull);
    });

    test('fromStorageJson parses stored format correctly', () {
      final json = {
        'name': 'Krakow',
        'placeId': 11111,
        'countryCode': 'PL',
        'population': 760000,
      };

      final city = City.fromStorageJson(json);

      expect(city.name, 'Krakow');
      expect(city.placeId, 11111);
      expect(city.countryCode, 'PL');
      expect(city.population, 760000);
    });

    test('toStorageJson serializes correctly', () {
      const city = City(
        name: 'Poznan',
        placeId: 33333,
        countryCode: 'PL',
        population: 540000,
      );

      final json = city.toStorageJson();

      expect(json['name'], 'Poznan');
      expect(json['placeId'], 33333);
      expect(json['countryCode'], 'PL');
      expect(json['population'], 540000);
    });
  });

  group('CityAutocompleteField Widget', () {
    testWidgets('displays label text', (WidgetTester tester) async {
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityRepositoryProvider.overrideWith((ref) async => repository),
            citySearchLangProvider.overrideWithValue('en'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CityAutocompleteField(
                controller: TextEditingController(),
                labelText: 'Origin City',
                prefixIcon: Icons.location_on,
                onCitySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Wait for async provider to resolve
      await tester.pumpAndSettle();

      expect(find.text('Origin City'), findsOneWidget);
    });

    testWidgets('displays prefix icon', (WidgetTester tester) async {
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityRepositoryProvider.overrideWith((ref) async => repository),
            citySearchLangProvider.overrideWithValue('en'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CityAutocompleteField(
                controller: TextEditingController(),
                labelText: 'Origin City',
                prefixIcon: Icons.trip_origin,
                onCitySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.trip_origin), findsOneWidget);
    });

    testWidgets('validator is called on form validation',
        (WidgetTester tester) async {
      bool validatorCalled = false;
      final formKey = GlobalKey<FormState>();
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityRepositoryProvider.overrideWith((ref) async => repository),
            citySearchLangProvider.overrideWithValue('en'),
          ],
          child: MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      expect(validatorCalled, isTrue);
      expect(find.text('City is required'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityRepositoryProvider.overrideWith((ref) async => repository),
            citySearchLangProvider.overrideWithValue('en'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CityAutocompleteField(
                controller: controller,
                labelText: 'Destination',
                prefixIcon: Icons.flag,
                onCitySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'War');
      await tester.pump();

      expect(find.text('War'), findsOneWidget);
    });

    testWidgets('does not show options initially', (WidgetTester tester) async {
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityRepositoryProvider.overrideWith((ref) async => repository),
            citySearchLangProvider.overrideWithValue('en'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CityAutocompleteField(
                controller: TextEditingController(),
                labelText: 'City',
                prefixIcon: Icons.location_city,
                onCitySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // No ListView should be visible initially (before focus)
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('CityRepository', () {
    test('returns empty list for empty query with no recents', () async {
      final mockClient = MockCitySearchClient();
      final repository = CityRepository(mockClient);

      final results = await repository.searchCities(query: '', lang: 'en');

      expect(results, isEmpty);
    });

    test('filters results by query', () async {
      final mockClient = MockCitySearchClient(
        mockResults: [
          const City(name: 'Warsaw', placeId: 1, countryCode: 'PL'),
          const City(name: 'Wroclaw', placeId: 2, countryCode: 'PL'),
          const City(name: 'Krakow', placeId: 3, countryCode: 'PL'),
        ],
      );
      final repository = CityRepository(mockClient);

      final results = await repository.searchCities(query: 'Wa', lang: 'en');

      expect(results.length, 1);
      expect(results.first.name, 'Warsaw');
    });

    test('sorts by prefix match first', () async {
      final mockClient = MockCitySearchClient(
        mockResults: [
          const City(name: 'New Warsaw', placeId: 1, population: 100000),
          const City(name: 'Warsaw', placeId: 2, population: 1700000),
        ],
      );
      final repository = CityRepository(mockClient);

      final results = await repository.searchCities(query: 'War', lang: 'en');

      expect(results.first.name, 'Warsaw');
    });

    test('sorts by population when prefix match is equal', () async {
      final mockClient = MockCitySearchClient(
        mockResults: [
          const City(name: 'Warsaw Small', placeId: 1, population: 10000),
          const City(name: 'Warsaw Big', placeId: 2, population: 1700000),
        ],
      );
      final repository = CityRepository(mockClient);

      final results = await repository.searchCities(query: 'Warsaw', lang: 'en');

      expect(results.first.name, 'Warsaw Big');
    });
  });
}
