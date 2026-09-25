import 'package:dio/dio.dart';

import '../../../../features/mosque/hadith_of_the_day/models/hadith_day_model.dart';
import '../dio/dio_config.dart';

class HadithDayService {
  final Dio _dio;

  HadithDayService({Dio? dio})
    : _dio = dio ?? DioConfig.create('https://api.islamic.app/v1/');

  Future<HadithDayModel> getHadithOfTheDay({required String savedDate}) async {
    try {
      final response = await _dio.get('hadith/today');
      return HadithDayModel.fromJson(
        response.data as Map<String, dynamic>,
        savedDate: savedDate,
      );
    } on DioException catch (e) {
      throw Exception('تعذّر تحميل حديث اليوم: ${e.message}');
    } catch (e) {
      throw Exception('خطأ غير متوقع عند تحميل حديث اليوم: $e');
    }
  }
}
