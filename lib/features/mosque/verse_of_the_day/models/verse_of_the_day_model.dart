class VerseOfTheDayModel {
  final String text;
  final int surahNumber;
  final String surahEnglishName;
  final int numberInSurah;
  final String savedDate;

  const VerseOfTheDayModel({
    required this.text,
    required this.surahNumber,
    required this.surahEnglishName,
    required this.numberInSurah,
    required this.savedDate,
  });

  factory VerseOfTheDayModel.fromJson(
    Map<String, dynamic> json, {
    required String savedDate,
  }) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final surah = data['surah'] as Map<String, dynamic>? ?? {};

    return VerseOfTheDayModel(
      text: (data['text'] as String? ?? '').trim(),
      surahNumber: surah['number'] as int? ?? 0,
      surahEnglishName: surah['englishName'] as String? ?? '',
      numberInSurah: data['numberInSurah'] as int? ?? 0,
      savedDate: savedDate,
    );
  }

  factory VerseOfTheDayModel.fromStoredMap(Map<String, dynamic> map) {
    return VerseOfTheDayModel(
      text: map['text'] as String? ?? '',
      surahNumber: map['surahNumber'] as int? ?? 0,
      surahEnglishName: map['surahEnglishName'] as String? ?? '',
      numberInSurah: map['numberInSurah'] as int? ?? 0,
      savedDate: map['savedDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toStoredMap() => {
    'text': text,
    'surahNumber': surahNumber,
    'surahEnglishName': surahEnglishName,
    'numberInSurah': numberInSurah,
    'savedDate': savedDate,
  };
}
