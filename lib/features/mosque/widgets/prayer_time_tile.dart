import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/models.dart';

class PrayerTimeTile extends StatelessWidget {
  final PrayerTimeItem item;

  const PrayerTimeTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = item.isNext;
    final isCurrent = item.isCurrent;
    final isPassed = item.isPassed;

    // Outer card styling based on state
    BoxDecoration decoration;
    if (isNext) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.champagneGold.withValues(alpha: 0.09),
          ],
        ),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isCurrent) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isPassed ? const Color(0xFFFAFBFB) : Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    // Icon container color
    Color iconBgColor;
    Color iconColor;
    if (isNext) {
      iconBgColor = AppColors.primary;
      iconColor = Colors.white;
    } else if (isCurrent) {
      iconBgColor = AppColors.primary.withValues(alpha: 0.15);
      iconColor = AppColors.primary;
    } else if (isPassed) {
      iconBgColor = Colors.grey.withValues(alpha: 0.12);
      iconColor = const Color(0xFF71807B);
    } else {
      iconBgColor = AppColors.primary.withValues(alpha: 0.08);
      iconColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: decoration,
      child: Row(
        children: [
          // Prayer Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBgColor,
            ),
            child: Icon(
              item.type.icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),

          // Prayer Names & Status Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type.englishName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPassed
                        ? const Color(0xFF556561)
                        : const Color(0xFF163B33),
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(context),
              ],
            ),
          ),

          // Formatted 12-Hour Scheduled Time
          Text(
            item.formatted12Hour,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isNext
                  ? AppColors.primary
                  : (isPassed
                      ? const Color(0xFF71807B)
                      : const Color(0xFF163B33)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (item.isPassed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.done_all_rounded,
            size: 13,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            'Passed ${item.formattedElapsed} ago',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      );
    } else if (item.isNext) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Next Prayer',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8A6D1D),
          ),
        ),
      );
    } else if (item.isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Current Prayer',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    } else {
      return const Text(
        'Upcoming',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8A9995),
        ),
      );
    }
  }
}
