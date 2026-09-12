import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models_listening/reciter_model.dart';
import '../../../../reading/models/surah_model.dart';
import '../controller/audio_player_coordinator.dart';
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
    return ChangeNotifierProvider<AudioPlayerCoordinator>(
      create: (_) => AudioPlayerCoordinator(
        initialSurah: surah,
        initialReciter: reciter,
        initialAudioUrl: audioUrl,
        surahList: surahList,
        audioMap: audioMap,
      )..init(),
      child: const AudioPlayerView(),
    );
  }
}
