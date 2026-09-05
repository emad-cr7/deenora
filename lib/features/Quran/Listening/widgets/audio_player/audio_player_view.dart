import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'audio_player_controller.dart';

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.chapter.nameSimple),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: controller.hasError
          ? const Center(child: Text('حصل خطأ في تشغيل التلاوة، حاول تاني'))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              backgroundImage: AssetImage(controller.reciter.imagePath),
            ),
            const SizedBox(height: 20),
            Text(
              controller.chapter.nameSimple,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.reciter.name,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            StreamBuilder<Duration>(
              stream: controller.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;

                return ProgressBar(
                  progress: position,
                  buffered: controller.bufferedPosition,
                  total: controller.duration,
                  progressBarColor: primaryColor,
                  baseBarColor: primaryColor.withValues(alpha: 0.10),
                  bufferedBarColor: primaryColor.withValues(alpha: 0.2),
                  thumbColor: primaryColor,
                  onSeek: controller.seek,
                );
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<PlayerState>(
              stream: controller.playerStateStream,
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
                    onPressed: () => controller.togglePlayPause(playing),
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