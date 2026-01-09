import 'package:blablafront/views/Search_Passenger_Screen.dart';
import 'package:blablafront/views/Search_Ride_Screen.dart';
import 'package:blablafront/views/profile_screen.dart';
import 'package:flutter/material.dart';

import 'Bottom_Button.dart';

class Bottom_Buttons extends StatelessWidget {
  final int primary;

  const Bottom_Buttons({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    var buttonsSize = 80.0;
    return SizedBox(
      height: buttonsSize,
      child: Row(
        children: [
          BottomButton(
            icon: Icons.directions_car,
            text: 'Rides',
            route: MaterialPageRoute(builder: (_) => SearchRideScreen()),
            primary: primary == 1 ? true : false,
          ),
          BottomButton(
            icon: Icons.accessibility_rounded,
            text: 'Passengers',
            route: MaterialPageRoute(builder: (_) => SearchPassengerScreen()),
            primary: primary == 2 ? true : false,
          ),
          BottomButton(
            icon: Icons.account_box_rounded,
            text: 'Profile',
            route: MaterialPageRoute(builder: (_) => const ProfileScreen()),
            primary: primary == 3 ? true : false,
          ),
        ],
      ),
    );
  }
}
