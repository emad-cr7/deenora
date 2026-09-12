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
  AudioPlayerCoordinator? _fallbackCoordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final coordinator = context.read<AudioPlayerCoordinator>();
        coordinator.startRecitation(
          surah: widget.surah,
          reciter: widget.reciter,
          audioUrl: widget.audioUrl,
          surahList: widget.surahList,
          audioMap: widget.audioMap,
        );
      } catch (_) {
        // Ancestor coordinator not present (e.g. isolated test)
      }
    });
  }

  @override
  void dispose() {
    _fallbackCoordinator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasAncestorCoordinator = false;
    try {
      Provider.of<AudioPlayerCoordinator>(context, listen: false);
      hasAncestorCoordinator = true;
    } catch (_) {
      hasAncestorCoordinator = false;
    }

    if (hasAncestorCoordinator) {
      return const AudioPlayerView();
    }

    _fallbackCoordinator ??= AudioPlayerCoordinator(
      initialSurah: widget.surah,
      initialReciter: widget.reciter,
      initialAudioUrl: widget.audioUrl,
      surahList: widget.surahList,
      audioMap: widget.audioMap,
    )..init();

    return ChangeNotifierProvider<AudioPlayerCoordinator>.value(
      value: _fallbackCoordinator!,
      child: const AudioPlayerView(),
    );
  }
}
