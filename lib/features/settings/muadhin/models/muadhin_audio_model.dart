/// Represents the audio track details for either Adhan or Iqama.
class MuadhinAudioModel {
  final bool isAvailable;
  final String? audioUrl;
  final String apiUrl;
  final String? description;

  const MuadhinAudioModel({
    required this.isAvailable,
    this.audioUrl,
    required this.apiUrl,
    this.description,
  });

  String? get effectiveAudioUrl {
    if (audioUrl != null && audioUrl!.trim().isNotEmpty) {
      return audioUrl;
    }
    if (apiUrl.trim().isNotEmpty) {
      return apiUrl;
    }
    return null;
  }

  factory MuadhinAudioModel.fromJson(Map<String, dynamic> json) {
    return MuadhinAudioModel(
      isAvailable: json['available'] as bool? ?? false,
      audioUrl: json['audioUrl'] as String?,
      apiUrl: json['apiUrl'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': isAvailable,
      'audioUrl': audioUrl,
      'apiUrl': apiUrl,
      'description': description,
    };
  }
}
