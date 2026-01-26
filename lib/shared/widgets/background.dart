import 'package:flutter/cupertino.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/road6.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
