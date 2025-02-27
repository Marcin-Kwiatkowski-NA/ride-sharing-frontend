import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to your pubspec.yaml

class DateSearchField extends StatefulWidget {
  const DateSearchField({super.key});

  @override
  _DateSearchFieldState createState() => _DateSearchFieldState();
}

class _DateSearchFieldState extends State<DateSearchField> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Starting date
      firstDate: DateTime(2000), // Lower bound for date selection
      lastDate: DateTime(2100), // Upper bound for date selection
    );
    if (pickedDate != null) {
      setState(() {
        // Format the date using the intl package (e.g., "2025-02-25")
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      readOnly: true, // Prevent manual editing
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white60,
        labelText: 'Select Date',
        labelStyle: Theme.of(context).textTheme.headlineSmall,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context), // Open date picker on tap
    );
  }
}
