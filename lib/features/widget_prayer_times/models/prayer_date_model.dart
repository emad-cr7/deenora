import 'package:hive_ce_flutter/hive_flutter.dart';

part 'prayer_date_model.g.dart';

@HiveType(typeId: 6)
class PrayerDateModel {
  @HiveField(0)
  final String date;
  @HiveField(1)
  final String day;
  @HiveField(2)
  final String weekdayEn;
  @HiveField(3)
  final String monthEn;
  @HiveField(4)
  final int monthNumber;
  @HiveField(5)
  final String year;

  PrayerDateModel({
    required this.date,
    required this.day,
    required this.weekdayEn,
    required this.monthEn,
    required this.monthNumber,
    required this.year,
  });

  String get formatted => '$weekdayEn, $day $monthEn $year';

  factory PrayerDateModel.fromJson(Map<String, dynamic> json) {
    final weekday = (json['weekday'] as Map<String, dynamic>?) ?? {};
    final month = (json['month'] as Map<String, dynamic>?) ?? {};

    return PrayerDateModel(
      date: (json['date'] as String?) ?? '',
      day: json['day']?.toString() ?? '',
      weekdayEn: (weekday['en'] as String?) ?? '',
      monthEn: (month['en'] as String?) ?? '',
      monthNumber: (month['number'] as num?)?.toInt() ?? 1,
      year: json['year']?.toString() ?? '',
    );
  }
}
