import 'package:hive_ce_flutter/hive_flutter.dart';

part 'prayer_meta_model.g.dart';

@HiveType(typeId: 8)
class PrayerMetaModel {
  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;
  @HiveField(2)
  final String timezone;
  @HiveField(3)
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
