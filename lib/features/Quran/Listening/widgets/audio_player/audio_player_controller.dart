import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../models_listening/name_surah_model.dart';
import '../../models_listening/reciter_model.dart';

class AudioPlayerController extends ChangeNotifier {
  final NameSurahModel chapter;
  final ReciterModel reciter;
  final String audioUrl;

  AudioPlayerController({
    required this.chapter,
    required this.reciter,
    required this.audioUrl,
  });

  final AudioPlayer player = AudioPlayer();
  bool hasError = false;

  Stream<Duration> get positionStream => player.positionStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Duration get duration => player.duration ?? Duration.zero;
  Duration get bufferedPosition => player.bufferedPosition;

  void seek(Duration position) => player.seek(position);

  void togglePlayPause(bool isPlaying) {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
  }

  void init() {
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: audioUrl,
            title: chapter.nameSimple,
            artist: reciter.name,
          ),
        ),
      );
      player.play();
      notifyListeners();
    } catch (_) {
      hasError = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}