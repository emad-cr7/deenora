import 'package:hive_ce_flutter/hive_flutter.dart';

part 'name_surah_model.g.dart';

@HiveType(typeId: 2)
class NameSurahModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String revelationPlace;

  @HiveField(2)
  final int revelationOrder;

  @HiveField(3)
  final String nameSimple;

  @HiveField(4)
  final String nameComplex;

  @HiveField(5)
  final String nameArabic;

  @HiveField(6)
  final int versesCount;

  NameSurahModel({
    required this.id,
    required this.revelationPlace,
    required this.revelationOrder,
    required this.nameSimple,
    required this.nameComplex,
    required this.nameArabic,
    required this.versesCount,
  });

  factory NameSurahModel.fromJson(Map<String, dynamic> json) {
    return NameSurahModel(
      id: json['id'] as int,
      revelationPlace: json['revelation_place'] as String,
      revelationOrder: json['revelation_order'] as int,
      nameSimple: json['name_simple'] as String,
      nameComplex: json['name_complex'] as String,
      nameArabic: json['name_arabic'] as String,
      versesCount: json['verses_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'revelation_place': revelationPlace,
      'revelation_order': revelationOrder,
      'name_simple': nameSimple,
      'name_complex': nameComplex,
      'name_arabic': nameArabic,
      'verses_count': versesCount,
    };
  }
}