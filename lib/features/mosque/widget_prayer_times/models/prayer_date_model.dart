class PrayerDateModel {
  final String date;
  final String day;
  final String weekdayEn;
  final String monthEn;
  final int monthNumber;
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
