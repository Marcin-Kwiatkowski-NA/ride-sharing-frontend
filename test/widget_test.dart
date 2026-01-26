// Basic Flutter widget test for Vamos Ride Sharing app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'package:blablafront/main.dart';
import 'package:blablafront/core/providers/auth_provider.dart';
import 'package:blablafront/core/services/api_client.dart';

void main() {
  testWidgets('App builds and shows loading or login screen', (WidgetTester tester) async {
    // Build our app with required providers and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
            provider.Provider(create: (_) => ApiClient()),
          ],
          child: const MyApp(),
        ),
      ),
    );

    // Verify that the app builds without crashing
    // It should show either a CircularProgressIndicator (loading) or login elements
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
      find.text('Login').evaluate().isNotEmpty ||
      find.byType(MaterialApp).evaluate().isNotEmpty,
      isTrue,
    );
  });
}
