import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio_player/controller/audio_player_coordinator.dart';
import 'mini_player_view.dart';

export 'mini_player_view.dart';
export 'widgets/mini_player_avatar.dart';
export 'widgets/mini_player_controls.dart';
export 'widgets/mini_player_info.dart';
export 'widgets/mini_player_progress.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerCoordinator, bool>(
      selector: (_, coordinator) => coordinator.hasActiveSession,
      builder: (context, hasActiveSession, child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: hasActiveSession
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: MiniPlayerView(),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
