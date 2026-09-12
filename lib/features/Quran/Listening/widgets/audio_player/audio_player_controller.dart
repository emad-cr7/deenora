import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/data/local_data/hive_manager.dart';
import '../../../../../core/data/remote_data/quran/quran_listening_service.dart';
import '../../../reading/models/surah_model.dart';
import '../../models_listening/reciter_model.dart';
import 'controllers/sleep_timer_controller.dart';
import 'models/sleep_timer_option.dart';
import 'services/audio_player_service.dart';
import 'services/surah_navigation_service.dart';

// إعادة تصدير خيارات مؤقت النوم لضمان التوافق الكامل مع الملفات الأخرى
export 'models/sleep_timer_option.dart';

// متحكم منسق لمشغل التلاوة وإدارة الحالة بين الخدمات وواجهة المستخدم
class AudioPlayerController extends ChangeNotifier {
  final ReciterModel reciter;
  String _currentAudioUrl;
  Map<int, String>? _audioMap;

  final AudioPlayerService _audioService;
  final SurahNavigationService _navigationService;
  final SleepTimerController _timerController;
  final QuranListeningService _listeningService;
  final HiveManager _hiveManager;

  AudioPlayerController({
    required SurahModel surah,
    required this.reciter,
    required String audioUrl,
    List<SurahModel>? surahList,
    Map<int, String>? audioMap,
    AudioPlayerService? audioService,
    SurahNavigationService? navigationService,
    SleepTimerController? timerController,
    QuranListeningService? listeningService,
    HiveManager? hiveManager,
  })  : _currentAudioUrl = audioUrl,
        _audioMap = audioMap,
        _audioService = audioService ?? AudioPlayerService(),
        _navigationService = navigationService ??
            SurahNavigationService(
              initialSurah: surah,
              surahList: surahList,
            ),
        _timerController = timerController ?? SleepTimerController(),
        _listeningService = listeningService ?? QuranListeningService(),
        _hiveManager = hiveManager ?? HiveManager() {
    // الاستماع لتحديثات مؤقت النوم وتنبيه واجهة المستخدم
    _timerController.addListener(notifyListeners);
  }

  bool hasError = false;
  String? errorMessage;
  bool isLoadingSurah = false;
  bool _isTransitioningSurah = false;

  StreamSubscription<PlayerState>? _playerStateSubscription;

  // كائن المشغل الداخلي للتوافقية
  AudioPlayer get player => _audioService.player;

  // خصائص السورة الحالية والتنقل
  SurahModel get surah => _navigationService.currentSurah;
  SurahModel get currentSurah => _navigationService.currentSurah;
  String get currentAudioUrl => _currentAudioUrl;
  List<SurahModel> get surahList => _navigationService.surahList;
  int get currentSurahIndex => _navigationService.currentSurahIndex;
  bool get hasPrevious => _navigationService.hasPrevious;
  bool get hasNext => _navigationService.hasNext;
  SurahModel? get previousSurah => _navigationService.previousSurah;
  SurahModel? get nextSurah => _navigationService.nextSurah;

  // تدفقات وحالات تشغيل الصوت
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Duration get duration => _audioService.duration;
  Duration get bufferedPosition => _audioService.bufferedPosition;
  double get speed => _audioService.speed;
  bool get isLoopingSurah => _audioService.isLooping;

  // خصائص مؤقت النوم
  bool get isSleepTimerActive => _timerController.isActive;
  SleepTimerOption? get sleepTimerOption => _timerController.selectedOption;
  int get sleepTimerRemainingSeconds => _timerController.remainingSeconds;
  String get sleepTimerFormatted => _timerController.formattedRemainingTime;

  // ---------------- تهيئة المشغل ----------------

  void init() {
    _ensureSurahList();
    _initAudio();
    _listenToPlaybackState();
  }

  // التأكد من توفر قائمة السور عبر الذاكرة المحلية عند الحاجة
  void _ensureSurahList() {
    if (_navigationService.surahList.isEmpty) {
      final cached = _hiveManager.loadSurahs();
      if (cached.isNotEmpty) {
        _navigationService.updateSurahList(cached);
        notifyListeners();
      }
    }
  }

  // بدء تشغيل التلاوة المحددة
  Future<void> _initAudio() async {
    await _loadAudioSource(_currentAudioUrl, _navigationService.currentSurah);
  }

  // تحميل مصدر الصوت وتحديث البيانات التعريفية
  Future<void> _loadAudioSource(String url, SurahModel surah) async {
    try {
      hasError = false;
      errorMessage = null;
      isLoadingSurah = true;
      notifyListeners();

      await _audioService.loadAudioSource(
        url: url,
        title: surah.englishName,
        artist: reciter.name,
      );

      // إنهاء حالة تحميل السورة فور نجاح ضبط مصدر الصوت
      isLoadingSurah = false;
      notifyListeners();

      // تشغيل الصوت بشكل غير متزامن لتفادي تعليق واجهة المشغل أثناء التشغيل
      unawaited(
        _audioService.play().catchError((e) {
          hasError = true;
          errorMessage = 'Playback error occurred. Please try again.';
          isLoadingSurah = false;
          notifyListeners();
        }),
      );
    } catch (e) {
      hasError = true;
      errorMessage = 'Failed to play recitation. Please try again.';
      isLoadingSurah = false;
      notifyListeners();
    }
  }

  // مراقبة تدفق حالة المشغل لمعالجة انتهاء التشغيل
  void _listenToPlaybackState() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackCompleted();
      }
    });
  }

  // معالجة انتهاء تشغيل السورة الحالية
  Future<void> _onPlaybackCompleted() async {
    if (_isTransitioningSurah) return;
    _isTransitioningSurah = true;

    try {
      // إذا كان مؤقت النوم مضبوطاً على نهاية السورة، يتم إيقاف الصوت وإلغاء المؤقت
      if (_timerController.selectedOption == SleepTimerOption.endOfSurah) {
        await _audioService.pause();
        await _audioService.seek(Duration.zero);
        cancelSleepTimer();
        isLoadingSurah = false;
        notifyListeners();
        return;
      }

      // في حال تفعيل التكرار، تتم إعادة تشغيل السورة الحالية
      if (isLoopingSurah) {
        await _audioService.seek(Duration.zero);
        unawaited(
          _audioService.play().catchError((e) {
            hasError = true;
            errorMessage = 'Playback error occurred. Please try again.';
            isLoadingSurah = false;
            notifyListeners();
          }),
        );
        return;
      }

      // الانتقال للسورة التالية إذا كانت متوفرة
      if (hasNext && nextSurah != null) {
        await playNextSurah();
      } else {
        // السورة الأخيرة: التوقف عند البداية بدون حالة تحميل
        isLoadingSurah = false;
        await _audioService.pause();
        await _audioService.seek(Duration.zero);
        notifyListeners();
      }
    } finally {
      _isTransitioningSurah = false;
      isLoadingSurah = false;
      notifyListeners();
    }
  }

  // ---------------- إجراءات التنقل ----------------

  // تشغيل السورة التالية مع التحقق من الحدود
  Future<void> playNextSurah() async {
    if (!hasNext || nextSurah == null) {
      isLoadingSurah = false;
      notifyListeners();
      return;
    }
    if (isLoadingSurah) return;
    await _loadAndPlaySurah(nextSurah!);
  }

  // تشغيل السورة السابقة مع التحقق من الحدود
  Future<void> playPreviousSurah() async {
    if (!hasPrevious || previousSurah == null) {
      isLoadingSurah = false;
      notifyListeners();
      return;
    }
    if (isLoadingSurah) return;
    await _loadAndPlaySurah(previousSurah!);
  }

  // تشغيل سورة محددة
  Future<void> playSurah(SurahModel surah) async {
    if (isLoadingSurah) return;
    await _loadAndPlaySurah(surah);
  }

  // تحميل وتشغيل سورة والتأكد من نطاق الأرقام
  Future<void> _loadAndPlaySurah(SurahModel targetSurah) async {
    if (!_navigationService.isValidSurahNumber(targetSurah.number)) {
      isLoadingSurah = false;
      notifyListeners();
      return;
    }

    try {
      isLoadingSurah = true;
      hasError = false;
      errorMessage = null;
      _navigationService.updateCurrentSurah(targetSurah);
      notifyListeners();

      if (_audioMap == null || !_audioMap!.containsKey(targetSurah.number)) {
        _audioMap = await _listeningService.getReciterAudioFiles(reciter.id);
      }

      final url = _audioMap?[targetSurah.number];
      if (url == null) {
        hasError = true;
        errorMessage = 'Recitation is not available for this reciter.';
        isLoadingSurah = false;
        notifyListeners();
        return;
      }

      _currentAudioUrl = url;
      await _loadAudioSource(url, targetSurah);
    } catch (e) {
      hasError = true;
      errorMessage = 'Failed to load Surah recitation.';
      isLoadingSurah = false;
      notifyListeners();
    }
  }

  // إعادة المحاولة عند حدوث خطأ
  void retry() {
    _loadAndPlaySurah(_navigationService.currentSurah);
  }

  // ---------------- أدوات التحكم بالصوت ----------------

  void seek(Duration position) => _audioService.seek(position);

  void togglePlayPause(bool isPlaying) {
    if (isPlaying) {
      _audioService.pause();
    } else {
      _audioService.play();
    }
  }

  void rewind10() => _audioService.rewind(const Duration(seconds: 10));

  void forward10() => _audioService.forward(const Duration(seconds: 10));

  Future<void> setSpeed(double newSpeed) async {
    await _audioService.setSpeed(newSpeed);
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    final nextMode = isLoopingSurah ? LoopMode.off : LoopMode.one;
    await _audioService.setLoopMode(nextMode);
    notifyListeners();
  }

  // ---------------- إدارة مؤقت النوم ----------------

  void setSleepTimer(SleepTimerOption option, {int? customMinutes}) {
    _timerController.startTimer(
      option,
      customMinutes: customMinutes,
      onTimerComplete: () => _audioService.pause(),
    );
  }

  void cancelSleepTimer({bool notify = true}) {
    _timerController.cancelTimer(notify: notify);
  }

  // ---------------- تنظيف الموارد ----------------

  @override
  void dispose() {
    _timerController.removeListener(notifyListeners);
    _playerStateSubscription?.cancel();
    _timerController.dispose();
    _audioService.dispose();
    super.dispose();
  }
}