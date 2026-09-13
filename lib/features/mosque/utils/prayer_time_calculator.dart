import '../models/models.dart';

class PrayerTimeCalculator {
  PrayerTimeCalculator._();

  /// Parses a time string like "05:10", "05:10:00", or "05:10 (EET)" into a [DateTime] on [referenceDate].
  static DateTime parseTimeToDateTime(String timeStr, DateTime referenceDate) {
    try {
      final clean = timeStr.trim().split(' ').first;
      final parts = clean.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        hour,
        minute,
      );
    } catch (_) {
      return DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        0,
        0,
      );
    }
  }

  /// Calculates the next prayer countdown and elapsed time since the current prayer.
  static NextPrayerCountdown calculateCountdown(
    PrayerTimesModel model,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final fajrToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.fajr),
      today,
    );
    final sunriseToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.sunrise),
      today,
    );
    final dhuhrToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.dhuhr),
      today,
    );
    final asrToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.asr),
      today,
    );
    final maghribToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.maghrib),
      today,
    );
    final ishaToday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.isha),
      today,
    );

    final ishaYesterday = parseTimeToDateTime(
      model.getTimeFor(PrayerType.isha),
      yesterday,
    );
    final fajrTomorrow = parseTimeToDateTime(
      model.getTimeFor(PrayerType.fajr),
      tomorrow,
    );

    Duration nonNegative(Duration d) => d.isNegative ? Duration.zero : d;

    if (now.isBefore(fajrToday)) {
      // Early morning before Fajr: previous is yesterday's Isha, next is today's Fajr
      return NextPrayerCountdown(
        previousPrayer: PrayerType.isha,
        previousPrayerTime: ishaYesterday,
        passedDuration: nonNegative(now.difference(ishaYesterday)),
        nextPrayer: PrayerType.fajr,
        nextPrayerTime: fajrToday,
        remainingDuration: nonNegative(fajrToday.difference(now)),
      );
    } else if (now.isBefore(sunriseToday)) {
      // Between Fajr and Sunrise: previous is Fajr, next is Sunrise
      return NextPrayerCountdown(
        previousPrayer: PrayerType.fajr,
        previousPrayerTime: fajrToday,
        passedDuration: nonNegative(now.difference(fajrToday)),
        nextPrayer: PrayerType.sunrise,
        nextPrayerTime: sunriseToday,
        remainingDuration: nonNegative(sunriseToday.difference(now)),
      );
    } else if (now.isBefore(dhuhrToday)) {
      // Between Sunrise and Dhuhr: previous is Sunrise, next is Dhuhr
      return NextPrayerCountdown(
        previousPrayer: PrayerType.sunrise,
        previousPrayerTime: sunriseToday,
        passedDuration: nonNegative(now.difference(sunriseToday)),
        nextPrayer: PrayerType.dhuhr,
        nextPrayerTime: dhuhrToday,
        remainingDuration: nonNegative(dhuhrToday.difference(now)),
      );
    } else if (now.isBefore(asrToday)) {
      // Between Dhuhr and Asr: previous is Dhuhr, next is Asr
      return NextPrayerCountdown(
        previousPrayer: PrayerType.dhuhr,
        previousPrayerTime: dhuhrToday,
        passedDuration: nonNegative(now.difference(dhuhrToday)),
        nextPrayer: PrayerType.asr,
        nextPrayerTime: asrToday,
        remainingDuration: nonNegative(asrToday.difference(now)),
      );
    } else if (now.isBefore(maghribToday)) {
      // Between Asr and Maghrib: previous is Asr, next is Maghrib
      return NextPrayerCountdown(
        previousPrayer: PrayerType.asr,
        previousPrayerTime: asrToday,
        passedDuration: nonNegative(now.difference(asrToday)),
        nextPrayer: PrayerType.maghrib,
        nextPrayerTime: maghribToday,
        remainingDuration: nonNegative(maghribToday.difference(now)),
      );
    } else if (now.isBefore(ishaToday)) {
      // Between Maghrib and Isha: previous is Maghrib, next is Isha
      return NextPrayerCountdown(
        previousPrayer: PrayerType.maghrib,
        previousPrayerTime: maghribToday,
        passedDuration: nonNegative(now.difference(maghribToday)),
        nextPrayer: PrayerType.isha,
        nextPrayerTime: ishaToday,
        remainingDuration: nonNegative(ishaToday.difference(now)),
      );
    } else {
      // Night after Isha: previous is today's Isha, next is tomorrow's Fajr
      return NextPrayerCountdown(
        previousPrayer: PrayerType.isha,
        previousPrayerTime: ishaToday,
        passedDuration: nonNegative(now.difference(ishaToday)),
        nextPrayer: PrayerType.fajr,
        nextPrayerTime: fajrTomorrow,
        remainingDuration: nonNegative(fajrTomorrow.difference(now)),
      );
    }
  }

  /// Calculates the current and previous prayer information.
  static CurrentAndPreviousPrayer calculateCurrentAndPrevious(
    PrayerTimesModel model,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final countdown = calculateCountdown(model, now);
    final currentPrayer = countdown.currentPrayer;
    final currentElapsed = countdown.currentElapsed;

    final isEarlyMorningBeforeFajr =
        currentPrayer == PrayerType.isha && now.hour < 12;

    DateTime currentScheduledTime;
    if (isEarlyMorningBeforeFajr) {
      currentScheduledTime = parseTimeToDateTime(
        model.getTimeFor(PrayerType.isha),
        yesterday,
      );
    } else {
      currentScheduledTime = parseTimeToDateTime(
        model.getTimeFor(currentPrayer),
        today,
      );
    }

    final previousPrayer = currentPrayer.previousPrayer;
    DateTime previousScheduledTime;
    if (isEarlyMorningBeforeFajr) {
      previousScheduledTime = parseTimeToDateTime(
        model.getTimeFor(PrayerType.maghrib),
        yesterday,
      );
    } else if (currentPrayer == PrayerType.fajr) {
      previousScheduledTime = parseTimeToDateTime(
        model.getTimeFor(PrayerType.isha),
        yesterday,
      );
    } else {
      previousScheduledTime = parseTimeToDateTime(
        model.getTimeFor(previousPrayer),
        today,
      );
    }

    final previousElapsed = now.difference(previousScheduledTime);

    return CurrentAndPreviousPrayer(
      currentPrayer: currentPrayer,
      currentScheduledTime: currentScheduledTime,
      currentElapsed: currentElapsed,
      previousPrayer: previousPrayer,
      previousScheduledTime: previousScheduledTime,
      previousElapsed: previousElapsed,
    );
  }

  /// Calculates the list of [PrayerTimeItem]s with their individual states and elapsed/remaining times.
  static List<PrayerTimeItem> calculatePrayerItems(
    PrayerTimesModel model,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final countdown = calculateCountdown(model, now);
    final currentPrayer = countdown.currentPrayer;
    final nextPrayer = countdown.nextPrayer;

    final isNightAfterIsha =
        currentPrayer == PrayerType.isha &&
        nextPrayer == PrayerType.fajr &&
        now.hour >= 12;
    final isBeforeFajr =
        currentPrayer == PrayerType.isha &&
        nextPrayer == PrayerType.fajr &&
        now.hour < 12;

    return PrayerType.values.map((type) {
      final scheduledTime = parseTimeToDateTime(model.getTimeFor(type), today);
      final rawTime = model.getTimeFor(type);

      PrayerState state;
      Duration? timeDifference;

      if (isBeforeFajr) {
        // All of today's prayers are ahead
        if (type == PrayerType.fajr) {
          state = PrayerState.next;
          timeDifference = scheduledTime.difference(now);
        } else {
          state = PrayerState.upcoming;
          timeDifference = scheduledTime.difference(now);
        }
      } else if (isNightAfterIsha) {
        // All of today's prayers have passed
        if (type == PrayerType.isha) {
          state = PrayerState.current;
          timeDifference = now.difference(scheduledTime);
        } else {
          state = PrayerState.passed;
          timeDifference = now.difference(scheduledTime);
        }
      } else {
        // During the day
        if (type == currentPrayer) {
          state = PrayerState.current;
          timeDifference = now.difference(scheduledTime);
        } else if (scheduledTime.isBefore(now)) {
          state = PrayerState.passed;
          timeDifference = now.difference(scheduledTime);
        } else if (type == nextPrayer) {
          state = PrayerState.next;
          timeDifference = scheduledTime.difference(now);
        } else {
          state = PrayerState.upcoming;
          timeDifference = scheduledTime.difference(now);
        }
      }

      return PrayerTimeItem(
        type: type,
        scheduledTime: scheduledTime,
        rawTime: rawTime,
        state: state,
        timeDifference: timeDifference,
      );
    }).toList();
  }
}
