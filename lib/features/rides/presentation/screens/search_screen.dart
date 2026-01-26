import 'package:flutter/material.dart';

import '../../../../shared/widgets/background.dart';
import '../widgets/search_widget.dart';

class SearchScreen extends StatelessWidget {
  final int screenNumber;

  const SearchScreen({super.key, required this.screenNumber});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Background(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SearchWidget(title: findTitle(screenNumber)),
                ),
              ),
              const Spacer(),
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
