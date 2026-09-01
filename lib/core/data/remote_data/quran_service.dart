import 'package:dio/dio.dart';

import '../../models/quran_response_model.dart';

class QuranService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.alquran.cloud/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
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