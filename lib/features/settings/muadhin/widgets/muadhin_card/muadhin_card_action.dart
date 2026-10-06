import 'package:flutter/material.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';

/// Trailing action button on a Muadhin card (Unavailable badge or Play/Pause/Expand circle button).
class MuadhinCardAction extends StatelessWidget {
  final bool isAvailable;
  final bool isExpanded;
  final bool isPlaying;
  final VoidCallback? onTap;

  const MuadhinCardAction({
    super.key,
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
            : (isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.play_arrow_rounded),
        color: isPlaying
            ? Colors.white
            : (isExpanded ? AppColors.primary : AppColors.textDark),
        size: 24,
      ),
    );
  }
}
