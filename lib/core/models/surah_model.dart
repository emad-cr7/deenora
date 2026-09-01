import 'package:hive_ce_flutter/hive_flutter.dart';

import 'ayah_model.dart';

part 'surah_model.g.dart';

@HiveType(typeId: 1)
class SurahModel {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String englishName;

  @HiveField(3)
  final String englishNameTranslation;

  @HiveField(4)
  final String revelationType;

  @HiveField(5)
  final List<AyahModel> ayahs;

  SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      revelationType: json['revelationType'],
      ayahs: (json['ayahs'] as List).map((ayah) => AyahModel.fromJson(ayah)).toList(),
    );
  }
}