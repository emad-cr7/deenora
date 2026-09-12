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
import '../services/quran_audio_handler.dart';
import '../services/audio_background_handler.dart';

/// Orchestrator coordinator that binds together the independent feature controllers:
/// audio playback, surah navigation, reciter handling, sleep timer, loop mode,
/// and Android media notification / lock-screen controls.
class AudioPlayerCoordinator extends ChangeNotifier {
  final AudioPlayerController playerController;
  final SurahNavigationController navigationController;
  final SleepTimerController sleepTimerController;
  final RepeatController repeatController;
  final ReciterAudioHandler reciterHandler;
  final QuranAudioHandler audioHandler;

  final String? _initialAudioUrl;
  bool _isTransitioning = false;
  bool _hasActiveSession = false;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPlayerCoordinator({
    SurahModel? initialSurah,
    ReciterModel? initialReciter,
    String? initialAudioUrl,
    List<SurahModel>? surahList,
    Map<int, String>? audioMap,
    AudioPlayerController? playerController,
    SurahNavigationController? navigationController,
    SleepTimerController? sleepTimerController,
    RepeatController? repeatController,
    ReciterAudioHandler? reciterHandler,
    AudioPlayerService? audioService,
    QuranAudioHandler? audioHandler,
  })  : _initialAudioUrl = initialAudioUrl,
        _hasActiveSession = initialSurah != null && initialAudioUrl != null,
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
            ),
        audioHandler = audioHandler ?? QuranAudioHandler.instance {
    // Listen to changes from sub-controllers and propagate to coordinator listeners
    this.playerController.addListener(notifyListeners);
    this.navigationController.addListener(_onNavigationChanged);
    this.sleepTimerController.addListener(notifyListeners);
    this.repeatController.addListener(_onRepeatChanged);
    this.reciterHandler.addListener(notifyListeners);
  }

  void _onNavigationChanged() {
    audioHandler.updateNavigationState(
      hasPrevious: hasPrevious,
      hasNext: hasNext,
    );
    notifyListeners();
  }

  void _onRepeatChanged() {
    audioHandler.updateRepeatState(repeatController.isLooping);
    notifyListeners();
  }

  // --- Convenience Getters & Delegates ---
  bool get hasActiveSession => _hasActiveSession;
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
  Stream<Duration?> get durationStream => playerController.durationStream;
  Stream<Duration> get bufferedPositionStream => playerController.bufferedPositionStream;
  Duration get duration => playerController.duration;
  Duration get bufferedPosition => playerController.bufferedPosition;
  double get speed => playerController.speed;

  // --- Initialization ---
  void init() {
    playerController.init();
    navigationController.ensureSurahListLoaded();

    playerController.setOnPlaybackCompleted(_handlePlaybackCompleted);

    // Attach AudioPlayer to QuranAudioHandler for MediaSession and Android notifications
    audioHandler.attachPlayer(
      playerController.player,
      initialLooping: repeatController.isLooping,
      initialHasPrevious: hasPrevious,
      initialHasNext: hasNext,
    );

    // Register AudioHandler notification action callbacks
    audioHandler.onPlay = () => playerController.play();
    audioHandler.onPause = () => playerController.pause();
    audioHandler.onStop = () => stopAndClearSession();
    audioHandler.onSkipToNext = () => playNextSurah();
    audioHandler.onSkipToPrevious = () => playPreviousSurah();
    audioHandler.onToggleRepeat = () => toggleLoop();
    audioHandler.onSeek = (pos) => seek(pos);

    // Listen for duration updates to keep notification metadata accurate
    _durationSubscription?.cancel();
    _durationSubscription = playerController.durationStream.listen((d) {
      if (d != null && _hasActiveSession) {
        _syncNotificationMetadata(duration: d);
      }
    });

    final initialUrl = _initialAudioUrl;
    if (initialUrl != null && initialUrl.isNotEmpty) {
      playerController.loadAudio(
        url: initialUrl,
        title: navigationController.currentSurah.englishName,
        artist: reciterHandler.currentReciter.name,
      );
      _syncNotificationMetadata();
    }
  }

  // --- Notification Metadata Synchronization ---
  Future<void> _syncNotificationMetadata({Duration? duration}) async {
    final surah = navigationController.currentSurah;
    final currentReciter = reciterHandler.currentReciter;
    final url = playerController.currentAudioUrl ?? '';

    final artUri = await AudioBackgroundHandler.resolveArtworkUri(currentReciter.imagePath);

    final item = AudioBackgroundHandler.buildMediaItem(
      id: url.isNotEmpty ? url : 'surah_${surah.number}',
      title: surah.englishName,
      arabicSurahName: surah.name,
      artist: currentReciter.name,
      arabicReciterName: currentReciter.arabicName,
      duration: duration ?? (playerController.duration > Duration.zero ? playerController.duration : null),
      artUri: artUri,
    );

    audioHandler.updateMetadata(item);
    audioHandler.updateNavigationState(
      hasPrevious: hasPrevious,
      hasNext: hasNext,
    );
    audioHandler.updateRepeatState(repeatController.isLooping);
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
  Future<void> startRecitation({
    required SurahModel surah,
    required ReciterModel reciter,
    required String audioUrl,
    List<SurahModel>? surahList,
    Map<int, String>? audioMap,
  }) async {
    _hasActiveSession = true;

    final isSameRecitation =
        navigationController.currentSurah.number == surah.number &&
            reciterHandler.currentReciter.id == reciter.id &&
            playerController.currentAudioUrl == audioUrl;

    navigationController.updateCurrentSurah(surah);
    if (surahList != null) {
      navigationController.updateSurahList(surahList);
    } else {
      navigationController.ensureSurahListLoaded();
    }

    reciterHandler.setReciter(reciter);
    if (audioMap != null) {
      reciterHandler.setAudioMap(audioMap);
    }

    if (isSameRecitation && !playerController.hasError) {
      _syncNotificationMetadata();
      notifyListeners();
      return;
    }

    playerController.setOnPlaybackCompleted(_handlePlaybackCompleted);

    await playerController.loadAudio(
      url: audioUrl,
      title: surah.englishName,
      artist: reciter.name,
    );

    await _syncNotificationMetadata();
  }

  Future<void> stopAndClearSession() async {
    await playerController.stop();
    await seek(Duration.zero);
    _hasActiveSession = false;
    await audioHandler.clearSession();
    notifyListeners();
  }

  Future<void> playSurah(SurahModel targetSurah) async {
    if (!navigationController.isValidSurahNumber(targetSurah.number)) {
      return;
    }

    _hasActiveSession = true;
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

    await _syncNotificationMetadata();
  }

  Future<void> playNextSurah() async {
    if (navigationController.currentSurah.number >= 114) {
      // Last Surah in Quran: do not crash, gracefully handle boundary
      await playerController.pause();
      await seek(Duration.zero);
      return;
    }

    final next = navigationController.getNextSurah();
    if (next != null) {
      await playSurah(next);
    }
  }

  Future<void> playPreviousSurah() async {
    if (navigationController.currentSurah.number <= 1) {
      // First Surah in Quran: do not crash, gracefully seek to start
      await seek(Duration.zero);
      return;
    }

    final prev = navigationController.getPreviousSurah();
    if (prev != null) {
      await playSurah(prev);
    } else {
      await seek(Duration.zero);
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
      await _syncNotificationMetadata();
    }
  }

  Future<void> toggleLoop() async {
    await repeatController.toggleLoop(
      onLoopModeChanged: (mode) => playerController.setLoopMode(mode),
    );
    audioHandler.updateRepeatState(repeatController.isLooping);
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

  Future<void> seek(Duration position) => playerController.seek(position);

  void togglePlayPause(bool isPlaying) => playerController.togglePlayPause(isPlaying);

  Future<void> rewind10() => playerController.rewind();

  Future<void> forward10() => playerController.forward();

  @override
  void dispose() {
    _durationSubscription?.cancel();
    playerController.removeListener(notifyListeners);
    navigationController.removeListener(_onNavigationChanged);
    sleepTimerController.removeListener(notifyListeners);
    repeatController.removeListener(_onRepeatChanged);
    reciterHandler.removeListener(notifyListeners);

    playerController.dispose();
    navigationController.dispose();
    sleepTimerController.dispose();
    repeatController.dispose();
    reciterHandler.dispose();

    super.dispose();
  }
}
