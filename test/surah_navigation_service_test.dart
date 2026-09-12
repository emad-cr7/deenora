import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/services/surah_navigation_service.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';

void main() {
  final sampleSurahs = [
    SurahModel(
      number: 1,
      name: 'سورة الفاتحة',
      englishName: 'Al-Fatiha',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: [],
    ),
    SurahModel(
      number: 2,
      name: 'سورة البقرة',
      englishName: 'Al-Baqarah',
      englishNameTranslation: 'The Cow',
      revelationType: 'Medinan',
      ayahs: [],
    ),
    SurahModel(
      number: 114,
      name: 'سورة الناس',
      englishName: 'An-Naas',
      englishNameTranslation: 'Mankind',
      revelationType: 'Meccan',
      ayahs: [],
    ),
  ];

  group('SurahNavigationService Tests', () {
    // اختبار حدود السورة الأولى
    test('Boundary check for first Surah', () {
      final service = SurahNavigationService(
        initialSurah: sampleSurahs[0],
        surahList: sampleSurahs,
      );

      expect(service.hasPrevious, isFalse);
      expect(service.hasNext, isTrue);
      expect(service.previousSurah, isNull);
      expect(service.nextSurah?.englishName, 'Al-Baqarah');
      expect(service.currentSurahIndex, 0);
    });

    // اختبار التنقل لسورة تالية والسورة الأخيرة
    test('Boundary check for last Surah', () {
      final service = SurahNavigationService(
        initialSurah: sampleSurahs[2],
        surahList: sampleSurahs,
      );

      expect(service.hasPrevious, isTrue);
      expect(service.hasNext, isFalse);
      expect(service.previousSurah?.englishName, 'Al-Baqarah');
      expect(service.nextSurah, isNull);
    });

    // اختبار التحقق من صحة أرقام السور (1 إلى 114)
    test('Validates surah numbers strictly between 1 and 114', () {
      final service = SurahNavigationService(initialSurah: sampleSurahs[0]);

      expect(service.isValidSurahNumber(0), isFalse);
      expect(service.isValidSurahNumber(1), isTrue);
      expect(service.isValidSurahNumber(55), isTrue);
      expect(service.isValidSurahNumber(114), isTrue);
      expect(service.isValidSurahNumber(115), isFalse);
    });

    // اختبار تحديث السورة الحالية
    test('Update current surah changes index and boundary status', () {
      final service = SurahNavigationService(
        initialSurah: sampleSurahs[0],
        surahList: sampleSurahs,
      );

      service.updateCurrentSurah(sampleSurahs[1]);
      expect(service.currentSurah.number, 2);
      expect(service.hasPrevious, isTrue);
      expect(service.hasNext, isTrue);
    });
  });
}
