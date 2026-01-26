import 'package:flutter/material.dart';
import 'search_screen.dart';

class SearchRideScreen extends StatelessWidget {
  const SearchRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: FAB is now handled by MainLayout
    return const SearchScreen(screenNumber: 1);
  }
}
