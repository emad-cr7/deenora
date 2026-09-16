class HijriDateModel {
  final String date;
  final String day;
  final String weekdayEn;
  final String weekdayAr;
  final String monthEn;
  final String monthAr;
  final int monthNumber;
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
