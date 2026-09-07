import 'package:hive_ce/hive.dart';

part 'azkar_model.g.dart';

@HiveType(typeId: 3)
class AzkarModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int count;

  AzkarModel({
    required this.id,
    required this.text,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'count': count,
    };
  }

  factory AzkarModel.fromJson(Map<String, dynamic> map) {
    final count = int.tryParse(map['count']?.toString() ?? '') ?? 1;

    return AzkarModel(
      id: map['id'] as int,
      text: map['text'] as String,
      count: count == 0 ? 1 : count,
    );
  }
}