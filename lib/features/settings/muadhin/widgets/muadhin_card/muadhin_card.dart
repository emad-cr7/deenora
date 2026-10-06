import 'package:flutter/material.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_player_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'muadhin_avatar.dart';
import 'muadhin_card_action.dart';
import 'muadhin_card_info.dart';
import '../muadhin_inline_player.dart';

/// Card widget representing a single Muadhin, with an expandable inline audio player.
class MuadhinCard extends StatelessWidget {
  final MuadhinModel muadhin;
  final MuadhinType selectedType;
  final bool isExpanded;
  final bool isPlaying;
  final MuadhinPlayerController playerController;
  final VoidCallback onTap;

  const MuadhinCard({
    super.key,
    required this.muadhin,
    required this.selectedType,
    required this.isExpanded,
    required this.isPlaying,
    required this.playerController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final audio = muadhin.getAudio(selectedType);
    final isAudioAvailable = muadhin.hasAudioFor(selectedType);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary
              : AppColors.borderSubtle,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isAudioAvailable ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row: Avatar + Info + Play/Expand Indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Image with fallback
                    MuadhinAvatar(
                      imageUrl: muadhin.imageUrl,
                      isMosque: muadhin.isMosque,
                    ),

                    const SizedBox(width: 14),

                    // Sheikh Info (Name, Category, Location)
                    Expanded(
                      child: MuadhinCardInfo(
                        name: muadhin.nameAr,
                        category: muadhin.categoryAr,
                        location: muadhin.locationAr,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Play/Expand Action Button
                    ListenableBuilder(
                      listenable: playerController,
                      builder: (context, _) {
                        return MuadhinCardAction(
                          isAvailable: isAudioAvailable,
                          isExpanded: isExpanded,
                          isPlaying: playerController.isTrackPlaying(
                            muadhin.id,
                            selectedType,
                          ),
                          onTap: isAudioAvailable ? onTap : null,
                        );
                      },
                    ),
                  ],
                ),

                // Inline Player: Appears directly below the card when expanded
                if (isExpanded && isAudioAvailable)
                  MuadhinInlinePlayer(
                    playerController: playerController,
                    audioModel: audio,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
