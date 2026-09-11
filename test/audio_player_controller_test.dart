import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/audio_player_controller.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummySurahs = [
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
      number: 3,
      name: 'سورة آل عمران',
      englishName: 'Aal-E-Imran',
      englishNameTranslation: 'The Family of Imran',
      revelationType: 'Medinan',
      ayahs: [],
    ),
  ];

  const dummyReciter = ReciterModel(
    id: 51,
    name: 'Abdul Basit Abdus Samad',
    imagePath: 'assets/images/Abdul Basit Abdus Samad.png',
    country: 'Egypt',
    birthDate: '1927',
    description: 'Reciter',
  );

  final dummyAudioMap = {
    1: 'https://server.test/001.mp3',
    2: 'https://server.test/002.mp3',
    3: 'https://server.test/003.mp3',
  };

  group('AudioPlayerController Navigation Tests', () {
    test('Boundary conditions for first Surah (Surah 1)', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.hasPrevious, isFalse);
      expect(controller.hasNext, isTrue);
      expect(controller.previousSurah, isNull);
      expect(controller.nextSurah?.englishName, 'Al-Baqarah');
      expect(controller.currentSurahIndex, 0);

      controller.dispose();
    });

    test('Middle Surah has both Previous and Next', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[1],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[2]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.hasPrevious, isTrue);
      expect(controller.hasNext, isTrue);
      expect(controller.previousSurah?.englishName, 'Al-Fatiha');
      expect(controller.nextSurah?.englishName, 'Aal-E-Imran');
      expect(controller.currentSurahIndex, 1);

      controller.dispose();
    });

    test('Boundary conditions for last Surah in list', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[2],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[3]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.hasPrevious, isTrue);
      expect(controller.hasNext, isFalse);
      expect(controller.previousSurah?.englishName, 'Al-Baqarah');
      expect(controller.nextSurah, isNull);
      expect(controller.currentSurahIndex, 2);

      controller.dispose();
    });
  });

  group('AudioPlayerController Sleep Timer Tests', () {
    test('Setting preset sleep timer updates state and formatted remaining time', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.isSleepTimerActive, isFalse);

      controller.setSleepTimer(SleepTimerOption.tenMin);
      expect(controller.isSleepTimerActive, isTrue);
      expect(controller.sleepTimerOption, SleepTimerOption.tenMin);
      expect(controller.sleepTimerRemainingSeconds, 600);
      expect(controller.sleepTimerFormatted, '10:00');

      controller.cancelSleepTimer();
      expect(controller.isSleepTimerActive, isFalse);
      expect(controller.sleepTimerOption, isNull);
      expect(controller.sleepTimerRemainingSeconds, 0);

      controller.dispose();
    });

    test('Custom sleep timer sets custom duration properly', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      controller.setSleepTimer(SleepTimerOption.custom, customMinutes: 25);
      expect(controller.isSleepTimerActive, isTrue);
      expect(controller.sleepTimerOption, SleepTimerOption.custom);
      expect(controller.sleepTimerRemainingSeconds, 1500);
      expect(controller.sleepTimerFormatted, '25:00');

      controller.cancelSleepTimer();
      controller.dispose();
    });

    test('End of Surah option sets active status', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      controller.setSleepTimer(SleepTimerOption.endOfSurah);
      expect(controller.isSleepTimerActive, isTrue);
      expect(controller.sleepTimerOption, SleepTimerOption.endOfSurah);
      expect(controller.sleepTimerFormatted, 'End of Surah');

      controller.cancelSleepTimer();
      controller.dispose();
    });

    // اختبار عدم الدخول في حالة تحميل عند محاولة الانتقال خارج حدود السور
    test('Attempting playPreviousSurah on Surah 1 does not trigger loading', () async {
      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.hasPrevious, isFalse);
      expect(controller.isLoadingSurah, isFalse);

      await controller.playPreviousSurah();

      expect(controller.isLoadingSurah, isFalse);
      expect(controller.currentSurah.number, 1);

      controller.dispose();
    });

    // اختبار عدم الدخول في حالة تحميل عند محاولة الانتقال بعد السورة الأخيرة
    test('Attempting playNextSurah on last Surah does not trigger loading', () async {
      final controller = AudioPlayerController(
        surah: dummySurahs[2],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[3]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.hasNext, isFalse);
      expect(controller.isLoadingSurah, isFalse);

      await controller.playNextSurah();

      expect(controller.isLoadingSurah, isFalse);
      expect(controller.currentSurah.number, 3);

      controller.dispose();
    });
  });

  group('AudioPlayerController Loading & Navigation State Tests', () {
    // اختبار أن حالة التحميل تكون معطلة في البداية وأزرار التنقل نشطة حسب موقع السورة
    test('Initial loading state is false and navigation controls are active', () {
      final controller = AudioPlayerController(
        surah: dummySurahs[1],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[2]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(controller.isLoadingSurah, isFalse);
      expect(controller.hasPrevious && !controller.isLoadingSurah, isTrue);
      expect(controller.hasNext && !controller.isLoadingSurah, isTrue);

      controller.dispose();
    });

    // اختبار عدم بدء التحميل إذا تم تمرير سورة برقم خارج النطاق (أقل من 1)
    test('Invalid Surah number does not initiate loading state', () async {
      final invalidSurah = SurahModel(
        number: 0,
        name: 'غير معروف',
        englishName: 'Unknown',
        englishNameTranslation: 'Unknown',
        revelationType: 'Meccan',
        ayahs: [],
      );

      final controller = AudioPlayerController(
        surah: dummySurahs[0],
        reciter: dummyReciter,
        audioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      await controller.playSurah(invalidSurah);
      expect(controller.isLoadingSurah, isFalse);
      expect(controller.currentSurah.number, 1);

      controller.dispose();
    });
  });
}
