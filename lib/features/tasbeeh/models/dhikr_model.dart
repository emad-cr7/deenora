class DhikrModel {
  final String id;
  final String name;
  final String arabic;
  final String transliteration;
  final String english;
  final int? narratedCount;
  final String? countNote;
  final String source;
  final String sourceUrl;
  final String? grading;
  final bool isCustom;
  final int? personalTarget;

  const DhikrModel({
    required this.id,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.english,
    this.narratedCount,
    this.countNote,
    required this.source,
    required this.sourceUrl,
    this.grading,
    this.isCustom = false,
    this.personalTarget,
  });

  /// Returns true if a specific count was cited in the hadith.
  bool get hasNarratedCount => narratedCount != null;

  factory DhikrModel.fromJson(Map<String, dynamic> json) {
    return DhikrModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      transliteration: (json['transliteration'] ?? '').toString(),
      english: (json['english'] ?? '').toString(),
      // Handle nullable narratedCount: never convert null to a default number here
      narratedCount: json['narratedCount'] != null
          ? int.tryParse(json['narratedCount'].toString())
          : null,
      // Handle nullable countNote
      countNote: json['countNote']?.toString(),
      source: (json['source'] ?? '').toString(),
      sourceUrl: (json['sourceUrl'] ?? '').toString(),
      // Handle nullable grading
      grading: json['grading']?.toString(),
      isCustom: json['isCustom'] as bool? ?? false,
      personalTarget: json['personalTarget'] != null
          ? int.tryParse(json['personalTarget'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'transliteration': transliteration,
      'english': english,
      'narratedCount': narratedCount,
      'countNote': countNote,
      'source': source,
      'sourceUrl': sourceUrl,
      'grading': grading,
      'isCustom': isCustom,
      'personalTarget': personalTarget,
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
