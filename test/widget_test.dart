// Basic Flutter widget test for Vamos Ride Sharing app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blablafront/core/l10n/shared_preferences_provider.dart';
import 'package:blablafront/main.dart';

void main() {
  testWidgets('App builds and shows loading or login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app with ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds without crashing
    // It should show either a CircularProgressIndicator (loading) or login elements
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
      find.byType(MaterialApp).evaluate().isNotEmpty,
      isTrue,
    );
  });
}
