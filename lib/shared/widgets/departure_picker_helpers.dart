import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Format a picked date for display in date fields.
String formatPickedDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Format a picked TimeOfDay for display in time fields (24h).
String formatPickedTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Format a date for the date/time tile display — e.g. "Fri, 24 Feb".
///
/// Pass [locale] (e.g. `Localizations.localeOf(context).toString()`) to
/// format in the user's language.
String formatDateForTile(DateTime date, {String? locale}) =>
    DateFormat('EEE, d MMM', locale).format(date);

/// Format a DateTime for the API request (ISO 8601, no timezone).
String formatDepartureTimeForApi(DateTime dateTime) =>
    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
