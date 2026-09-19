import 'dhikr_model.dart';

class TasbihDatasetModel {
  final String attribution;
  final List<DhikrModel> dhikrList;

  const TasbihDatasetModel({
    required this.attribution,
    required this.dhikrList,
  });

  factory TasbihDatasetModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['dhikr'] as List<dynamic>? ?? [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => DhikrModel.fromJson(e))
        .toList();

    return TasbihDatasetModel(
      attribution: (json['attribution'] ?? 'Tasbih.info (https://tasbih.info)')
          .toString(),
      dhikrList: items,
    );
  }
}
