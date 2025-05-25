import 'package:blablafront/views/Search_Ride_Screen.dart';
import 'package:blablafront/views/Search_Screen.dart';
import 'package:flutter/material.dart';


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
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.teal, // Primary color for FAB
    foregroundColor: Colors.white, // Icon/text color for FAB
    elevation: 6.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Standard FAB shape
  ),
);