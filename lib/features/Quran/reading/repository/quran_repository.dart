import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/quran/quran_Reading_service.dart';
import '../models/surah_model.dart';

/// Central repository for loading and caching Quran Surah data.
class QuranRepository {
  final HiveManager _hiveManager;
  final QuranReadingService _readingService;

  QuranRepository({
    HiveManager? hiveManager,
    QuranReadingService? readingService,
  })  : _hiveManager = hiveManager ?? HiveManager(),
        _readingService = readingService ?? QuranReadingService();

  /// Loads all 114 Surahs from Hive local storage, falling back to the API.
  Future<List<SurahModel>> getSurahs() async {
    final cached = _hiveManager.loadSurahs();
    if (cached.isNotEmpty) {
      return cached;
    }

    final response = await _readingService.getFullQuran();
    await _hiveManager.saveSurahs(response.surahs);
    return response.surahs;
  }

  /// Finds a specific Surah by its 1-based number (1..114).
  Future<SurahModel?> getSurahByNumber(int surahNumber) async {
    final surahs = await getSurahs();
    if (surahs.isEmpty) return null;
    return surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => surahs.first,
    );
  }
}
