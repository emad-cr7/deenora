import 'package:hive_ce_flutter/hive_flutter.dart';

part 'hijri_date_model.g.dart';

@HiveType(typeId: 7)
class HijriDateModel {
  @HiveField(0)
  final String date;
  @HiveField(1)
  final String day;
  @HiveField(2)
  final String weekdayEn;
  @HiveField(3)
  final String weekdayAr;
  @HiveField(4)
  final String monthEn;
  @HiveField(5)
  final String monthAr;
  @HiveField(6)
  final int monthNumber;
  @HiveField(7)
  final String year;

  HijriDateModel({
    required this.date,
    required this.day,
    required this.weekdayEn,
    required this.weekdayAr,
    required this.monthEn,
    required this.monthAr,
    required this.monthNumber,
    required this.year,
  });

  String get formattedArabic => '$day $monthAr $year هـ';
  String get formattedEnglish => '$day $monthEn $year AH';

  factory HijriDateModel.fromJson(Map<String, dynamic> json) {
    final weekday = (json['weekday'] as Map<String, dynamic>?) ?? {};
    final month = (json['month'] as Map<String, dynamic>?) ?? {};

    return HijriDateModel(
      date: (json['date'] as String?) ?? '',
      day: json['day']?.toString() ?? '',
      weekdayEn: (weekday['en'] as String?) ?? '',
      weekdayAr: (weekday['ar'] as String?) ?? '',
      monthEn: (month['en'] as String?) ?? '',
      monthAr: (month['ar'] as String?) ?? '',
      monthNumber: (month['number'] as num?)?.toInt() ?? 1,
      year: json['year']?.toString() ?? '',
    );
  }
}
