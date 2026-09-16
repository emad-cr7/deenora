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

class TasbihDatasetModel {
  final String name;
  final String description;
  final String version;
  final String updated;
  final String license;
  final String licenseUrl;
  final String attribution;
  final String homepage;
  final List<String> editorialRules;
  final int count;
  final List<DhikrModel> dhikrList;

  const TasbihDatasetModel({
    required this.name,
    required this.description,
    required this.version,
    required this.updated,
    required this.license,
    required this.licenseUrl,
    required this.attribution,
    required this.homepage,
    required this.editorialRules,
    required this.count,
    required this.dhikrList,
  });

  factory TasbihDatasetModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['dhikr'] as List<dynamic>? ?? [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => DhikrModel.fromJson(e))
        .toList();

    final rawRules = json['editorialRules'] as List<dynamic>? ?? [];
    final rules = rawRules.map((e) => e.toString()).toList();

    return TasbihDatasetModel(
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      version: (json['version'] ?? '').toString(),
      updated: (json['updated'] ?? '').toString(),
      license: (json['license'] ?? 'CC BY 4.0').toString(),
      licenseUrl: (json['licenseUrl'] ?? '').toString(),
      attribution: (json['attribution'] ?? 'Tasbih.info (https://tasbih.info)')
          .toString(),
      homepage: (json['homepage'] ?? '').toString(),
      editorialRules: rules,
      count: int.tryParse(json['count']?.toString() ?? '') ?? items.length,
      dhikrList: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'version': version,
      'updated': updated,
      'license': license,
      'licenseUrl': licenseUrl,
      'attribution': attribution,
      'homepage': homepage,
      'editorialRules': editorialRules,
      'count': count,
      'dhikr': dhikrList.map((e) => e.toJson()).toList(),
    };
  }
}
