import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

// شريط التقدم الزمني للتشغيل مع تسميات الوقت المنقضي والمتبقي
class PlayerProgressBar extends StatelessWidget {
  final Stream<Duration> positionStream;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  const PlayerProgressBar({
    super.key,
    required this.positionStream,
    required this.bufferedPosition,
    required this.totalDuration,
    required this.onSeek,
  });

  static const Color primaryColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;

        return ProgressBar(
          progress: position,
          buffered: bufferedPosition,
          total: totalDuration,
          progressBarColor: primaryColor,
          baseBarColor: primaryColor.withValues(alpha: 0.12),
          bufferedBarColor: primaryColor.withValues(alpha: 0.25),
          thumbColor: primaryColor,
          thumbRadius: 7,
          thumbGlowRadius: 15,
          timeLabelTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
          onSeek: onSeek,
        );
      },
    );
  }
}
