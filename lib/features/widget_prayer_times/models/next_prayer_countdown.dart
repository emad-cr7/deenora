import 'prayer_time_item.dart';
import 'prayer_type.dart';

class NextPrayerCountdown {
  final PrayerType previousPrayer;
  final DateTime previousPrayerTime;
  final Duration passedDuration;

  final PrayerType nextPrayer;
  final DateTime nextPrayerTime;
  final Duration remainingDuration;

  NextPrayerCountdown({
    PrayerType? previousPrayer,
    DateTime? previousPrayerTime,
    Duration? passedDuration,
    required this.nextPrayer,
    required this.nextPrayerTime,
    Duration? remainingDuration,
    Duration? remainingTime,
    PrayerType? currentPrayer,
    Duration? currentElapsed,
  }) : previousPrayer = previousPrayer ?? currentPrayer ?? PrayerType.isha,
       previousPrayerTime =
           previousPrayerTime ??
           nextPrayerTime.subtract(const Duration(hours: 3)),
       passedDuration =
           (passedDuration ?? currentElapsed ?? Duration.zero).isNegative
           ? Duration.zero
           : (passedDuration ?? currentElapsed ?? Duration.zero),
       remainingDuration =
           (remainingDuration ?? remainingTime ?? Duration.zero).isNegative
           ? Duration.zero
           : (remainingDuration ?? remainingTime ?? Duration.zero);

  // Backward compatibility getters
  PrayerType get currentPrayer => previousPrayer;
  DateTime get currentPrayerTime => previousPrayerTime;
  Duration get currentElapsed => passedDuration;
  Duration get remainingTime => remainingDuration;

  /// Formats duration as HH:mm:ss
  static String formatDuration(Duration duration) {
    final nonNegative = duration.isNegative ? Duration.zero : duration;
    final hours = nonNegative.inHours.toString().padLeft(2, '0');
    final minutes = (nonNegative.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (nonNegative.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formats passed duration as "Passed HH:mm:ss"
  String get formattedPassed => 'Passed ${formatDuration(passedDuration)}';

  /// Formats remaining duration as "Remaining HH:mm:ss"
  String get formattedRemaining =>
      'Remaining ${formatDuration(remainingDuration)}';

  /// Formats previous prayer scheduled time in 12-hour format (e.g. "06:45 PM")
  String get formattedPreviousPrayerTime =>
      PrayerTimeItem.format12Hour(previousPrayerTime);

  /// Formats next prayer scheduled time in 12-hour format (e.g. "08:10 PM")
  String get formattedNextPrayerTime =>
      PrayerTimeItem.format12Hour(nextPrayerTime);

  /// Formats remaining countdown as "HH:mm:ss"
  String get formattedCountdown => formatDuration(remainingDuration);

  /// Formats elapsed time since previous prayer started as "HH:mm"
  String get formattedElapsed {
    final hours = passedDuration.inHours.toString().padLeft(2, '0');
    final minutes = (passedDuration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
