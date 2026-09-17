import 'package:intl/intl.dart';

import 'prayer_type.dart';

enum PrayerState { passed, current, next, upcoming }

class PrayerTimeItem {
  static final DateFormat _time12HourFormat = DateFormat('hh:mm a');

  final PrayerType type;
  final DateTime scheduledTime;
  final String rawTime;
  final PrayerState state;
  final Duration? timeDifference;

  const PrayerTimeItem({
    required this.type,
    required this.scheduledTime,
    required this.rawTime,
    required this.state,
    this.timeDifference,
  });

  bool get isPassed => state == PrayerState.passed;
  bool get isCurrent => state == PrayerState.current;
  bool get isNext => state == PrayerState.next;
  bool get isUpcoming => state == PrayerState.upcoming;

  /// Returns 12-hour formatted time with 2-digit hour (e.g., "05:10 AM", "12:30 PM", "04:45 PM")
  String get formatted12Hour => format12Hour(scheduledTime);

  /// Formats any [DateTime] into a standard 12-hour string (e.g. "05:10 AM", "12:00 PM")
  static String format12Hour(DateTime dateTime) {
    return _time12HourFormat.format(dateTime);
  }

  /// Returns elapsed duration formatted like "05:32"
  String get formattedElapsed {
    if (timeDifference == null) return '00:00';
    final d = timeDifference!;
    final hours = d.inHours.abs().toString().padLeft(2, '0');
    final minutes = (d.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Human-readable status label, e.g.:
  /// - "Passed 05:32 ago"
  /// - "Active now"
  /// - "In 01:25"
  String get statusText {
    switch (state) {
      case PrayerState.passed:
        return 'Passed $formattedElapsed ago';
      case PrayerState.current:
        return 'Current Prayer';
      case PrayerState.next:
        return 'Next Prayer';
      case PrayerState.upcoming:
        return 'Upcoming';
    }
  }
}
