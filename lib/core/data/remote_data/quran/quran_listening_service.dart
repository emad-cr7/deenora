
import 'package:dio/dio.dart';
import '../../../../features/Quran/Listening/models_listening/name_surah_model.dart';
import '../../../../features/Quran/Listening/models_listening/chapter_audio_model.dart';
import '../dio/dio_config.dart';

class QuranListeningService {
  final Dio _dio = DioConfig.create(
    'https://api.quran.com/api/v4/',
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

  Future<List<ChapterAudioModel>> getReciterAudioFiles(int reciterId) async {
    try {
      final response = await _dio.get('chapter_recitations/$reciterId');
      final List<dynamic> filesJson = response.data['audio_files'];
      return filesJson.where(
            (json) => json['chapter_id'] != null && json['audio_url'] != null,)
          .map(
            (json) => ChapterAudioModel.fromJson(json as Map<String, dynamic>),
          ).toList();
    } on DioException catch (e) {
      throw Exception('حصل خطأ وإحنا بنجيب تلاوة الشيخ: ${e.message}');
    }
  }
}
