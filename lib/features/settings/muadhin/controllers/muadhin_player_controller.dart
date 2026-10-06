import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';

/// Controller responsible for managing inline audio playback of Adhan & Iqama tracks.
class MuadhinPlayerController extends ChangeNotifier {
  final AudioPlayer _player;
  final bool _ownsPlayer;

  String? _currentAudioUrl;
  String? _currentMuadhinId;
  MuadhinType? _currentType;
  String? _playbackError;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;

  MuadhinPlayerController({AudioPlayer? player})
      : _player = player ?? AudioPlayer(),
        _ownsPlayer = player == null {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Reset playback position to beginning when finished
        _player.seek(Duration.zero);
        _player.pause();
      }
      notifyListeners();
    });

    _playbackEventSubscription = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e) {
        _playbackError = 'Failed to play audio track';
        notifyListeners();
      },
    );
  }

  // --- Getters & Streams ---
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;

  Duration get duration => _player.duration ?? Duration.zero;
  Duration get bufferedPosition => _player.bufferedPosition;
  bool get isPlaying => _player.playing;

  String? get currentAudioUrl => _currentAudioUrl;
  String? get currentMuadhinId => _currentMuadhinId;
  MuadhinType? get currentType => _currentType;
  String? get playbackError => _playbackError;

  /// Checks if this specific Muadhin and type is the one currently loaded/active.
  bool isTrackActive(String muadhinId, MuadhinType type) {
    return _currentMuadhinId == muadhinId && _currentType == type;
  }

  /// Checks if this specific Muadhin and type is currently playing audio.
  bool isTrackPlaying(String muadhinId, MuadhinType type) {
    return isTrackActive(muadhinId, type) && isPlaying;
  }

  // --- Playback Controls ---

  /// Plays or toggles the audio track for a specific Muadhin.
  /// If the same track is active: toggles between play and pause.
  /// If a different track is requested: stops the old track, loads the new track, and starts playback.
  Future<void> playMuadhin({
    required String audioUrl,
    required String muadhinId,
    required MuadhinType type,
  }) async {
    // If same track is already loaded, toggle play/pause
    if (isTrackActive(muadhinId, type)) {
      if (_player.playing) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    _playbackError = null;
    _currentAudioUrl = audioUrl;
    _currentMuadhinId = muadhinId;
    _currentType = type;
    notifyListeners();

    try {
      await _player.stop();
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await _player.play();
    } catch (e) {
      _playbackError = 'Failed to play audio track';
      notifyListeners();
    }
  }

  /// Pauses audio playback.
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  /// Resumes audio playback.
  Future<void> resume() async {
    try {
      await _player.play();
    } catch (_) {}
  }

  /// Stops audio playback and resets the active track.
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _currentAudioUrl = null;
    _currentMuadhinId = null;
    _currentType = null;
    _playbackError = null;
    notifyListeners();
  }

  /// Seeks to a specific timestamp.
  Future<void> seek(Duration target) async {
    try {
      final maxDuration = _player.duration ?? Duration.zero;
      final clamped = target < Duration.zero
          ? Duration.zero
          : (target > maxDuration ? maxDuration : target);
      await _player.seek(clamped);
    } catch (_) {}
  }

  /// Seeks backward by [offset] (default 10 seconds).
  Future<void> rewind([Duration offset = const Duration(seconds: 10)]) async {
    final newPos = _player.position - offset;
    await seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  /// Seeks forward by [offset] (default 10 seconds).
  Future<void> forward([Duration offset = const Duration(seconds: 10)]) async {
    final maxDuration = _player.duration ?? Duration.zero;
    final newPos = _player.position + offset;
    await seek(newPos > maxDuration ? maxDuration : newPos);
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playbackEventSubscription?.cancel();
    if (_ownsPlayer) {
      _player.stop();
      _player.dispose();
    }
    super.dispose();
  }
}
