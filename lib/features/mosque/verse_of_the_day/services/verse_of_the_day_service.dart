import 'package:dio/dio.dart';
import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/dio/dio_config.dart';
import '../models/verse_of_the_day_model.dart';

class VerseOfTheDayService {
  final Dio _dio;
  final HiveManager _hiveManager;

  static const String baseUrl = 'https://api.alquran.cloud/v1/';
  static const int totalQuranVerses = 6236;

  VerseOfTheDayService({Dio? dio, HiveManager? hiveManager})
    : _dio = dio ?? DioConfig.create(baseUrl),
      _hiveManager = hiveManager ?? HiveManager();

  VerseOfTheDayModel? _cachedVerse;
  String? _cachedDateKey;

  /// Calculates a deterministic ayah index (1..6236) based on the calendar date.
  /// The same calendar date always returns the exact same verse index.
  /// The next calendar date deterministically shifts to a new index across the Quran.
  int getDailyAyahIndex([DateTime? date]) {
    final now = date ?? DateTime.now();
    final dayNumber = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(2024, 1, 1)).inDays;

    // Linear congruential step using coprime multiplier across all 6236 ayahs
    const multiplier = 1013;
    const offset = 2014;
    return ((dayNumber * multiplier + offset) % totalQuranVerses).abs() + 1;
  }

  /// Fetches the Quran verse for the specified day from the API.
  /// Caches the result in memory for the duration of the calendar day.
  /// Falls back to local Quran data in Hive when offline or network fails.
  Future<VerseOfTheDayModel> getVerseOfTheDay({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = '${targetDate.year}-${targetDate.month}-${targetDate.day}';

    if (!forceRefresh && _cachedVerse != null && _cachedDateKey == dateKey) {
      return _cachedVerse!;
    }

    final ayahIndex = getDailyAyahIndex(targetDate);

    try {
      final response = await _dio.get('ayah/$ayahIndex/quran-uthmani');

      if (response.data == null) {
        throw Exception('Received empty response from Quran API');
      }

      final Map<String, dynamic> json = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final verse = VerseOfTheDayModel.fromJson(json);
      _cachedVerse = verse;
      _cachedDateKey = dateKey;

      return verse;
    } on DioException catch (e) {
      final localVerse = _loadVerseFromLocalQuran(ayahIndex);
      if (localVerse != null) {
        _cachedVerse = localVerse;
        _cachedDateKey = dateKey;
        return localVerse;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout while fetching verse of the day');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Network connection error. Please check your internet.',
        );
      } else {
        throw Exception('Failed to load verse of the day: ${e.message}');
      }
    } catch (e) {
      final localVerse = _loadVerseFromLocalQuran(ayahIndex);
      if (localVerse != null) {
        _cachedVerse = localVerse;
        _cachedDateKey = dateKey;
        return localVerse;
      }
      throw Exception('Error loading verse of the day: $e');
    }
  }

  VerseOfTheDayModel? _loadVerseFromLocalQuran(int ayahIndex) {
    try {
      final surahs = _hiveManager.loadSurahs();
      for (final surah in surahs) {
        for (final ayah in surah.ayahs) {
          if (ayah.number == ayahIndex) {
            return VerseOfTheDayModel(
              number: ayah.number,
              text: ayah.text,
              surahNumber: surah.number,
              surahName: surah.name,
              surahEnglishName: surah.englishName,
              numberInSurah: ayah.numberInSurah,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
