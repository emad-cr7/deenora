/// Represents the audio track details for either Adhan or Iqama.
class MuadhinAudioModel {
  final String type;
  final bool isAvailable;
  final String? audioUrl;
  final String? relativeUrl;
  final String? reciter;
  final String? reciterAr;
  final String? description;
  final String? source;
  final String? license;
  final String? message;
  final String? messageAr;
  final String apiUrl;

  const MuadhinAudioModel({
    required this.type,
    required this.isAvailable,
    this.audioUrl,
    this.relativeUrl,
    this.reciter,
    this.reciterAr,
    this.description,
    this.source,
    this.license,
    this.message,
    this.messageAr,
    required this.apiUrl,
  });

  /// The effective playable URL (direct mp3 URL if present, otherwise the redirecting apiUrl).
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
      type: json['type'] as String? ?? '',
      isAvailable: json['available'] as bool? ?? false,
      audioUrl: json['audioUrl'] as String?,
      relativeUrl: json['relativeUrl'] as String?,
      reciter: json['reciter'] as String?,
      reciterAr: json['reciterAr'] as String?,
      description: json['description'] as String?,
      source: json['source'] as String?,
      license: json['license'] as String?,
      message: json['message'] as String?,
      messageAr: json['messageAr'] as String?,
      apiUrl: json['apiUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'available': isAvailable,
      'audioUrl': audioUrl,
      'relativeUrl': relativeUrl,
      'reciter': reciter,
      'reciterAr': reciterAr,
      'description': description,
      'source': source,
      'license': license,
      'message': message,
      'messageAr': messageAr,
      'apiUrl': apiUrl,
    };
  }
}
