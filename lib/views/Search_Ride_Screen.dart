import 'package:flutter/material.dart';
import 'PostRideScreen.dart';
import 'Search_Screen.dart';

class SearchRideScreen extends StatelessWidget {
  const SearchRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SearchScreen(screenNumber: 1),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // This pushes the FAB up
        child: FloatingActionButton.extended(
          onPressed: () {
            // Ensure PostRideScreen is imported if not already
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostRideScreen()),
            );
          },
          label: const Text('POST RIDE'),
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
