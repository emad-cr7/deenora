import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'audio_player_controller.dart';

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: Text(controller.surah.englishName),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: controller.hasError
          ? const Center(child: Text('حصل خطأ في تشغيل التلاوة، حاول تاني'))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 95,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                backgroundImage: AssetImage(controller.reciter.imagePath),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.surah.englishName,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  StreamBuilder<Duration>(
                    stream: controller.positionStream,
                    builder: (context, positionSnapshot) {
                      final position =
                          positionSnapshot.data ?? Duration.zero;

                      return ProgressBar(
                        progress: position,
                        buffered: controller.bufferedPosition,
                        total: controller.duration,
                        progressBarColor: primaryColor,
                        baseBarColor:
                        primaryColor.withValues(alpha: 0.10),
                        bufferedBarColor:
                        primaryColor.withValues(alpha: 0.2),
                        thumbColor: primaryColor,
                        onSeek: controller.seek,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: StreamBuilder<PlayerState>(
                      stream: controller.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        final processingState =
                            snapshot.data?.processingState;

                        final isLoading = processingState ==
                            ProcessingState.loading ||
                            processingState ==
                                ProcessingState.buffering;

                        return Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                primaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? Center(
                            child: LoadingAnimationWidget
                                .staggeredDotsWave(
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                              : IconButton(
                            iconSize: 32,
                            color: Colors.white,
                            icon: Icon(
                              playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () => controller
                                .togglePlayPause(playing),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}