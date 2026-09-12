import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../audio_player/view/audio_player_view.dart';
import 'widgets/mini_player_avatar.dart';
import 'widgets/mini_player_controls.dart';
import 'widgets/mini_player_info.dart';
import 'widgets/mini_player_progress.dart';

class MiniPlayerView extends StatelessWidget {
  const MiniPlayerView({super.key});

  static const Color primaryColor = AppColors.primary;
  static const double cardHeight = 62.0;
  static const double overlapOffset = 8.0;

  void _openFullPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AudioPlayerView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.centerStart,
      children: [
        // Main Mini Player Card Container
        Container(
          margin: const EdgeInsets.only(top: overlapOffset),
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openFullPlayer(context),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 70, // Leaves room for overlapping avatar (size 52 + 14 margin + 4 gap)
                          end: 6,
                          top: 2,
                          bottom: 2,
                        ),
                        child: Row(
                          children: const [
                            Expanded(child: MiniPlayerInfo()),
                            MiniPlayerControls(),
                          ],
                        ),
                      ),
                    ),
                    const MiniPlayerProgress(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Overlapping Circular Avatar on the left / start
        const PositionedDirectional(
          start: 12,
          top: 0,
          child: MiniPlayerAvatar(),
        ),
      ],
    );
  }
}
