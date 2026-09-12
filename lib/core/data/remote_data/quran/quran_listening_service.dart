import 'package:dio/dio.dart';
import '../../../../features/Quran/Listening/models_listening/mp3quran_reciter_model.dart';
import '../dio/dio_config.dart';

class QuranListeningService {
  final Dio _dio = DioConfig.create(
    'https://www.mp3quran.net/api/v3/',
  );

  static final Map<int, Map<int, String>> _cache = {};

  Future<Map<int, String>> getReciterAudioFiles(int reciterId) async {
    if (_cache.containsKey(reciterId)) {
      return _cache[reciterId]!;
    }

    try {
      final response = await _dio.get(
        'reciters',
        queryParameters: {
          'language': 'ar',
          'reciter': reciterId,
        },
      );

      final List<dynamic> recitersJson = response.data['reciters'] ?? [];
      if (recitersJson.isEmpty) {
        throw Exception('القارئ غير موجود');
      }

      final reciter = Mp3QuranReciter.fromJson(
        recitersJson.first as Map<String, dynamic>,
      );

      final moshaf = _selectMoshaf(reciter.moshaf);
      final Map<int, String> audioMap = {};
      for (final surahNumber in moshaf.surahNumbers) {
        final url = moshaf.getAudioUrl(surahNumber);
        if (url != null) {
          audioMap[surahNumber] = url;
        }
      }

      _cache[reciterId] = audioMap;
      return audioMap;
    } on DioException catch (e) {
      throw Exception('حصل خطأ وإحنا بنجيب تلاوة الشيخ: ${e.message}');
    }
  }

  Mp3QuranMoshaf _selectMoshaf(List<Mp3QuranMoshaf> moshafs) {
    if (moshafs.isEmpty) {
      throw Exception('لا توجد مصاحف متاحة لهذا القارئ');
    }

    return moshafs.firstWhere(
      (m) => m.name.contains('مرتل') && m.name.contains('حفص'),
      orElse: () => moshafs.reduce(
        (a, b) => a.surahTotal > b.surahTotal ? a : b,
      ),
    );
  }
}
