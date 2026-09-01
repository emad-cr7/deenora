class AyahModel {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int page;
  final bool sajda;

  AyahModel({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.page,
    required this.sajda,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'page': page,
      'sajda': sajda,
    };
  }

  factory AyahModel.fromJson(Map<String, dynamic> map) {
    return AyahModel(
      number: map['number'] as int,
      text: map['text'] as String,
      numberInSurah: map['numberInSurah'] as int,
      juz: map['juz'] as int,
      page: map['page'] as int,
      sajda: map['sajda'] == true,
    );
  }
}
