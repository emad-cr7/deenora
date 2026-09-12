import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/surah_navigation_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/models/sleep_timer_option.dart';
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

  group('SurahNavigationController Tests', () {
    test('Boundary conditions for first Surah (Surah 1)', () {
      final nav = SurahNavigationController(
        initialSurah: dummySurahs[0],
        surahList: dummySurahs,
      );

      expect(nav.hasPrevious, isFalse);
      expect(nav.hasNext, isTrue);
      expect(nav.previousSurah, isNull);
      expect(nav.nextSurah?.englishName, 'Al-Baqarah');
      expect(nav.currentSurahIndex, 0);

      nav.dispose();
    });

    test('Middle Surah has both Previous and Next', () {
      final nav = SurahNavigationController(
        initialSurah: dummySurahs[1],
        surahList: dummySurahs,
      );

      expect(nav.hasPrevious, isTrue);
      expect(nav.hasNext, isTrue);
      expect(nav.previousSurah?.englishName, 'Al-Fatiha');
      expect(nav.nextSurah?.englishName, 'Aal-E-Imran');
      expect(nav.currentSurahIndex, 1);

      nav.dispose();
    });

    test('Boundary conditions for last Surah in list', () {
      final nav = SurahNavigationController(
        initialSurah: dummySurahs[2],
        surahList: dummySurahs,
      );

      expect(nav.hasPrevious, isTrue);
      expect(nav.hasNext, isFalse);
      expect(nav.previousSurah?.englishName, 'Al-Baqarah');
      expect(nav.nextSurah, isNull);
      expect(nav.currentSurahIndex, 2);

      nav.dispose();
    });
  });

  group('AudioPlayerCoordinator Tests', () {
    test('Coordinator initializes navigation and sleep timer state correctly', () {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(coordinator.hasPrevious, isFalse);
      expect(coordinator.hasNext, isTrue);
      expect(coordinator.currentSurah.number, 1);
      expect(coordinator.reciter.name, 'Abdul Basit Abdus Samad');
      expect(coordinator.isSleepTimerActive, isFalse);

      coordinator.setSleepTimer(SleepTimerOption.tenMin);
      expect(coordinator.isSleepTimerActive, isTrue);
      expect(coordinator.sleepTimerOption, SleepTimerOption.tenMin);
      expect(coordinator.sleepTimerRemainingSeconds, 600);
      expect(coordinator.sleepTimerFormatted, '10:00');

      coordinator.cancelSleepTimer();
      expect(coordinator.isSleepTimerActive, isFalse);
      expect(coordinator.sleepTimerOption, isNull);

      coordinator.dispose();
    });

    test('Custom sleep timer sets custom duration properly', () {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      coordinator.setSleepTimer(SleepTimerOption.custom, customMinutes: 25);
      expect(coordinator.isSleepTimerActive, isTrue);
      expect(coordinator.sleepTimerOption, SleepTimerOption.custom);
      expect(coordinator.sleepTimerRemainingSeconds, 1500);
      expect(coordinator.sleepTimerFormatted, '25:00');

      coordinator.cancelSleepTimer();
      coordinator.dispose();
    });

    test('End of Surah option sets active status', () {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      coordinator.setSleepTimer(SleepTimerOption.endOfSurah);
      expect(coordinator.isSleepTimerActive, isTrue);
      expect(coordinator.sleepTimerOption, SleepTimerOption.endOfSurah);
      expect(coordinator.sleepTimerFormatted, 'End of Surah');

      coordinator.cancelSleepTimer();
      coordinator.dispose();
    });

    test('Attempting playPreviousSurah on Surah 1 does not trigger loading', () async {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(coordinator.hasPrevious, isFalse);
      expect(coordinator.isLoadingSurah, isFalse);

      await coordinator.playPreviousSurah();

      expect(coordinator.isLoadingSurah, isFalse);
      expect(coordinator.currentSurah.number, 1);

      coordinator.dispose();
    });

    test('Attempting playNextSurah on last Surah does not trigger loading', () async {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[2],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[3]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(coordinator.hasNext, isFalse);
      expect(coordinator.isLoadingSurah, isFalse);

      await coordinator.playNextSurah();

      expect(coordinator.isLoadingSurah, isFalse);
      expect(coordinator.currentSurah.number, 3);

      coordinator.dispose();
    });

    test('Invalid Surah number does not initiate loading state', () async {
      final invalidSurah = SurahModel(
        number: 0,
        name: 'غير معروف',
        englishName: 'Unknown',
        englishNameTranslation: 'Unknown',
        revelationType: 'Meccan',
        ayahs: [],
      );

      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      await coordinator.playSurah(invalidSurah);
      expect(coordinator.isLoadingSurah, isFalse);
      expect(coordinator.currentSurah.number, 1);

      coordinator.dispose();
    });

    test('Coordinator initializes with inactive session when no initial parameters provided', () {
      final coordinator = AudioPlayerCoordinator();

      expect(coordinator.hasActiveSession, isFalse);
      expect(coordinator.currentSurah.number, 1);

      coordinator.dispose();
    });

    test('Coordinator initializes with active session when initial parameters provided and resets on stop', () async {
      final coordinator = AudioPlayerCoordinator(
        initialSurah: dummySurahs[0],
        initialReciter: dummyReciter,
        initialAudioUrl: dummyAudioMap[1]!,
        surahList: dummySurahs,
        audioMap: dummyAudioMap,
      );

      expect(coordinator.hasActiveSession, isTrue);
      expect(coordinator.currentSurah.number, 1);
      expect(coordinator.reciter.id, dummyReciter.id);

      await coordinator.stopAndClearSession();
      expect(coordinator.hasActiveSession, isFalse);

      coordinator.dispose();
    });
  });

  group('Minimal AudioPlayerController Core Tests', () {
    test('AudioPlayerController initializes with clean state', () {
      final playerController = AudioPlayerController();

      expect(playerController.isLoading, isFalse);
      expect(playerController.hasError, isFalse);
      expect(playerController.errorMessage, isNull);
      expect(playerController.currentAudioUrl, isNull);
      expect(playerController.duration, equals(Duration.zero));
      expect(playerController.position, equals(Duration.zero));

      playerController.dispose();
    });
  });
}
