import 'package:flutter/material.dart';
import '../controller/audio_player_coordinator.dart';
import 'player_controls_row.dart';
import 'player_progress_bar.dart';

// بطاقة الحاوية البيضاء لشريط التقدم وأزرار التحكم بالصوت
class MainPlayerControlsCard extends StatelessWidget {
  final AudioPlayerCoordinator coordinator;

  const MainPlayerControlsCard({
    super.key,
    required this.coordinator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط التقدم الزمني للتلاوة
          PlayerProgressBar(
            positionStream: coordinator.positionStream,
            bufferedPosition: coordinator.bufferedPosition,
            totalDuration: coordinator.duration,
            onSeek: coordinator.seek,
          ),
          const SizedBox(height: 10),

          // صف أزرار التحكم
          PlayerControlsRow(
            playerStateStream: coordinator.playerStateStream,
            isLoadingSurah: coordinator.isLoadingSurah,
            hasPrevious: coordinator.hasPrevious,
            onPreviousPressed: coordinator.canPlayPrevious
                ? () => coordinator.playPreviousSurah()
                : null,
            hasNext: coordinator.hasNext,
            onNextPressed: coordinator.canPlayNext
                ? () => coordinator.playNextSurah()
                : null,
            onRewindPressed: () => coordinator.rewind10(),
            onForwardPressed: () => coordinator.forward10(),
            onPlayPausePressed: (playing) =>
                coordinator.togglePlayPause(playing),
          ),
        ],
      ),
    );
  }
}
