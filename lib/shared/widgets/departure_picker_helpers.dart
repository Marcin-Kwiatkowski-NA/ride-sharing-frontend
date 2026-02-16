import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Format a picked date for display in date fields.
String formatPickedDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Format a picked TimeOfDay for display in time fields.
String formatPickedTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// Format a DateTime for the API request (ISO 8601, no timezone).
String formatDepartureTimeForApi(DateTime dateTime) =>
    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
