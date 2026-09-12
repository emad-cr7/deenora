import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Dedicated AudioHandler that connects the Android MediaSession notification
/// to Deenora's existing audio architecture and AudioPlayerCoordinator.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  static QuranAudioHandler? _instance;
  static QuranAudioHandler get instance =>
      _instance ?? (_instance = QuranAudioHandler._internal());

  factory QuranAudioHandler() => instance;

  QuranAudioHandler._internal();

  AudioPlayer? _player;
  bool _isLooping = false;
  bool _hasPrevious = true;
  bool _hasNext = true;
  bool _isSessionActive = false;

  bool get isLooping => _isLooping;
  bool get hasPrevious => _hasPrevious;
  bool get hasNext => _hasNext;
  bool get isSessionActive => _isSessionActive;

  // Callbacks hooked directly into AudioPlayerCoordinator
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onStop;
  Future<void> Function()? onSkipToNext;
  Future<void> Function()? onSkipToPrevious;
  Future<void> Function()? onToggleRepeat;
  Future<void> Function(Duration position)? onSeek;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;

  /// Connects the active [AudioPlayer] instance to this handler so that
  /// playback states and positions are continually mapped to the system notification.
  void attachPlayer(
    AudioPlayer player, {
    bool initialLooping = false,
    bool initialHasPrevious = true,
    bool initialHasNext = true,
  }) {
    _player = player;
    _isLooping = initialLooping;
    _hasPrevious = initialHasPrevious;
    _hasNext = initialHasNext;
    _isSessionActive = true;

    _playerStateSubscription?.cancel();
    _playerStateSubscription = player.playerStateStream.listen((state) {
      _broadcastCurrentState();
    });

    _positionSubscription?.cancel();
    _positionSubscription = player.positionStream.listen((_) {
      _broadcastCurrentState();
    });

    _bufferedPositionSubscription?.cancel();
    _bufferedPositionSubscription = player.bufferedPositionStream.listen((_) {
      _broadcastCurrentState();
    });

    _broadcastCurrentState();
  }

  /// Updates Surah metadata displayed in the notification
  void updateMetadata(MediaItem item) {
    _isSessionActive = true;
    mediaItem.add(item);
  }

  /// Updates the repeat (loop) state and refreshes notification actions
  void updateRepeatState(bool isLooping) {
    _isLooping = isLooping;
    _broadcastCurrentState();
  }

  /// Updates navigation boundary states (whether previous or next surah is available)
  void updateNavigationState({
    required bool hasPrevious,
    required bool hasNext,
  }) {
    _hasPrevious = hasPrevious;
    _hasNext = hasNext;
    _broadcastCurrentState();
  }

  /// Clears playback state and media item, effectively hiding the notification
  Future<void> clearSession() async {
    _isSessionActive = false;
    playbackState.add(
      PlaybackState(
        controls: const [],
        systemActions: const {},
        androidCompactActionIndices: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        speed: 1.0,
      ),
    );
    mediaItem.add(null);
  }

  // --- AudioService Callbacks (from Android Notification / MediaSession) ---

  @override
  Future<void> play() async {
    if (onPlay != null) {
      await onPlay!();
    } else {
      await _player?.play();
    }
  }

  @override
  Future<void> pause() async {
    if (onPause != null) {
      await onPause!();
    } else {
      await _player?.pause();
    }
  }

  @override
  Future<void> stop() async {
    if (onStop != null) {
      await onStop!();
    } else {
      await _player?.stop();
      await clearSession();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeek != null) {
      await onSeek!(position);
    } else {
      await _player?.seek(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onSkipToNext != null) {
      await onSkipToNext!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPrevious != null) {
      await onSkipToPrevious!();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (onToggleRepeat != null) {
      await onToggleRepeat!();
    }
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'toggleRepeat') {
      if (onToggleRepeat != null) {
        await onToggleRepeat!();
      }
      return true;
    }
    return super.customAction(name, extras);
  }

  // --- State Broadcasting ---

  void _broadcastCurrentState() {
    final player = _player;
    if (player == null || !_isSessionActive) return;

    final isPlaying = player.playing;
    final processingState = player.processingState;

    final mappedProcessingState = switch (processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    // Construct the 5 notification controls
    final repeatControl = MediaControl(
      androidIcon: _isLooping ? 'drawable/ic_repeat_one' : 'drawable/ic_repeat',
      label: _isLooping ? 'تكرار السورة (مفعّل)' : 'تكرار السورة (معطّل)',
      action: MediaAction.custom,
      customAction: const CustomMediaAction(name: 'toggleRepeat'),
    );

    final stopControl = const MediaControl(
      androidIcon: 'drawable/audio_service_stop',
      label: 'إيقاف التلاوة',
      action: MediaAction.stop,
    );

    final controls = [
      MediaControl.skipToPrevious,
      isPlaying ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      repeatControl,
      stopControl,
    ];

    // Compact indices: Previous (0), Play/Pause (1), Next (2)
    final compactIndices = [0, 1, 2];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: {
          MediaAction.seek,
          MediaAction.setRepeatMode,
          MediaAction.stop,
          if (_hasNext) MediaAction.skipToNext,
          if (_hasPrevious) MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: compactIndices,
        processingState: mappedProcessingState,
        playing: isPlaying && processingState != ProcessingState.completed,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        repeatMode: _isLooping
            ? AudioServiceRepeatMode.one
            : AudioServiceRepeatMode.none,
      ),
    );
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
  }
}
