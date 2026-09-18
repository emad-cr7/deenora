import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CounterDisplay extends StatelessWidget {
  final int count;
  final int? targetCount;
  final bool hasTarget;
  final bool isCompleted;
  final double progress;
  final VoidCallback? onSetTargetTap;

  const CounterDisplay({
    super.key,
    required this.count,
    required this.targetCount,
    required this.hasTarget,
    required this.isCompleted,
    required this.progress,
    this.onSetTargetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Completed State Banner
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isCompleted
              ? Container(
                  key: const ValueKey('completed-badge'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.shade600,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target Reached · Masha\'Allah',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 28),
        ),
        const SizedBox(height: 8),

        // Main Counter Numbers Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                '$count',
                key: ValueKey<int>(count),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.deepForest,
                  height: 1.0,
                ),
              ),
            ),
            if (hasTarget) ...[
              const SizedBox(width: 6),
              Text(
                '/ $targetCount',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepForest.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ),

        // Progress indicator & percent
        if (hasTarget) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 140,
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.deepForest.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.gold : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toInt()}% completed',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isCompleted ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFEF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.all_inclusive_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Open Counter',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
