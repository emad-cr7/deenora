import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/search/audio_search_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/search/utils/search_text_normalizer.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSurahs = [
    SurahModel(
      number: 1,
      name: 'سُورَةُ ٱلْفَاتِحَةِ',
      englishName: 'Al-Faatiha',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: [],
    ),
    SurahModel(
      number: 2,
      name: 'سُورَةُ البَقَرَةِ',
      englishName: 'Al-Baqarah',
      englishNameTranslation: 'The Cow',
      revelationType: 'Medinan',
      ayahs: [],
    ),
    SurahModel(
      number: 36,
      name: 'سُورَةُ يٰسٓ',
      englishName: 'Yaseen',
      englishNameTranslation: 'Yasin',
      revelationType: 'Meccan',
      ayahs: [],
    ),
  ];

  const testReciters = [
    ReciterModel(
      id: 51,
      name: 'Abdul Basit Abdus Samad',
      arabicName: 'عبد الباسط عبد الصمد',
      imagePath: 'assets/images/Abdul Basit Abdus Samad.png',
      country: 'Egypt',
      birthDate: '1927',
      description: 'Reciter',
    ),
    ReciterModel(
      id: 92,
      name: 'Yasser Al Dosari',
      arabicName: 'ياسر الدوسري',
      imagePath: 'assets/images/Yasser Al-Dosari.png',
      country: 'Saudi Arabia',
      birthDate: '1980',
      description: 'Reciter',
    ),
    ReciterModel(
      id: 123,
      name: 'Mishary Rashid Al Afasy',
      arabicName: 'مشاري راشد العفاسي',
      imagePath: 'assets/images/Mishary Rashid Al-Afasy.png',
      country: 'Kuwait',
      birthDate: '1976',
      description: 'Reciter',
    ),
  ];

  group('SearchTextNormalizer Tests', () {
    test('Arabic diacritics stripping', () {
      final normalized = SearchTextNormalizer.normalizeArabic('سُورَةُ البَقَرَةِ');
      expect(normalized, equals('سوره البقره'));
    });

    test('English search matches "baq" -> Al-Baqarah', () {
      final matches = SearchTextNormalizer.matchesSurah(testSurahs[1], 'baq');
      expect(matches, isTrue);
    });

    test('Arabic search matches "البقرة" -> Al-Baqarah with diacritics', () {
      final matches = SearchTextNormalizer.matchesSurah(testSurahs[1], 'البقرة');
      expect(matches, isTrue);
    });

    test('Arabic search matches "بقرة" without Al prefix -> Al-Baqarah', () {
      final matches = SearchTextNormalizer.matchesSurah(testSurahs[1], 'بقرة');
      expect(matches, isTrue);
    });

    test('Surah number search matches "2" and "002"', () {
      expect(SearchTextNormalizer.matchesSurah(testSurahs[1], '2'), isTrue);
      expect(SearchTextNormalizer.matchesSurah(testSurahs[1], '002'), isTrue);
    });

    test('Reciter English search matches "Abdul" -> Abdul Basit', () {
      final matches = SearchTextNormalizer.matchesReciter(testReciters[0], 'Abdul');
      expect(matches, isTrue);
    });

    test('Reciter Arabic search matches "ياسر" -> Yasser Al Dosari', () {
      final matches = SearchTextNormalizer.matchesReciter(testReciters[1], 'ياسر');
      expect(matches, isTrue);
    });
  });

  group('AudioSearchController Tests', () {
    test('Filter Surahs and Reciters by English query', () async {
      final controller = AudioSearchController(
        initialSurahs: testSurahs,
        initialReciters: testReciters,
      );

      controller.onSearchQueryChanged('baq');
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 300));

      expect(controller.filteredSurahs.length, equals(1));
      expect(controller.filteredSurahs.first.englishName, equals('Al-Baqarah'));
      expect(controller.filteredReciters.isEmpty, isTrue);
      controller.dispose();
    });

    test('Filter by Arabic query "ياسر"', () async {
      final controller = AudioSearchController(
        initialSurahs: testSurahs,
        initialReciters: testReciters,
      );

      controller.onSearchQueryChanged('ياسر');
      await Future.delayed(const Duration(milliseconds: 300));

      expect(controller.filteredReciters.length, equals(1));
      expect(controller.filteredReciters.first.name, equals('Yasser Al Dosari'));
      expect(controller.filteredSurahs.isEmpty, isTrue);
      controller.dispose();
    });

    test('Clear search resets state immediately', () async {
      final controller = AudioSearchController(
        initialSurahs: testSurahs,
        initialReciters: testReciters,
      );

      controller.onSearchQueryChanged('baq');
      await Future.delayed(const Duration(milliseconds: 300));
      expect(controller.filteredSurahs.length, equals(1));

      controller.clearSearch();
      expect(controller.searchQuery, isEmpty);
      expect(controller.filteredSurahs.isEmpty, isTrue);
      expect(controller.filteredReciters.isEmpty, isTrue);
      expect(controller.isInitial, isTrue);
      controller.dispose();
    });
  });
}
