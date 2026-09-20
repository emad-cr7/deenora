import 'package:dio/dio.dart';

import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/dio/dio_config.dart';
import '../models/verse_of_the_day_model.dart';

class VerseOfTheDayService {
  final Dio _dio = DioConfig.create('https://api.qurani.ai/gw/qh/v1/');
  final HiveManager _hiveManager = HiveManager();

  String get todayKey {
    return DateTime.now().toString().split(' ').first;
  }

  Future<VerseOfTheDayModel> getVerseOfTheDay({
    bool forceRefresh = false,
  }) async {
    final today = todayKey;

    if (!forceRefresh) {
      final saved = await _hiveManager.loadVerseOfTheDay();
      if (saved != null && saved['savedDate'] == today) {
        return VerseOfTheDayModel.fromStoredMap(saved);
      }
    }

    try {
      final response = await _dio.get('ayah/random/quran-uthmani');

      final verse = VerseOfTheDayModel.fromJson(
        response.data as Map<String, dynamic>,
        savedDate: today,
      );

      await _hiveManager.saveVerseOfTheDay(verse.toStoredMap());

      return verse;
    } on DioException catch (e) {
      final saved = await _hiveManager.loadVerseOfTheDay();
      if (saved != null && saved['savedDate'] == today) {
        return VerseOfTheDayModel.fromStoredMap(saved);
      }

      throw Exception('تعذّر تحميل آية اليوم: ${e.message}');
    }
  }
}
