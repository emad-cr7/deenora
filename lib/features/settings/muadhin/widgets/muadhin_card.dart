import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';
import 'package:deenora/core/widget/share_widget/icon_text_widget.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_player_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'muadhin_inline_player.dart';

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
                    _MuadhinAvatar(
                      imageUrl: muadhin.imageUrl,
                      isMosque: muadhin.isMosque,
                    ),

                    const SizedBox(width: 14),

                    // Sheikh Info (Name, Category, Location)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            muadhin.nameAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: AppSizes.sp15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                          ),
                          const SizedBox(height: 4),

                          // Category tag
                          if (muadhin.categoryAr.isNotEmpty)
                            Text(
                              muadhin.categoryAr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppSizes.sp12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),

                          const SizedBox(height: 4),

                          // Location
                          if (muadhin.locationAr.isNotEmpty)
                            IconTextWidget(
                              icon: Icons.location_on_outlined,
                              text: muadhin.locationAr,
                              iconSize: 13,
                              iconColor: AppColors.textMuted,
                              spacing: 4,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Play/Expand Action Button
                    _TrailingActionButton(
                      isAvailable: isAudioAvailable,
                      isExpanded: isExpanded,
                      isPlaying: isPlaying,
                      onTap: isAudioAvailable ? onTap : null,
                    ),
                  ],
                ),

                // Inline Player: Appears directly below the card when expanded
                if (isExpanded && isAudioAvailable)
                  MuadhinInlinePlayer(
                    playerController: playerController,
                    audioModel: audio,
                    muadhinName: muadhin.nameAr,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MuadhinAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isMosque;

  const _MuadhinAvatar({
    required this.imageUrl,
    required this.isMosque,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _FallbackAvatar(isMosque: isMosque),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFF1F5F3),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              )
            : _FallbackAvatar(isMosque: isMosque),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final bool isMosque;

  const _FallbackAvatar({required this.isMosque});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EFEA),
      child: Icon(
        isMosque ? FlutterIslamicIcons.solidMosque : FlutterIslamicIcons.solidMuslim,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}

class _TrailingActionButton extends StatelessWidget {
  final bool isAvailable;
  final bool isExpanded;
  final bool isPlaying;
  final VoidCallback? onTap;

  const _TrailingActionButton({
    required this.isAvailable,
    required this.isExpanded,
    required this.isPlaying,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Unavailable',
          style: TextStyle(
            fontSize: AppSizes.sp11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.primary
            : (isExpanded
                ? AppColors.primary.withValues(alpha: 0.12)
                : const Color(0xFFF1F5F3)),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPlaying
            ? Icons.pause_rounded
            : (isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.play_arrow_rounded),
        color: isPlaying
            ? Colors.white
            : (isExpanded ? AppColors.primary : AppColors.textDark),
        size: 24,
      ),
    );
  }
}
