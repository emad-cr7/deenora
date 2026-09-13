class PrayerMetaModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final String methodName;

  PrayerMetaModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.methodName,
  });

  factory PrayerMetaModel.fromJson(Map<String, dynamic> json) {
    final method = (json['method'] as Map<String, dynamic>?) ?? {};
    return PrayerMetaModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? '',
      methodName: (method['name'] as String?) ?? '',
    );
  }
}
