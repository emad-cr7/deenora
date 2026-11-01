import 'package:hive_ce_flutter/hive_flutter.dart';

import 'hijri_date_model.dart';
import 'prayer_date_model.dart';
import 'prayer_meta_model.dart';
import 'prayer_type.dart';

part 'prayer_times_model.g.dart';

@HiveType(typeId: 9)
class PrayerTimesModel {
  @HiveField(0)
  final Map<PrayerType, String> timings;
  @HiveField(1)
  final String imsak;
  @HiveField(2)
  final String sunset;
  @HiveField(3)
  final String midnight;
  @HiveField(4)
  final String firstThird;
  @HiveField(5)
  final String lastThird;

  @HiveField(6)
  final String readableDate;
  @HiveField(7)
  final HijriDateModel hijri;
  @HiveField(8)
  final PrayerDateModel gregorian;
  @HiveField(9)
  final PrayerMetaModel meta;

  PrayerTimesModel({
    required this.timings,
    required this.imsak,
    required this.sunset,
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
    required this.readableDate,
    required this.hijri,
    required this.gregorian,
    required this.meta,
  });

  /// Sanitizes time strings like "05:10 (EET)" or "05:10" into "05:10"
  static String cleanTime(String? raw) {
    if (raw == null || raw.isEmpty) return '00:00';
    return raw.trim().split(' ').first;
  }

  String getTimeFor(PrayerType type) {
    return timings[type] ?? '00:00';
  }

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final rawTimings = (data['timings'] as Map<String, dynamic>?) ?? {};

    final timingsMap = <PrayerType, String>{
      PrayerType.fajr: cleanTime(rawTimings['Fajr'] as String?),
      PrayerType.sunrise: cleanTime(rawTimings['Sunrise'] as String?),
      PrayerType.dhuhr: cleanTime(rawTimings['Dhuhr'] as String?),
      PrayerType.asr: cleanTime(rawTimings['Asr'] as String?),
      PrayerType.maghrib: cleanTime(rawTimings['Maghrib'] as String?),
      PrayerType.isha: cleanTime(rawTimings['Isha'] as String?),
    };

    final dateJson = (data['date'] as Map<String, dynamic>?) ?? {};
    final metaJson = (data['meta'] as Map<String, dynamic>?) ?? {};

    return PrayerTimesModel(
      timings: timingsMap,
      imsak: cleanTime(rawTimings['Imsak'] as String?),
      sunset: cleanTime(rawTimings['Sunset'] as String?),
      midnight: cleanTime(rawTimings['Midnight'] as String?),
      firstThird: cleanTime(rawTimings['Firstthird'] as String?),
      lastThird: cleanTime(rawTimings['Lastthird'] as String?),
      readableDate: (dateJson['readable'] as String?) ?? '',
      hijri: HijriDateModel.fromJson(
        (dateJson['hijri'] as Map<String, dynamic>?) ?? {},
      ),
      gregorian: PrayerDateModel.fromJson(
        (dateJson['gregorian'] as Map<String, dynamic>?) ?? {},
      ),
      meta: PrayerMetaModel.fromJson(metaJson),
    );
  }
}
