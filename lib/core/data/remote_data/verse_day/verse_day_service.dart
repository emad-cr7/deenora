import 'package:dio/dio.dart';

import '../../../../core/data/remote_data/dio/dio_config.dart';
import '../../../../features/mosque/verse_of_the_day/models/verse_day_model.dart';

class VerseDayService {
  final Dio _dio = DioConfig.create('https://api.qurani.ai/gw/qh/v1/');

  Future<VerseDayModel> getVerseOfTheDay({
    required String savedDate,
  }) async {
    try {
      final response = await _dio.get('ayah/random/quran-uthmani');
      return VerseDayModel.fromJson(
        response.data as Map<String, dynamic>,
        savedDate: savedDate,
      );
    } on DioException catch (e) {
      throw Exception('تعذّر تحميل آية اليوم: ${e.message}');
    }
  }
}
