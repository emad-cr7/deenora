import 'package:deenora/core/data/remote_data/dio/dio_config.dart';
import 'package:dio/dio.dart';

import 'package:deenora/core/enum/azkar_model/zekr_category.dart';

class AzkaraService {
  final Dio _dio = DioConfig.create('https://quran.yousefheiba.com/api/azkar');

  Future<ZekrCategory> getAzkar() async {
    try {
      final response = await _dio.get('');
      return ZekrCategory.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('فشل تحميل الأذكار: ${e.message}');
    }
  }
}