import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/dhikr_model.dart';

class DhikrListTile extends StatelessWidget {
  final DhikrModel dhikr;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DhikrListTile({
    super.key,
    required this.dhikr,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = dhikr.isCustom;
    final hasNarrated = dhikr.narratedCount != null;
    final String countText = isCustom
        ? '${dhikr.customGoal ?? ''}'
        : (hasNarrated ? '${dhikr.narratedCount}' : '—');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFEDF2EE),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                dhikr.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),
            isSelected
                ? const Icon(
                    Icons.check_circle_rounded,
                    size: 25,
                    color: AppColors.primary,
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCustom
                          ? const Color(0xFFE8F4F8)
                          : (hasNarrated
                                ? AppColors.champagneGold.withValues(
                                    alpha: 0.30,
                                  )
                                : const Color(0xFFEFF2F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isCustom
                            ? AppColors.badgeBlue
                            : (hasNarrated
                                  ? AppColors.darkGold
                                  : AppColors.textMuted),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
