import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade600, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Target Reached · Masha\'Allah',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 28),
        ),

        // Main Numerical Count
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                '$count',
                key: ValueKey<int>(count),
                style: const TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepForest,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),
            if (hasTarget) ...[
              const SizedBox(width: 6),
              Text(
                '/ $targetCount',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepForest.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // Progress Bar or Open-Counter indicator
        if (hasTarget) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE0E8E4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.gold : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toInt()}% completed',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isCompleted ? AppColors.gold : const Color(0xFF71807B),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFEF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.all_inclusive_rounded,
                  size: 14,
                  color: Color(0xFF556861),
                ),
                SizedBox(width: 6),
                Text(
                  'Open Counter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF556861),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
