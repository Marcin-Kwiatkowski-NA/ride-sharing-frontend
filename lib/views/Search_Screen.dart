import 'package:flutter/material.dart';

import 'Backgroung.dart';
import 'Bottom_Buttons.dart';
import 'Search_Widget.dart';

class SearchScreen extends StatelessWidget {
  final int screenNumber;

  const SearchScreen({super.key, required this.screenNumber});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Background(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SearchWidget(title: findTitle(screenNumber)),
                ),
              ),
              Spacer(),
              Bottom_Buttons(primary: screenNumber),
            ],
          ),
        ),
      ),
    );
  }

  String findTitle(int i) {
    switch (screenNumber) {
      case 1:
        return 'Search Ride';
      case 2:
        return 'Search Passenger';
      default:
        return '';
    }
  }
}