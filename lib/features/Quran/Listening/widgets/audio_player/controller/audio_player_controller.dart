import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';

/// Minimal, clean controller responsible strictly for core audio playback functionality:
/// initialization, playback controls, position, duration, buffering, state streams, and lifecycle.
class AudioPlayerController extends ChangeNotifier {
  final AudioPlayerService _audioService;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  FutureOr<void> Function()? _onPlaybackCompleted;

  String? _currentAudioUrl;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  AudioPlayerController({
    AudioPlayerService? audioService,
  }) : _audioService = audioService ?? AudioPlayerService();

  // Core state getters
  String? get currentAudioUrl => _currentAudioUrl;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _audioService.isPlaying;

  // Streams
  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<Duration> get bufferedPositionStream =>
      _audioService.bufferedPositionStream;

  // Durations & playback properties
  Duration get duration => _audioService.duration;
  Duration get position => _audioService.position;
  Duration get bufferedPosition => _audioService.bufferedPosition;
  double get speed => _audioService.speed;

  // Direct player access if needed
  AudioPlayer get player => _audioService.player;

  void init() {
    _listenToPlaybackState();
  }

  void setOnPlaybackCompleted(FutureOr<void> Function() callback) {
    _onPlaybackCompleted = callback;
  }

  Future<void> loadAudio({
    required String url,
    required String title,
    required String artist,
  }) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      _currentAudioUrl = url;
      notifyListeners();

      await _audioService.loadAudioSource(
        url: url,
        title: title,
        artist: artist,
      );

      _isLoading = false;
      notifyListeners();

      unawaited(
        _audioService.play().catchError((e) {
          _hasError = true;
          _errorMessage = 'Playback error occurred. Please try again.';
          _isLoading = false;
          notifyListeners();
        }),
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to play recitation. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() => _audioService.play();

  Future<void> pause() => _audioService.pause();

  void togglePlayPause(bool isPlaying) {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  Future<void> stop() => _audioService.player.stop();

  Future<void> seek(Duration position) => _audioService.seek(position);

  Future<void> rewind([Duration offset = const Duration(seconds: 10)]) =>
      _audioService.rewind(offset);

  Future<void> forward([Duration offset = const Duration(seconds: 10)]) =>
      _audioService.forward(offset);

  Future<void> setSpeed(double newSpeed) async {
    await _audioService.setSpeed(newSpeed);
    notifyListeners();
  }

  Future<void> setLoopMode(LoopMode mode) => _audioService.setLoopMode(mode);

  void _listenToPlaybackState() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
