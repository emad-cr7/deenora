import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/iqama/iqama_settings_controller.dart';
import '../../features/widget_prayer_times/models/prayer_times_model.dart';
import '../../features/widget_prayer_times/models/prayer_type.dart';
import 'location_service.dart';

/// A one-off OS notification. IDs are unique by date, prayer and reminder type.
class PrayerNotification {
  final int id;
  final PrayerType prayer;
  final bool isIqama;
  final tz.TZDateTime time;

  const PrayerNotification(this.id, this.prayer, this.isIqama, this.time);

  String get title => isIqama ? 'Iqama Time' : 'Prayer Time';
  String get body => isIqama
      ? "It's time for ${prayer.englishName} Iqama."
      : "It's time for ${prayer.englishName} prayer.";
  String get payload =>
      'deenora_prayer:${time.millisecondsSinceEpoch}:${time.location.name}';
}

class PrayerNotificationPlan {
  /// Verify API date, IANA zone and coordinates against the active location.
  /// An automatic Cairo fallback is never permission to schedule for Cairo.
  static tz.TZDateTime? verifiedDate(
    PrayerTimesModel model,
    UserLocation location,
  ) {
    final meta = model.meta;
    if (location.isFallback ||
        !location.latitude.isFinite ||
        !location.longitude.isFinite ||
        location.latitude.abs() > 90 ||
        location.longitude.abs() > 180 ||
        !meta.latitude.isFinite ||
        !meta.longitude.isFinite ||
        (meta.latitude - location.latitude).abs() > 0.01 ||
        (meta.longitude - location.longitude).abs() > 0.01) {
      return null;
    }
    final match = RegExp(
      r'^(\d{2})-(\d{2})-(\d{4})$',
    ).firstMatch(model.gregorian.date);
    if (match == null) return null;
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    try {
      final zone = tz.getLocation(meta.timezone);
      final date = tz.TZDateTime(zone, year, month, day);
      if (date.year != year ||
          date.month != month ||
          date.day != day ||
          int.tryParse(model.gregorian.day) != day ||
          model.gregorian.monthNumber != month ||
          int.tryParse(model.gregorian.year) != year) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  static List<PrayerNotification> build({
    required Iterable<PrayerTimesModel> timetables,
    required UserLocation location,
    required IqamaSettings iqama,
    required DateTime now,
  }) {
    final events = <int, PrayerNotification>{};
    for (final model in timetables) {
      final date = verifiedDate(model, location);
      if (date == null) continue;
      final localNow = tz.TZDateTime.from(now, date.location);
      // Yesterday can still have a valid Isha Iqama after midnight.
      final firstDate = DateTime.utc(
        localNow.year,
        localNow.month,
        localNow.day - 1,
      );
      final lastDate = DateTime.utc(
        localNow.year,
        localNow.month,
        localNow.day + 1,
      );
      final calendarDate = DateTime.utc(date.year, date.month, date.day);
      if (calendarDate.isBefore(firstDate) || calendarDate.isAfter(lastDate)) {
        continue;
      }

      for (final prayer in IqamaSettings.defaultDelays.keys) {
        final match = RegExp(
          r'^(\d{2}):(\d{2})(?::(\d{2}))?$',
        ).firstMatch(model.timings[prayer] ?? '');
        if (match == null) continue;
        final hour = int.parse(match[1]!);
        final minute = int.parse(match[2]!);
        final second = int.parse(match[3] ?? '0');
        if (hour > 23 || minute > 59 || second > 59) continue;
        final start = tz.TZDateTime(
          date.location,
          date.year,
          date.month,
          date.day,
          hour,
          minute,
          second,
        );
        // Reject DST gaps instead of accepting a silently normalised time.
        if (start.hour != hour ||
            start.minute != minute ||
            start.day != date.day) {
          continue;
        }
        // An API clock time without an offset cannot disambiguate a DST fold.
        final ambiguous = [-60, -30, 30, 60].any((minutes) {
          final other = start.add(Duration(minutes: minutes));
          return other.day == start.day &&
              other.hour == hour &&
              other.minute == minute &&
              other.timeZoneOffset != start.timeZoneOffset;
        });
        if (ambiguous) continue;
        final baseId =
            (date.year * 10000 + date.month * 100 + date.day) * 20 +
            prayer.index * 2;
        if (start.isAfter(now)) {
          events[baseId] = PrayerNotification(baseId, prayer, false, start);
        }
        final iqamaTime = start.add(Duration(minutes: iqama.delays[prayer]!));
        if (iqama.enabled && iqamaTime.isAfter(now)) {
          events[baseId + 1] = PrayerNotification(
            baseId + 1,
            prayer,
            true,
            iqamaTime,
          );
        }
      }
    }
    return events.values.toList()..sort((a, b) => a.time.compareTo(b.time));
  }
}
