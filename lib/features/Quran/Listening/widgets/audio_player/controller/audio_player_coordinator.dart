import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'audio_player_controller.dart';
import 'surah_navigation_controller.dart';
import 'reciter_audio_handler.dart';
import 'repeat_controller.dart';
import 'sleep_timer_controller.dart';
import '../models/sleep_timer_option.dart';
import '../services/audio_player_service.dart';

/// Orchestrator coordinator that binds together the independent feature controllers:
/// audio playback, surah navigation, reciter handling, sleep timer, and loop mode.
class AudioPlayerCoordinator extends ChangeNotifier {
  final AudioPlayerController playerController;
  final SurahNavigationController navigationController;
  final SleepTimerController sleepTimerController;
  final RepeatController repeatController;
  final ReciterAudioHandler reciterHandler;

  final String _initialAudioUrl;
  bool _isTransitioning = false;

  AudioPlayerCoordinator({
    required SurahModel initialSurah,
    required ReciterModel initialReciter,
    required String initialAudioUrl,
    List<SurahModel>? surahList,
    Map<int, String>? audioMap,
    AudioPlayerController? playerController,
    SurahNavigationController? navigationController,
    SleepTimerController? sleepTimerController,
    RepeatController? repeatController,
    ReciterAudioHandler? reciterHandler,
    AudioPlayerService? audioService,
  })  : _initialAudioUrl = initialAudioUrl,
        playerController = playerController ??
            AudioPlayerController(audioService: audioService),
        navigationController = navigationController ??
            SurahNavigationController(
              initialSurah: initialSurah,
              surahList: surahList,
            ),
        sleepTimerController =
            sleepTimerController ?? SleepTimerController(),
        repeatController = repeatController ?? RepeatController(),
        reciterHandler = reciterHandler ??
            ReciterAudioHandler(
              initialReciter: initialReciter,
              initialAudioMap: audioMap,
            ) {
    // Listen to changes from sub-controllers and propagate to coordinator listeners
    this.playerController.addListener(notifyListeners);
    this.navigationController.addListener(notifyListeners);
    this.sleepTimerController.addListener(notifyListeners);
    this.repeatController.addListener(notifyListeners);
    this.reciterHandler.addListener(notifyListeners);
  }

  // --- Convenience Getters & Delegates ---
  SurahModel get currentSurah => navigationController.currentSurah;
  SurahModel get surah => navigationController.currentSurah;
  ReciterModel get reciter => reciterHandler.currentReciter;
  List<SurahModel> get surahList => navigationController.surahList;
  int get currentSurahIndex => navigationController.currentSurahIndex;
  bool get hasPrevious => navigationController.hasPrevious;
  bool get hasNext => navigationController.hasNext;
  SurahModel? get previousSurah => navigationController.previousSurah;
  SurahModel? get nextSurah => navigationController.nextSurah;
  bool get canPlayPrevious => hasPrevious && !isLoadingSurah;
  bool get canPlayNext => hasNext && !isLoadingSurah;

  bool get isLoadingSurah => playerController.isLoading;
  bool get hasError => playerController.hasError;
  String? get errorMessage => playerController.errorMessage;

  bool get isSleepTimerActive => sleepTimerController.isActive;
  SleepTimerOption? get sleepTimerOption => sleepTimerController.selectedOption;
  int get sleepTimerRemainingSeconds => sleepTimerController.remainingSeconds;
  String get sleepTimerFormatted => sleepTimerController.formattedRemainingTime;

  bool get isLoopingSurah => repeatController.isLooping;

  Stream<PlayerState> get playerStateStream => playerController.playerStateStream;
  Stream<Duration> get positionStream => playerController.positionStream;
  Duration get duration => playerController.duration;
  Duration get bufferedPosition => playerController.bufferedPosition;
  double get speed => playerController.speed;

  // --- Initialization ---
  void init() {
    playerController.init();
    navigationController.ensureSurahListLoaded();

    playerController.setOnPlaybackCompleted(_handlePlaybackCompleted);

    playerController.loadAudio(
      url: _initialAudioUrl,
      title: navigationController.currentSurah.englishName,
      artist: reciterHandler.currentReciter.name,
    );
  }

  // --- Playback Completion Handling ---
  Future<void> _handlePlaybackCompleted() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      // 1. Sleep timer endOfSurah check
      if (sleepTimerController.isEndOfSurah) {
        await playerController.pause();
        await playerController.seek(Duration.zero);
        sleepTimerController.cancelTimer();
        return;
      }

      // 2. Loop check
      if (repeatController.isLooping) {
        await playerController.seek(Duration.zero);
        await playerController.play();
        return;
      }

      // 3. Next Surah check
      if (navigationController.hasNext &&
          navigationController.nextSurah != null) {
        await playNextSurah();
      } else {
        await playerController.pause();
        await playerController.seek(Duration.zero);
      }
    } finally {
      _isTransitioning = false;
    }
  }

  // --- Actions ---
  Future<void> playSurah(SurahModel targetSurah) async {
    if (!navigationController.isValidSurahNumber(targetSurah.number)) {
      return;
    }

    navigationController.updateCurrentSurah(targetSurah);

    final url = await reciterHandler.getAudioUrl(targetSurah.number);
    if (url == null) {
      return;
    }

    await playerController.loadAudio(
      url: url,
      title: targetSurah.englishName,
      artist: reciterHandler.currentReciter.name,
    );
  }

  Future<void> playNextSurah() async {
    final next = navigationController.getNextSurah();
    if (next != null) {
      await playSurah(next);
    }
  }

  Future<void> playPreviousSurah() async {
    final prev = navigationController.getPreviousSurah();
    if (prev != null) {
      await playSurah(prev);
    }
  }

  Future<void> changeReciter(ReciterModel newReciter) async {
    reciterHandler.setReciter(newReciter);
    final url = await reciterHandler.getAudioUrl(navigationController.currentSurah.number);
    if (url != null) {
      await playerController.loadAudio(
        url: url,
        title: navigationController.currentSurah.englishName,
        artist: newReciter.name,
      );
    }
  }

  Future<void> toggleLoop() async {
    await repeatController.toggleLoop(
      onLoopModeChanged: (mode) => playerController.setLoopMode(mode),
    );
  }

  void setSleepTimer(SleepTimerOption option, {int? customMinutes}) {
    sleepTimerController.startTimer(
      option,
      customMinutes: customMinutes,
      onTimerComplete: () => playerController.pause(),
    );
  }

  void cancelSleepTimer({bool notify = true}) {
    sleepTimerController.cancelTimer(notify: notify);
  }

  void retry() {
    playSurah(navigationController.currentSurah);
  }

  void seek(Duration position) => playerController.seek(position);

  void togglePlayPause(bool isPlaying) => playerController.togglePlayPause(isPlaying);

  void rewind10() => playerController.rewind();

  void forward10() => playerController.forward();

  @override
  void dispose() {
    playerController.removeListener(notifyListeners);
    navigationController.removeListener(notifyListeners);
    sleepTimerController.removeListener(notifyListeners);
    repeatController.removeListener(notifyListeners);
    reciterHandler.removeListener(notifyListeners);

    playerController.dispose();
    navigationController.dispose();
    sleepTimerController.dispose();
    repeatController.dispose();
    reciterHandler.dispose();

    super.dispose();
  }
}
