class VerseOfTheDayModel {
  final int number;
  final String text;
  final int surahNumber;
  final String surahName;
  final String surahEnglishName;
  final int numberInSurah;

  /// The calendar date (yyyy-MM-dd) on which this verse was fetched.
  final String savedDate;

  const VerseOfTheDayModel({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.numberInSurah,
    required this.savedDate,
  });

  String get displaySurahName {
    final cleaned = surahName
        .replaceAll('سُورَةُ', '')
        .replaceAll('سورة', '')
        .trim();
    return 'سورة $cleaned';
  }

  /// Creates a [VerseOfTheDayModel] from the API JSON response.
  /// The response shape is:
  ///   { "code": 200, "data": { "number": …, "text": …, "surah": { … }, … } }
  factory VerseOfTheDayModel.fromJson(
    Map<String, dynamic> json, {
    required String savedDate,
  }) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final surah = data['surah'] as Map<String, dynamic>? ?? {};

    return VerseOfTheDayModel(
      number: data['number'] as int? ?? 0,
      text: (data['text'] as String? ?? '').trim(),
      surahNumber: surah['number'] as int? ?? 0,
      surahName: surah['name'] as String? ?? '',
      surahEnglishName: surah['englishName'] as String? ?? '',
      numberInSurah: data['numberInSurah'] as int? ?? 0,
      savedDate: savedDate,
    );
  }

  /// Creates a [VerseOfTheDayModel] from the flat map stored in Hive.
  factory VerseOfTheDayModel.fromStoredMap(Map<String, dynamic> map) {
    return VerseOfTheDayModel(
      number: map['number'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      surahNumber: map['surahNumber'] as int? ?? 0,
      surahName: map['surahName'] as String? ?? '',
      surahEnglishName: map['surahEnglishName'] as String? ?? '',
      numberInSurah: map['numberInSurah'] as int? ?? 0,
      savedDate: map['savedDate'] as String? ?? '',
    );
  }

  /// Converts this model to a flat map for Hive storage.
  Map<String, dynamic> toStoredMap() => {
    'number': number,
    'text': text,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'surahEnglishName': surahEnglishName,
    'numberInSurah': numberInSurah,
    'savedDate': savedDate,
  };
}
