import 'package:dio/dio.dart';

import '../../../../core/data/remote_data/dio/dio_config.dart';
import '../models/verse_of_the_day_model.dart';

class VerseOfTheDayService {
  final Dio _dio = DioConfig.create('https://api.qurani.ai/gw/qh/v1/');

  Future<VerseOfTheDayModel> getVerseOfTheDay({
    required String savedDate,
  }) async {
    try {
      final response = await _dio.get('ayah/random/quran-uthmani');
      return VerseOfTheDayModel.fromJson(
        response.data as Map<String, dynamic>,
        savedDate: savedDate,
      );
    } on DioException catch (e) {
      throw Exception('تعذّر تحميل آية اليوم: ${e.message}');
    }
  }
}
