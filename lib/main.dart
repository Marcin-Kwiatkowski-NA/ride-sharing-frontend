import 'package:blablafront/views/LoginScreen.dart';
import 'package:blablafront/views/flex_screen.dart';
import 'package:flutter/material.dart';
import 'views/Search_Ride_Screen.dart';
import 'views/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: blablatwoTheme,
      home: SearchRideScreen(),
    );
  }
}

final ThemeData blablatwoTheme = ThemeData(
  brightness: Brightness.light,
  // Create a color scheme from a seed color.
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    elevation: 10,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Roboto', // Ensure this font is available or replace it.
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black87,
      disabledBackgroundColor: Colors.teal.shade100,
      backgroundColor: Colors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      textStyle: TextStyle(
        fontFamily: 'Roboto', // Ensure this font is available or replace it.
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
    ),
  ),
);
