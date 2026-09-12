import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../audio_player/controller/audio_player_coordinator.dart';

class MiniPlayerInfo extends StatelessWidget {
  const MiniPlayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerCoordinator, ({String surahName, String reciterName})>(
      selector: (_, coordinator) => (
        surahName: coordinator.currentSurah.englishName,
        reciterName: coordinator.reciter.name,
      ),
      builder: (context, data, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.surahName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.reciterName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF71807B),
              ),
            ),
          ],
        );
      },
    );
  }
}
