import 'package:hive_ce_flutter/hive_flutter.dart';

part 'dhikr_model.g.dart';

@HiveType(typeId: 2)
class DhikrModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String arabic;

  @HiveField(3)
  final int? narratedCount;

  @HiveField(4)
  final int? customGoal;

  const DhikrModel({
    required this.id,
    required this.name,
    required this.arabic,
    this.narratedCount,
    this.customGoal,
  });

  factory DhikrModel.fromJson(Map<String, dynamic> json) {
    return DhikrModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      narratedCount: json['narratedCount'] != null
          ? int.tryParse(json['narratedCount'].toString())
          : null,
      customGoal: json['customGoal'] != null
          ? int.tryParse(json['customGoal'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'narratedCount': narratedCount,
      if (customGoal != null) 'customGoal': customGoal,
    };
  }
}
