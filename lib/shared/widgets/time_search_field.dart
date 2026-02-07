import 'package:flutter/material.dart';

class TimeSearchField extends StatefulWidget {
  final Function(TimeOfDay?) onTimeSelected;
  final TimeOfDay? initialTime;

  const TimeSearchField({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
  });

  @override
  _TimeSearchFieldState createState() => _TimeSearchFieldState();
}

class _TimeSearchFieldState extends State<TimeSearchField> {
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      _selectedTime = widget.initialTime;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _timeController.text = widget.initialTime!.format(context);
      });
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _timeController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Select Time',
        suffixIcon: Icon(Icons.access_time),
      ),
      onTap: () => _selectTime(context),
    );
  }
}
