import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';

class SearchTextNormalizer {
  SearchTextNormalizer._();

  static final RegExp _arabicTashkeelRegex = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED]',
  );

  static final RegExp _tatweelRegex = RegExp(r'\u0640');

  /// Normalizes Arabic text by removing tashkeel, normalizing alef, taa marbuta, etc.
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';

    var result = text.replaceAll(_arabicTashkeelRegex, '');
    result = result.replaceAll(_tatweelRegex, '');

    // Normalize Alef variations
    result = result.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Taa Marbuta to Haa
    result = result.replaceAll('ة', 'ه');

    // Normalize Alef Maksura to Yaa
    result = result.replaceAll('ى', 'ي');

    // Clean whitespace
    result = result.trim().replaceAll(RegExp(r'\s+'), ' ');

    return result;
  }

  /// Removes common "سورة " or "سوره " prefix from Arabic Surah names
  static String removeSurahPrefix(String text) {
    final normalized = normalizeArabic(text);
    if (normalized.startsWith('سوره ')) {
      return normalized.substring(5).trim();
    }
    if (normalized.startsWith('سورة ')) {
      return normalized.substring(5).trim();
    }
    return normalized;
  }

  /// Normalizes English strings (lowercased, hyphens and extra characters removed)
  static String normalizeEnglish(String text) {
    if (text.isEmpty) return '';
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"['\-\.,_]"), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Checks if [source] matches [query] in Arabic
  static bool matchesArabic(String source, String query) {
    final normQuery = normalizeArabic(query);
    if (normQuery.isEmpty) return false;

    final normSource = normalizeArabic(source);
    if (normSource.contains(normQuery)) return true;

    final queryNoPrefix = removeSurahPrefix(normQuery);
    final sourceNoPrefix = removeSurahPrefix(normSource);

    if (sourceNoPrefix.contains(queryNoPrefix)) return true;

    // Check without "ال" definition article if query doesn't start with it
    final sourceWithoutAl = sourceNoPrefix.startsWith('ال')
        ? sourceNoPrefix.substring(2)
        : sourceNoPrefix;
    final queryWithoutAl = queryNoPrefix.startsWith('ال')
        ? queryNoPrefix.substring(2)
        : queryNoPrefix;

    if (sourceWithoutAl.contains(queryWithoutAl)) return true;

    return false;
  }

  /// Checks if [source] matches [query] in English
  static bool matchesEnglish(String source, String query) {
    final normQuery = normalizeEnglish(query);
    if (normQuery.isEmpty) return false;

    final normSource = normalizeEnglish(source);
    if (normSource.contains(normQuery)) return true;

    // Remove spaces for compressed comparisons (e.g. "albaqarah" vs "al baqarah")
    final compactSource = normSource.replaceAll(' ', '');
    final compactQuery = normQuery.replaceAll(' ', '');
    if (compactSource.contains(compactQuery)) return true;

    return false;
  }

  /// Evaluates whether a [SurahModel] matches the user query
  static bool matchesSurah(SurahModel surah, String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return false;

    // Check Surah number
    if (surah.number.toString() == query ||
        surah.number.toString().padLeft(3, '0') == query) {
      return true;
    }

    // Check English names
    if (matchesEnglish(surah.englishName, query)) return true;
    if (matchesEnglish(surah.englishNameTranslation, query)) return true;

    // Check Arabic name
    if (matchesArabic(surah.name, query)) return true;

    return false;
  }

  /// Evaluates whether a [ReciterModel] matches the user query
  static bool matchesReciter(ReciterModel reciter, String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return false;

    // Check English name
    if (matchesEnglish(reciter.name, query)) return true;

    // Check Arabic name if available
    if (reciter.arabicName != null &&
        matchesArabic(reciter.arabicName!, query)) {
      return true;
    }

    // Check country
    if (matchesEnglish(reciter.country, query)) return true;

    return false;
  }
}
