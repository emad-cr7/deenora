import 'surah_model.dart';

class QuranResponseModel {
  final int code;
  final String status;
  final List<SurahModel> surahs;

  QuranResponseModel({
    required this.code,
    required this.status,
    required this.surahs,
  });

  factory QuranResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return QuranResponseModel(
      code: json['code'],
      status: json['status'],
      surahs: (data['surahs'] as List).map((s) => SurahModel.fromJson(s)).toList(),
    );
  }
}
