import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../audio_player/controller/audio_player_coordinator.dart';

class MiniPlayerProgress extends StatelessWidget {
  const MiniPlayerProgress({super.key});

  static const Color primaryColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final coordinator = context.read<AudioPlayerCoordinator>();

    return StreamBuilder<Duration>(
      stream: coordinator.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final totalDuration = coordinator.duration;
        final bufferedPosition = coordinator.bufferedPosition;

        return SizedBox(
          height: 2.5,
          child: ProgressBar(
            progress: position,
            buffered: bufferedPosition,
            total: totalDuration,
            progressBarColor: primaryColor,
            baseBarColor: primaryColor.withValues(alpha: 0.12),
            bufferedBarColor: primaryColor.withValues(alpha: 0.25),
            thumbRadius: 0,
            thumbGlowRadius: 0,
            barHeight: 2.5,
            timeLabelLocation: TimeLabelLocation.none,
            onSeek: (targetPosition) => coordinator.seek(targetPosition),
          ),
        );
      },
    );
  }
}
