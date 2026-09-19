import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models_listening/reciter_model.dart';
import '../../../../reading/models/surah_model.dart';
import '../controller/audio_player_coordinator.dart';
import 'audio_player_view.dart';

class AudioPlayerScreen extends StatefulWidget {
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
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioPlayerCoordinator>().startRecitation(
        surah: widget.surah,
        reciter: widget.reciter,
        audioUrl: widget.audioUrl,
        surahList: widget.surahList,
        audioMap: widget.audioMap,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AudioPlayerView();
  }
}
