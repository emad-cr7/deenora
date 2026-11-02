import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class MuadhinPlayerController extends ChangeNotifier {
  final AudioPlayer player;
  final bool _ownsPlayer;

  String? _currentMuadhinId;
  String? _currentType;
  String? playbackError;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;

  MuadhinPlayerController({AudioPlayer? player})
    : player = player ?? AudioPlayer(),
      _ownsPlayer = player == null {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Reset playback position to beginning when finished
        player.seek(Duration.zero);
        player.pause();
      }
      notifyListeners();
    });

    _playbackEventSubscription = player.playbackEventStream.listen(
      (_) {},
      onError: (Object e) {
        playbackError = 'Failed to play audio track';
        notifyListeners();
      },
    );
  }

  bool isTrackActive(String muadhinId, String type) {
    return _currentMuadhinId == muadhinId && _currentType == type;
  }

  bool isTrackPlaying(String muadhinId, String type) {
    return isTrackActive(muadhinId, type) && player.playing;
  }

  // --- Playback Controls ---


  Future<void> playMuadhin({
    required String audioUrl,
    required String muadhinId,
    required String type,
  }) async {
    // If same track is already loaded, toggle play/pause
    if (isTrackActive(muadhinId, type)) {
      if (player.playing) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    playbackError = null;
    _currentMuadhinId = muadhinId;
    _currentType = type;
    notifyListeners();

    try {
      await player.stop();
      await player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await player.play();
    } catch (e) {
      playbackError = 'Failed to play audio track';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await player.play();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await player.stop();
    } catch (_) {}
    _currentMuadhinId = null;
    _currentType = null;
    playbackError = null;
    notifyListeners();
  }

  Future<void> seek(Duration target) async {
    try {
      final maxDuration = player.duration ?? Duration.zero;
      final clamped = target < Duration.zero
          ? Duration.zero
          : (target > maxDuration ? maxDuration : target);
      await player.seek(clamped);
    } catch (_) {}
  }

  Future<void> rewind([Duration offset = const Duration(seconds: 10)]) =>
      seek(player.position - offset);

  Future<void> forward([Duration offset = const Duration(seconds: 10)]) =>
      seek(player.position + offset);

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playbackEventSubscription?.cancel();
    if (_ownsPlayer) {
      player.stop();
      player.dispose();
    }
    super.dispose();
  }
}
