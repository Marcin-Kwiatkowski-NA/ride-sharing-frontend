import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final MaterialPageRoute route;
  final bool primary;
  const BottomButton({
    required this.text,
    required this.icon,
    super.key,
    required this.route,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    var foregroundColor = Colors.yellow.shade50;
    var foregroundColorPrimary = Colors.blueAccent.shade100;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(route);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          foregroundColor: primary ? foregroundColorPrimary : foregroundColor,
          disabledBackgroundColor: Colors.teal.shade100,
          backgroundColor: Colors.teal.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: primary ? foregroundColorPrimary : foregroundColor,
            ),
            SizedBox(height: 8),
            Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
