import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dhikr_model.dart';

class DhikrCard extends StatelessWidget {
  final DhikrModel dhikr;
  final int currentIndex;
  final int totalCount;
  final int? customTarget;
  final bool isCustom;

  const DhikrCard({
    super.key,
    required this.dhikr,
    required this.currentIndex,
    required this.totalCount,
    this.customTarget,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasNarrated = dhikr.narratedCount != null;
    final hasCustomGoal = isCustom || customTarget != null;
    final goalNumber = customTarget;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.deepForest,
          ],
        ),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Index indicator and Target Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Index counter pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentIndex + 1} / $totalCount',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Target pill badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasNarrated
                        ? AppColors.champagneGold.withValues(alpha: 0.2)
                        : (hasCustomGoal
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasNarrated
                          ? AppColors.champagneGold.withValues(alpha: 0.6)
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasNarrated
                            ? Icons.auto_stories_rounded
                            : (hasCustomGoal
                                  ? Icons.edit_note_rounded
                                  : Icons.all_inclusive_rounded),
                        size: 13,
                        color: hasNarrated
                            ? AppColors.champagneGold
                            : Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          hasNarrated
                              ? 'Narrated: ${dhikr.narratedCount}'
                              : (hasCustomGoal
                                    ? 'Personal Goal: $goalNumber'
                                    : 'No Narrated Count'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: hasNarrated
                                    ? AppColors.champagneGold
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              dhikr.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Bottom row: personal dhikr indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isCustom)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Personal Dhikr',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
