import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';

/// Represents a Muadhin (Muezzin / Sheikh) with Adhan and Iqama information.
class MuadhinModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String category;
  final String categoryAr;
  final bool isMosque;
  final String locationEn;
  final String locationAr;
  final String region;
  final String imageUrl;
  final MuadhinAudioModel adhan;
  final MuadhinAudioModel iqama;

  const MuadhinModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.categoryAr,
    required this.isMosque,
    required this.locationEn,
    required this.locationAr,
    required this.region,
    required this.imageUrl,
    required this.adhan,
    required this.iqama,
  });

  /// Whether Adhan audio is available and playable for this Muadhin.
  bool get hasAdhanAudio =>
      adhan.isAvailable && adhan.effectiveAudioUrl != null;

  /// Whether Iqama audio is available and playable for this Muadhin.
  bool get hasIqamaAudio =>
      iqama.isAvailable && iqama.effectiveAudioUrl != null;

  /// Returns the corresponding [MuadhinAudioModel] based on [MuadhinType].
  MuadhinAudioModel getAudio(MuadhinType type) {
    return type == MuadhinType.adhan ? adhan : iqama;
  }

  /// Checks if audio is available and playable for the specified [MuadhinType].
  bool hasAudioFor(MuadhinType type) {
    return type == MuadhinType.adhan ? hasAdhanAudio : hasIqamaAudio;
  }

  factory MuadhinModel.fromJson(Map<String, dynamic> json) {
    // Parse bilingual name
    String nameEn = '';
    String nameAr = '';
    if (json['name'] is Map) {
      final nameMap = json['name'] as Map<String, dynamic>;
      nameEn = nameMap['en'] as String? ?? '';
      nameAr = nameMap['ar'] as String? ?? '';
    }
    if (nameEn.isEmpty) {
      nameEn = json['nameString'] as String? ?? '';
    }
    if (nameAr.isEmpty) {
      nameAr = json['arabicName'] as String? ??
          json['nameArabic'] as String? ??
          nameEn;
    }

    // Parse bilingual location
    String locationEn = '';
    String locationAr = '';
    if (json['location'] is Map) {
      final locMap = json['location'] as Map<String, dynamic>;
      locationEn = locMap['en'] as String? ?? '';
      locationAr = locMap['ar'] as String? ?? '';
    }
    if (locationEn.isEmpty) {
      locationEn = json['locationEn'] as String? ??
          json['locationString'] as String? ??
          '';
    }
    if (locationAr.isEmpty) {
      locationAr = json['locationAr'] as String? ?? locationEn;
    }

    return MuadhinModel(
      id: json['id'] as String? ?? json['sheikhId'] as String? ?? '',
      nameEn: nameEn,
      nameAr: nameAr,
      category: json['category'] as String? ?? '',
      categoryAr:
          json['categoryAr'] as String? ?? json['category'] as String? ?? '',
      isMosque: json['isMosque'] as bool? ?? false,
      locationEn: locationEn,
      locationAr: locationAr,
      region: json['region'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      adhan: json['adhan'] != null
          ? MuadhinAudioModel.fromJson(json['adhan'] as Map<String, dynamic>)
          : const MuadhinAudioModel(
              type: 'adhan',
              isAvailable: false,
              apiUrl: '',
            ),
      iqama: json['iqama'] != null
          ? MuadhinAudioModel.fromJson(json['iqama'] as Map<String, dynamic>)
          : const MuadhinAudioModel(
              type: 'iqama',
              isAvailable: false,
              apiUrl: '',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {'en': nameEn, 'ar': nameAr},
      'category': category,
      'categoryAr': categoryAr,
      'isMosque': isMosque,
      'location': {'en': locationEn, 'ar': locationAr},
      'region': region,
      'image': imageUrl,
      'adhan': adhan.toJson(),
      'iqama': iqama.toJson(),
    };
  }
}
