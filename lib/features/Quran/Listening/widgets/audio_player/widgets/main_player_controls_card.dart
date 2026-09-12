import 'package:flutter/material.dart';
import '../audio_player_controller.dart';
import 'player_controls_row.dart';
import 'player_progress_bar.dart';

// بطاقة الحاوية البيضاء لشريط التقدم وأزرار التحكم بالصوت
class MainPlayerControlsCard extends StatelessWidget {
  final AudioPlayerController controller;

  const MainPlayerControlsCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط التقدم الزمني للتلاوة
          PlayerProgressBar(
            positionStream: controller.positionStream,
            bufferedPosition: controller.bufferedPosition,
            totalDuration: controller.duration,
            onSeek: controller.seek,
          ),
          const SizedBox(height: 14),

          // صف أزرار التحكم
          PlayerControlsRow(
            playerStateStream: controller.playerStateStream,
            isLoadingSurah: controller.isLoadingSurah,
            hasPrevious: controller.hasPrevious,
            onPreviousPressed:
                controller.hasPrevious && !controller.isLoadingSurah
                    ? () => controller.playPreviousSurah()
                    : null,
            hasNext: controller.hasNext,
            onNextPressed: controller.hasNext && !controller.isLoadingSurah
                ? () => controller.playNextSurah()
                : null,
            onRewindPressed: () => controller.rewind10(),
            onForwardPressed: () => controller.forward10(),
            onPlayPausePressed: (playing) =>
                controller.togglePlayPause(playing),
          ),
        ],
      ),
    );
  }
}
