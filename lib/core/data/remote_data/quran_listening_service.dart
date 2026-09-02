import 'package:dio/dio.dart';

class QuranListeningService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.quran.com/api/v4/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<dynamic> getChapters() async {
    try {
      final response = await _dio.get('chapters?language=ar');
      return response.data;
    } on DioException catch (e) {
      throw Exception('حصل خطأ وإحنا بنجيب أسماء السور: ${e.message}');
    }
  }

}