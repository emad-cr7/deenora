import 'prayer_time_item.dart';
import 'prayer_type.dart';

class CurrentAndPreviousPrayer {
  final PrayerType currentPrayer;
  final DateTime currentScheduledTime;
  final Duration currentElapsed;

  final PrayerType previousPrayer;
  final DateTime previousScheduledTime;
  final Duration previousElapsed;

  const CurrentAndPreviousPrayer({
    required this.currentPrayer,
    required this.currentScheduledTime,
    required this.currentElapsed,
    required this.previousPrayer,
    required this.previousScheduledTime,
    required this.previousElapsed,
  });

  /// 12-hour formatted scheduled time for current prayer (e.g. "12:30 PM")
  String get currentFormattedTime =>
      PrayerTimeItem.format12Hour(currentScheduledTime);

  /// 12-hour formatted scheduled time for previous prayer (e.g. "06:30 AM")
  String get previousFormattedTime =>
      PrayerTimeItem.format12Hour(previousScheduledTime);

  /// Formatted elapsed time for current prayer (e.g. "Passed 01:25 ago")
  String get currentFormattedElapsed {
    final d = currentElapsed.isNegative ? Duration.zero : currentElapsed;
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return 'Passed $hours:$minutes ago';
  }

  /// Formatted elapsed time for previous prayer (e.g. "Passed 06:10 ago")
  String get previousFormattedElapsed {
    final d = previousElapsed.isNegative ? Duration.zero : previousElapsed;
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return 'Passed $hours:$minutes ago';
  }
}
