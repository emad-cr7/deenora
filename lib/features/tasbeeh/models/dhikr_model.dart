class DhikrModel {
  final String id;
  final String name;
  final String arabic;
  final int? narratedCount;

  const DhikrModel({
    required this.id,
    required this.name,
    required this.arabic,
    this.narratedCount,
  });

  factory DhikrModel.fromJson(Map<String, dynamic> json) {
    return DhikrModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      narratedCount: json['narratedCount'] != null
          ? int.tryParse(json['narratedCount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'narratedCount': narratedCount,
    };
  }
}
