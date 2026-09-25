import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Compact error widget with a retry button for daily cards (Ayah / Hadith).
class VerseCardError extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  final Color color;

  const VerseCardError({
    super.key,
    required this.onRetry,
    this.message = 'Unable to load daily ayah',
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Retry',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
