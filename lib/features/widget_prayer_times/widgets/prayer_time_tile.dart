import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/models.dart';

class PrayerTimeTile extends StatelessWidget {
  const PrayerTimeTile({super.key, required this.item});

  final PrayerTimeItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _buildDecoration(),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type.englishName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepTeal,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatus(textTheme),
              ],
            ),
          ),
          Text(
            item.formatted12Hour,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: item.isNext ? AppColors.primary : AppColors.deepTeal,
            ),
          ),
        ],
      ),
    );
  }

  // الصلاة القادمة فقط لها gradient و border و shadow مميز.
  BoxDecoration _buildDecoration() {
    if (item.isNext) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.champagneGold.withValues(alpha: 0.09),
          ],
        ),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Colors.white,
      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    final isNext = item.isNext;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isNext
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.15),
      ),
      child: Icon(
        item.type.icon,
        size: 24,
        color: isNext ? Colors.white : AppColors.primary,
      ),
    );
  }

  Widget _buildStatus(TextTheme textTheme) {
    if (item.isPassed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.done_all_rounded,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            'Passed ${item.formattedElapsed} ago',
            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      );
    }

    if (item.isNext) {
      return _StatusBadge(
        label: 'Next Prayer',
        background: AppColors.gold.withValues(alpha: 0.18),
        textColor: AppColors.darkGold,
      );
    }

    if (item.isCurrent) {
      return _StatusBadge(
        label: 'Current Prayer',
        background: AppColors.primary.withValues(alpha: 0.12),
        textColor: AppColors.primary,
      );
    }

    return Text(
      'Upcoming',
      style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}