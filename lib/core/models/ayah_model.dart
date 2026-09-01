import 'package:hive_ce_flutter/hive_flutter.dart';

part 'ayah_model.g.dart';

@HiveType(typeId: 0)
class AyahModel {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int numberInSurah;

  @HiveField(3)
  final int juz;

  @HiveField(4)
  final int page;

  @HiveField(5)
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