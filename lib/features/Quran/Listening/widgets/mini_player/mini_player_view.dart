import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../audio_player/controller/audio_player_coordinator.dart';
import 'widgets/mini_player_avatar.dart';
import 'widgets/mini_player_controls.dart';
import 'widgets/mini_player_info.dart';
import 'widgets/mini_player_progress.dart';

class MiniPlayerView extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayerView({super.key, this.onTap});

  static const double cardHeight = 62.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.centerStart,
        children: [
          // Main Mini Player Card
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
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
                  onTap: onTap,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 70, // room for overlapping avatar
                            end: 4,
                            top: 2,
                            bottom: 2,
                          ),
                          child: const Row(
                            children: [
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

          // Overlapping Circular Avatar
          const PositionedDirectional(
            start: 12,
            top: 0,
            child: MiniPlayerAvatar(),
          ),

        ],
      ),
    );
  }
}
