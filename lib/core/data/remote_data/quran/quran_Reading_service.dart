import 'package:dio/dio.dart';

import '../../../models/quran_response_model.dart';
import '../dio/dio_config.dart';

class QuranReadingService {
  final Dio _dio = DioConfig.create(
    'https://api.alquran.cloud/v1/',
  );
  Future<QuranResponseModel> getFullQuran() async {
    try {
      final response = await _dio.get('quran/quran-uthmani');
      return QuranResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('حصل خطأ وإحنا بنجيب القرآن: ${e.message}');
    }
  }
}