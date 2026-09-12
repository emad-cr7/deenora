import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_controller.dart';
import 'audio_player_view.dart';

class AudioPlayerScreen extends StatelessWidget {
  final SurahModel surah;
  final ReciterModel reciter;
  final String audioUrl;
  final List<SurahModel>? surahList;
  final Map<int, String>? audioMap;

  const AudioPlayerScreen({
    super.key,
    required this.surah,
    required this.reciter,
    required this.audioUrl,
    this.surahList,
    this.audioMap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioPlayerController>(
      create: (_) => AudioPlayerController(
        surah: surah,
        reciter: reciter,
        audioUrl: audioUrl,
        surahList: surahList,
        audioMap: audioMap,
      )..init(),
      child: const AudioPlayerView(),
    );
  }
}

