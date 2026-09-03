import 'package:dio/dio.dart';

import '../../../features/Quran/Listening/models_listening/name_surah_model.dart';

class QuranListeningService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.quran.com/api/v4/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<NameSurahModel>> getChapters() async {
    try {
      final response = await _dio.get('chapters');
      final List<dynamic> chaptersJson = response.data['chapters'];
      return chaptersJson
          .map((json) => NameSurahModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('حصل خطأ وإحنا بنجيب أسماء السور: ${e.message}');
    }
  }
}