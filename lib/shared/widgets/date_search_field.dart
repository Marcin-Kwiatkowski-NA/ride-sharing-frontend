import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSearchField extends StatefulWidget {
  final Function(DateTime?)? onDateSelected;

  const DateSearchField({super.key, this.onDateSelected});

  @override
  _DateSearchFieldState createState() => _DateSearchFieldState();
}

class _DateSearchFieldState extends State<DateSearchField> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      widget.onDateSelected?.call(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Select Date',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context),
    );
  }
}
