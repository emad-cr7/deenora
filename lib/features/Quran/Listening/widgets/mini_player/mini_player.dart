import 'package:flutter/material.dart';
import 'package:flutter_miniplayer/flutter_miniplayer.dart';
import 'package:provider/provider.dart';
import '../audio_player/controller/audio_player_coordinator.dart';
import '../audio_player/view/audio_player_view.dart';
import 'mini_player_view.dart';
export 'mini_player_view.dart';
export 'widgets/mini_player_avatar.dart';
export 'widgets/mini_player_controls.dart';
export 'widgets/mini_player_info.dart';
export 'widgets/mini_player_progress.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  static const double _height = 72.0;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerCoordinator, bool>(
      selector: (_, coordinator) => coordinator.hasActiveSession,
      builder: (context, hasActiveSession, _) {
        if (!hasActiveSession) return const SizedBox.shrink();

        return Miniplayer(
          minHeight: _height,
          maxHeight: _height,
          // ignore: deprecated_member_use
          onDismiss: () =>
              context.read<AudioPlayerCoordinator>().stopAndClearSession(),
          builder: (height, percentage) {
            return MiniPlayerView(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioPlayerView()),
              ),
            );
          },
        );
      },
    );
  }
}
