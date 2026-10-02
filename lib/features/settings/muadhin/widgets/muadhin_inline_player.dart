import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_player_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';

/// Inline audio player displayed directly underneath the selected Muadhin card.
class MuadhinInlinePlayer extends StatelessWidget {
  final MuadhinPlayerController playerController;
  final MuadhinAudioModel audioModel;
  final String muadhinName;

  const MuadhinInlinePlayer({
    super.key,
    required this.playerController,
    required this.audioModel,
    required this.muadhinName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Audio description or reciter information
          if (audioModel.description != null &&
              audioModel.description!.trim().isNotEmpty) ...[
            Text(
              audioModel.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.sp12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Playback Error alert (if any)
          if (playerController.playbackError != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                playerController.playbackError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: AppSizes.sp12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Progress Bar with Elapsed & Total duration
          StreamBuilder<Duration>(
            stream: playerController.positionStream,
            builder: (context, posSnapshot) {
              final position = posSnapshot.data ?? Duration.zero;
              final total = playerController.duration;
              final buffered = playerController.bufferedPosition;

              return ProgressBar(
                progress: position,
                buffered: buffered,
                total: total,
                progressBarColor: AppColors.primary,
                baseBarColor: AppColors.primary.withValues(alpha: 0.12),
                bufferedBarColor: AppColors.primary.withValues(alpha: 0.22),
                thumbColor: AppColors.primary,
                thumbRadius: 6,
                thumbGlowRadius: 14,
                timeLabelTextStyle: const TextStyle(
                  fontSize: AppSizes.sp11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
                onSeek: (newPos) => playerController.seek(newPos),
              );
            },
          ),

          const SizedBox(height: 8),

          // Playback Controls Row: Rewind 10s | Play/Pause | Forward 10s
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 10s
              IconButton(
                iconSize: 26,
                tooltip: 'Rewind 10s',
                color: AppColors.primary,
                icon: const Icon(Icons.replay_10_rounded),
                onPressed: () => playerController.rewind(),
              ),

              const SizedBox(width: 14),

              // Main Play/Pause circular button
              _PlayPauseButton(playerController: playerController),

              const SizedBox(width: 14),

              // Forward 10s
              IconButton(
                iconSize: 26,
                tooltip: 'Forward 10s',
                color: AppColors.primary,
                icon: const Icon(Icons.forward_10_rounded),
                onPressed: () => playerController.forward(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final MuadhinPlayerController playerController;

  const _PlayPauseButton({required this.playerController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: StreamBuilder<PlayerState>(
        stream: playerController.playerStateStream,
        builder: (context, snapshot) {
          final isPlaying = snapshot.data?.playing ?? false;
          final state = snapshot.data?.processingState;
          final isLoading = state == ProcessingState.loading ||
              state == ProcessingState.buffering;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : IconButton(
                    iconSize: 30,
                    color: Colors.white,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        playerController.pause();
                      } else {
                        playerController.resume();
                      }
                    },
                  ),
          );
        },
      ),
    );
  }
}
