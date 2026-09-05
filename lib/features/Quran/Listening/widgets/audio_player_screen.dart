import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models_listening/name_surah_model.dart';

class AudioPlayerScreen extends StatefulWidget {
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
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  static const Color primaryColor = Color(0xFF1B5E4F);

  final AudioPlayer _player = AudioPlayer();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.audioUrl),
          tag: MediaItem(
            id: widget.audioUrl,
            title: widget.chapter.nameSimple,
            artist: widget.reciter.name,
          ),
        ),
      );
      _player.play();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.nameSimple),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _hasError
          ? const Center(child: Text('حصل خطأ في تشغيل التلاوة، حاول تاني'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    backgroundImage: AssetImage(widget.reciter.imagePath),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.chapter.nameSimple,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.reciter.name,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final duration = _player.duration ?? Duration.zero;
                      final buffered = _player.bufferedPosition;

                      return ProgressBar(
                        progress: position,
                        buffered: buffered,
                        total: duration,
                        progressBarColor: primaryColor,
                        baseBarColor: primaryColor.withValues(alpha: 0.15),
                        bufferedBarColor: primaryColor.withValues(alpha: 0.3),
                        thumbColor: primaryColor,
                        onSeek: (newPosition) {
                          _player.seek(newPosition);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      final processingState = snapshot.data?.processingState;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const CircularProgressIndicator(
                          color: primaryColor,
                        );
                      }

                      return Container(
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 40,
                          color: Colors.white,
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (playing) {
                              _player.pause();
                            } else {
                              _player.play();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
