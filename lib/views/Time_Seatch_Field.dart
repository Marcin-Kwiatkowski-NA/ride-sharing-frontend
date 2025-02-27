import 'package:flutter/material.dart';

class TimeSearchField extends StatefulWidget {
  const TimeSearchField({super.key});

  @override
  _TimeSearchFieldState createState() => _TimeSearchFieldState();
}

class _TimeSearchFieldState extends State<TimeSearchField> {
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Starting time
    );
    if (pickedTime != null) {
      setState(() {
        // Format the time using the context's localization.
        // Alternatively, you can format manually if needed.
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _timeController,
      readOnly: true, // Prevent manual editing
      decoration: InputDecoration(
        labelText: 'Select Time',
        labelStyle: Theme.of(context).textTheme.headlineLarge,
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: () => _selectTime(context), // Open time picker on tap
    );
  }
}
