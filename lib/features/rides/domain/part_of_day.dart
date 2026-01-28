import 'package:flutter/material.dart';

/// Part-of-day classification for ride departure times.
///
/// Thresholds:
/// - Morning: 05:00 - 11:59
/// - Afternoon: 12:00 - 16:59
/// - Evening: 17:00 - 21:59
/// - Night: 22:00 - 04:59
enum PartOfDay {
  morning,
  afternoon,
  evening,
  night,
}

/// Get part-of-day classification for a given time.
PartOfDay getPartOfDay(DateTime time) {
  final hour = time.hour;

  if (hour >= 5 && hour < 12) {
    return PartOfDay.morning;
  } else if (hour >= 12 && hour < 17) {
    return PartOfDay.afternoon;
  } else if (hour >= 17 && hour < 22) {
    return PartOfDay.evening;
  } else {
    return PartOfDay.night;
  }
}

/// Get localized label for part-of-day.
String partOfDayLabel(PartOfDay pod) {
  switch (pod) {
    case PartOfDay.morning:
      return 'Morning';
    case PartOfDay.afternoon:
      return 'Afternoon';
    case PartOfDay.evening:
      return 'Evening';
    case PartOfDay.night:
      return 'Night';
  }
}

/// Get icon for part-of-day.
IconData partOfDayIcon(PartOfDay pod) {
  switch (pod) {
    case PartOfDay.morning:
      return Icons.wb_sunny_outlined;
    case PartOfDay.afternoon:
      return Icons.wb_sunny;
    case PartOfDay.evening:
      return Icons.wb_twilight;
    case PartOfDay.night:
      return Icons.nightlight_outlined;
  }
}

/// Check if time represents "undefined" (23:57 + approximate).
///
/// This is a special sentinel value indicating the driver hasn't
/// specified a departure time.
bool isTimeUndefined(DateTime time, bool isApproximate) {
  return isApproximate && time.hour == 23 && time.minute == 57;
}
