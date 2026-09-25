import 'package:hive_ce/hive.dart';

part 'hadith_day_model.g.dart';

@HiveType(typeId: 10)
class HadithDayModel {
  @HiveField(0)
  final String textArabic;

  @HiveField(1)
  final String textEnglish;

  @HiveField(2)
  final String collection;

  @HiveField(3)
  final String bookNumber;

  @HiveField(4)
  final String hadithNumber;

  @HiveField(5)
  final String chapterTitleAr;

  @HiveField(6)
  final String chapterTitleEn;

  @HiveField(7)
  final String savedDate;

  HadithDayModel({
    required this.textArabic,
    required this.textEnglish,
    required this.collection,
    required this.bookNumber,
    required this.hadithNumber,
    required this.chapterTitleAr,
    required this.chapterTitleEn,
    required this.savedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'textArabic': textArabic,
      'textEnglish': textEnglish,
      'collection': collection,
      'bookNumber': bookNumber,
      'hadithNumber': hadithNumber,
      'chapterTitleAr': chapterTitleAr,
      'chapterTitleEn': chapterTitleEn,
      'savedDate': savedDate,
    };
  }

  factory HadithDayModel.fromJson(
    Map<String, dynamic> map, {
    String savedDate = '',
  }) {
    if (map.containsKey('data') || map.containsKey('ar')) {
      final data = map['data'] as Map<String, dynamic>? ?? map;
      final ar = data['ar'] as Map<String, dynamic>? ?? {};
      final en = data['en'] as Map<String, dynamic>? ?? {};
      final chapterTitle = data['chapterTitle'] as Map<String, dynamic>? ?? {};

      return HadithDayModel(
        textArabic: (ar['text'] as String? ?? '').trim(),
        textEnglish: (en['text'] as String? ?? '').trim(),
        collection: (data['collection'] as String? ?? '').trim(),
        bookNumber: data['bookNumber']?.toString() ?? '',
        hadithNumber: data['hadithNumber']?.toString() ?? '',
        chapterTitleAr: (chapterTitle['ar'] as String? ?? '').trim(),
        chapterTitleEn: (chapterTitle['en'] as String? ?? '').trim(),
        savedDate: (data['savedDate'] as String?) ?? savedDate,
      );
    }

    return HadithDayModel(
      textArabic: (map['textArabic'] as String? ?? '').trim(),
      textEnglish: (map['textEnglish'] as String? ?? '').trim(),
      collection: (map['collection'] as String? ?? '').trim(),
      bookNumber: map['bookNumber']?.toString() ?? '',
      hadithNumber: map['hadithNumber']?.toString() ?? '',
      chapterTitleAr: (map['chapterTitleAr'] as String? ?? '').trim(),
      chapterTitleEn: (map['chapterTitleEn'] as String? ?? '').trim(),
      savedDate: (map['savedDate'] as String?) ?? savedDate,
    );
  }
}
