import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';

/// Represents a Muadhin (Muezzin / Sheikh) with Adhan and Iqama information.
class MuadhinModel {
  final String id;
  final String nameAr;
  final String categoryAr;
  final String locationAr;
  final bool isMosque;
  final String imageUrl;
  final MuadhinAudioModel adhan;
  final MuadhinAudioModel iqama;

  const MuadhinModel({
    required this.id,
    required this.nameAr,
    required this.categoryAr,
    required this.locationAr,
    required this.isMosque,
    required this.imageUrl,
    required this.adhan,
    required this.iqama,
  });

  /// Whether Adhan audio is available and playable for this Muadhin.
  bool get hasAdhanAudio => hasAudioFor(MuadhinType.adhan);

  /// Whether Iqama audio is available and playable for this Muadhin.
  bool get hasIqamaAudio => hasAudioFor(MuadhinType.iqama);

  /// Returns the corresponding [MuadhinAudioModel] based on [MuadhinType].
  MuadhinAudioModel getAudio(MuadhinType type) {
    return type == MuadhinType.adhan ? adhan : iqama;
  }

  /// Checks if audio is available and playable for the specified [MuadhinType].
  bool hasAudioFor(MuadhinType type) {
    final audio = getAudio(type);
    return audio.isAvailable && audio.effectiveAudioUrl != null;
  }

  factory MuadhinModel.fromJson(Map<String, dynamic> json) {
    // Concise null-safe parsing with safe Arabic fallback
    String nameAr = '';
    if (json['name'] is Map) {
      nameAr = (json['name'] as Map<String, dynamic>)['ar'] as String? ?? '';
    }
    if (nameAr.isEmpty) {
      nameAr = json['arabicName'] as String? ??
          json['nameArabic'] as String? ??
          '';
    }

    String locationAr = '';
    if (json['location'] is Map) {
      locationAr =
          (json['location'] as Map<String, dynamic>)['ar'] as String? ?? '';
    }
    if (locationAr.isEmpty) {
      locationAr = json['locationAr'] as String? ?? '';
    }

    return MuadhinModel(
      id: json['id'] as String? ?? json['sheikhId'] as String? ?? '',
      nameAr: nameAr,
      categoryAr:
          json['categoryAr'] as String? ?? json['category'] as String? ?? '',
      locationAr: locationAr,
      isMosque: json['isMosque'] as bool? ?? false,
      imageUrl: json['image'] as String? ?? '',
      adhan: json['adhan'] != null
          ? MuadhinAudioModel.fromJson(json['adhan'] as Map<String, dynamic>)
          : const MuadhinAudioModel(
              isAvailable: false,
              apiUrl: '',
            ),
      iqama: json['iqama'] != null
          ? MuadhinAudioModel.fromJson(json['iqama'] as Map<String, dynamic>)
          : const MuadhinAudioModel(
              isAvailable: false,
              apiUrl: '',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'categoryAr': categoryAr,
      'locationAr': locationAr,
      'isMosque': isMosque,
      'image': imageUrl,
      'adhan': adhan.toJson(),
      'iqama': iqama.toJson(),
    };
  }
}
