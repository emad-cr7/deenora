class VerseOfTheDayModel {
  final int number;
  final String text;
  final int surahNumber;
  final String surahName;
  final String surahEnglishName;
  final int numberInSurah;

  const VerseOfTheDayModel({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.numberInSurah,
  });

  String get displaySurahName {
    final cleaned = surahName
        .replaceAll('سُورَةُ', '')
        .replaceAll('سورة', '')
        .trim();
    return 'سورة $cleaned';
  }

  factory VerseOfTheDayModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final surah = data['surah'] as Map<String, dynamic>? ?? {};

    return VerseOfTheDayModel(
      number: data['number'] as int? ?? 0,
      text: (data['text'] as String? ?? '').trim(),
      surahNumber: surah['number'] as int? ?? 0,
      surahName: surah['name'] as String? ?? '',
      surahEnglishName: surah['englishName'] as String? ?? '',
      numberInSurah: data['numberInSurah'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'text': text,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'surahEnglishName': surahEnglishName,
    'numberInSurah': numberInSurah,
  };
}
