import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models_listening/name_surah_model.dart';
import 'audio_player_controller.dart';
import 'audio_player_view.dart';

class AudioPlayerScreen extends StatelessWidget {
  final NameSurahModel chapter;
  final ReciterModel reciter;
  final String audioUrl;

  const AudioPlayerScreen({
    super.key,
    required this.chapter,
    required this.reciter,
    required this.audioUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioPlayerController>(
      create: (_) => AudioPlayerController(
        chapter: chapter,
        reciter: reciter,
        audioUrl: audioUrl,
      )..init(),
      child: const AudioPlayerView(),
    );
  }
}

