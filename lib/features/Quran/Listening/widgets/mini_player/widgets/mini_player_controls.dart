import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../audio_player/controller/audio_player_coordinator.dart';

class MiniPlayerControls extends StatelessWidget {
  const MiniPlayerControls({super.key});

  static const Color primaryColor = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    final coordinator = context.read<AudioPlayerCoordinator>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play / Pause / Loading Button
        StreamBuilder<PlayerState>(
          stream: coordinator.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            final processingState = snapshot.data?.processingState;

            final isBufferingOrLoading =
                (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) &&
                    (playing || coordinator.isLoadingSurah);

            final isLoading = coordinator.isLoadingSurah ||
                (isBufferingOrLoading &&
                    processingState != ProcessingState.completed);

            final hasError = coordinator.hasError;

            return SizedBox(
              width: 42,
              height: 42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: hasError
                        ? () => coordinator.retry()
                        : () => coordinator.togglePlayPause(playing),
                    child: Center(
                      child: isLoading
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white,
                              size: 18,
                            )
                          : hasError
                              ? const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 22,
                                )
                              : Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 4),

        // Next Button
        Selector<AudioPlayerCoordinator, bool>(
          selector: (_, c) => c.canPlayNext,
          builder: (context, canPlayNext, _) {
            return IconButton(
              iconSize: 30,
              tooltip: 'Next Surah',
              color: primaryColor,
              disabledColor: Colors.grey[350],
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: canPlayNext
                  ? () => context.read<AudioPlayerCoordinator>().playNextSurah()
                  : null,
            );
          },
        ),
      ],
    );
  }
}
