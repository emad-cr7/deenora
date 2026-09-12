import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/services/audio_player_service.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/services/quran_audio_handler.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/services/audio_background_handler.dart';

class FakeAudioPlayerService extends AudioPlayerService {
  final _stateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();

  bool _playing = false;
  LoopMode _loopMode = LoopMode.off;
  Duration _pos = Duration.zero;

  @override
  Stream<PlayerState> get playerStateStream => _stateController.stream;
  @override
  Stream<Duration> get positionStream => _positionController.stream;
  @override
  Stream<Duration?> get durationStream => _durationController.stream;
  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;

  @override
  bool get isPlaying => _playing;
  @override
  LoopMode get loopMode => _loopMode;
  @override
  Duration get position => _pos;
  @override
  Duration get duration => const Duration(minutes: 5);

  @override
  Future<void> loadAudioSource({
    required String url,
    String? title,
    String? artist,
    String? album,
  }) async {
    _stateController.add(PlayerState(true, ProcessingState.ready));
  }

  @override
  Future<void> play() async {
    _playing = true;
    _stateController.add(PlayerState(true, ProcessingState.ready));
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _stateController.add(PlayerState(false, ProcessingState.ready));
  }

  @override
  Future<void> stop() async {
    _playing = false;
    _stateController.add(PlayerState(false, ProcessingState.idle));
  }

  @override
  Future<void> seek(Duration targetPosition) async {
    _pos = targetPosition;
    _positionController.add(targetPosition);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _loopMode = mode;
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferedController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '.',
    );
  });

  group('QuranAudioHandler & Notification Controls Tests', () {
    late QuranAudioHandler handler;

    setUp(() {
      handler = QuranAudioHandler();
    });

    test('Handler exposes 5 notification controls and 3 compact indices', () {
      final player = AudioPlayer();
      handler.attachPlayer(player, initialLooping: false);

      final state = handler.playbackState.value;

      expect(state.controls.length, equals(5));
      expect(state.controls[0].action, equals(MediaAction.skipToPrevious));
      expect(state.controls[1].action, equals(MediaAction.play));
      expect(state.controls[2].action, equals(MediaAction.skipToNext));
      expect(state.controls[3].action, equals(MediaAction.custom));
      expect(state.controls[3].customAction?.name, equals('toggleRepeat'));
      expect(state.controls[3].androidIcon, equals('drawable/ic_repeat'));
      expect(state.controls[4].action, equals(MediaAction.stop));

      expect(state.androidCompactActionIndices, equals([0, 1, 2]));

      player.dispose();
    });

    test('Repeat toggle dynamically switches icon between ic_repeat and ic_repeat_one', () {
      final player = AudioPlayer();
      handler.attachPlayer(player, initialLooping: false);

      expect(handler.playbackState.value.controls[3].androidIcon,
          equals('drawable/ic_repeat'));
      expect(handler.playbackState.value.repeatMode,
          equals(AudioServiceRepeatMode.none));

      handler.updateRepeatState(true);
      expect(handler.playbackState.value.controls[3].androidIcon,
          equals('drawable/ic_repeat_one'));
      expect(handler.playbackState.value.repeatMode,
          equals(AudioServiceRepeatMode.one));

      handler.updateRepeatState(false);
      expect(handler.playbackState.value.controls[3].androidIcon,
          equals('drawable/ic_repeat'));
      expect(handler.playbackState.value.repeatMode,
          equals(AudioServiceRepeatMode.none));

      player.dispose();
    });

    test('clearSession resets playbackState to idle with empty controls and null mediaItem', () async {
      final player = AudioPlayer();
      handler.attachPlayer(player);

      await handler.clearSession();

      expect(handler.playbackState.value.processingState,
          equals(AudioProcessingState.idle));
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.controls, isEmpty);
      expect(handler.mediaItem.value, isNull);

      player.dispose();
    });

    test('AudioBackgroundHandler.buildMediaItem formats metadata correctly', () {
      final item = AudioBackgroundHandler.buildMediaItem(
        id: 'https://example.com/audio.mp3',
        title: 'Al-Baqarah',
        arabicSurahName: 'البقرة',
        artist: 'Abdul Basit',
        arabicReciterName: 'عبد الباسط عبد الصمد',
        duration: const Duration(minutes: 45),
        artUri: Uri.parse('file:///data/user/0/cache/reciter.png'),
      );

      expect(item.id, equals('https://example.com/audio.mp3'));
      expect(item.title, equals('Al-Baqarah (البقرة)'));
      expect(item.artist, equals('Abdul Basit - عبد الباسط عبد الصمد'));
      expect(item.album, equals('القرآن الكريم'));
      expect(item.duration, equals(const Duration(minutes: 45)));
      expect(item.artUri, isNotNull);
    });
  });

  group('Coordinator Notification Actions Integration Tests', () {
    final testSurahs = [
      SurahModel(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        revelationType: 'Meccan',
        ayahs: const [],
      ),
      SurahModel(
        number: 2,
        name: 'البقرة',
        englishName: 'Al-Baqarah',
        englishNameTranslation: 'The Cow',
        revelationType: 'Medinan',
        ayahs: const [],
      ),
      SurahModel(
        number: 3,
        name: 'آل عمران',
        englishName: 'Aal-i-Imraan',
        englishNameTranslation: 'The Family of Imraan',
        revelationType: 'Medinan',
        ayahs: const [],
      ),
    ];

    final testReciter = reciters.first;

    test('skipToPrevious on Surah 1 gracefully seeks to zero without errors', () async {
      final handler = QuranAudioHandler();
      final fakeService = FakeAudioPlayerService();
      final playerController = AudioPlayerController(audioService: fakeService);

      final coordinator = AudioPlayerCoordinator(
        initialSurah: testSurahs[0],
        initialReciter: testReciter,
        surahList: testSurahs,
        playerController: playerController,
        audioHandler: handler,
      )..init();

      expect(coordinator.currentSurah.number, equals(1));
      expect(coordinator.hasPrevious, isFalse);

      // Calling handler.skipToPrevious() should not crash and should remain on Surah 1
      await handler.skipToPrevious();

      expect(coordinator.currentSurah.number, equals(1));

      coordinator.dispose();
    });

    test('skipToNext advances to next Surah and updates metadata', () async {
      final handler = QuranAudioHandler();
      final fakeService = FakeAudioPlayerService();
      final playerController = AudioPlayerController(audioService: fakeService);

      final coordinator = AudioPlayerCoordinator(
        initialSurah: testSurahs[0],
        initialReciter: testReciter,
        surahList: testSurahs,
        audioMap: {
          1: 'https://example.com/001.mp3',
          2: 'https://example.com/002.mp3',
          3: 'https://example.com/003.mp3',
        },
        playerController: playerController,
        audioHandler: handler,
      )..init();

      expect(coordinator.currentSurah.number, equals(1));

      await handler.skipToNext();

      expect(coordinator.currentSurah.number, equals(2));
      expect(coordinator.currentSurah.englishName, equals('Al-Baqarah'));

      coordinator.dispose();
    });

    test('customAction toggleRepeat toggles repeat mode and syncs to notification', () async {
      final handler = QuranAudioHandler();
      final fakeService = FakeAudioPlayerService();
      final playerController = AudioPlayerController(audioService: fakeService);

      final coordinator = AudioPlayerCoordinator(
        initialSurah: testSurahs[1],
        initialReciter: testReciter,
        surahList: testSurahs,
        playerController: playerController,
        audioHandler: handler,
      )..init();

      expect(coordinator.isLoopingSurah, isFalse);
      expect(handler.isLooping, isFalse);

      // Trigger customAction from notification
      await handler.customAction('toggleRepeat');

      expect(coordinator.isLoopingSurah, isTrue);
      expect(handler.isLooping, isTrue);

      // Toggle again
      await handler.customAction('toggleRepeat');

      expect(coordinator.isLoopingSurah, isFalse);
      expect(handler.isLooping, isFalse);

      coordinator.dispose();
    });

    test('stop notification action completely clears session and hides player', () async {
      final handler = QuranAudioHandler();
      final fakeService = FakeAudioPlayerService();
      final playerController = AudioPlayerController(audioService: fakeService);

      final coordinator = AudioPlayerCoordinator(
        initialSurah: testSurahs[0],
        initialReciter: testReciter,
        initialAudioUrl: 'https://example.com/001.mp3',
        surahList: testSurahs,
        playerController: playerController,
        audioHandler: handler,
      )..init();

      expect(coordinator.hasActiveSession, isTrue);

      await handler.stop();

      expect(coordinator.hasActiveSession, isFalse);
      expect(handler.playbackState.value.processingState,
          equals(AudioProcessingState.idle));
      expect(handler.playbackState.value.controls, isEmpty);

      coordinator.dispose();
    });
  });
}
