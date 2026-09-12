import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models_listening/reciter_model.dart';
import '../../../../reading/models/surah_model.dart';
import '../controller/audio_player_controller.dart';
import '../controller/audio_player_coordinator.dart';
import '../controller/reciter_audio_handler.dart';
import '../controller/repeat_controller.dart';
import '../controller/sleep_timer_controller.dart';
import '../controller/surah_navigation_controller.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerCoordinator>(
          create: (_) => AudioPlayerCoordinator(
            initialSurah: surah,
            initialReciter: reciter,
            initialAudioUrl: audioUrl,
            surahList: surahList,
            audioMap: audioMap,
          )..init(),
        ),
        ChangeNotifierProxyProvider<AudioPlayerCoordinator, AudioPlayerController>(
          create: (ctx) => ctx.read<AudioPlayerCoordinator>().playerController,
          update: (_, coord, previous) => coord.playerController,
        ),
        ChangeNotifierProxyProvider<AudioPlayerCoordinator, SurahNavigationController>(
          create: (ctx) => ctx.read<AudioPlayerCoordinator>().navigationController,
          update: (_, coord, previous) => coord.navigationController,
        ),
        ChangeNotifierProxyProvider<AudioPlayerCoordinator, SleepTimerController>(
          create: (ctx) => ctx.read<AudioPlayerCoordinator>().sleepTimerController,
          update: (_, coord, previous) => coord.sleepTimerController,
        ),
        ChangeNotifierProxyProvider<AudioPlayerCoordinator, RepeatController>(
          create: (ctx) => ctx.read<AudioPlayerCoordinator>().repeatController,
          update: (_, coord, previous) => coord.repeatController,
        ),
        ChangeNotifierProxyProvider<AudioPlayerCoordinator, ReciterAudioHandler>(
          create: (ctx) => ctx.read<AudioPlayerCoordinator>().reciterHandler,
          update: (_, coord, previous) => coord.reciterHandler,
        ),
      ],
      child: const AudioPlayerView(),
    );
  }
}
