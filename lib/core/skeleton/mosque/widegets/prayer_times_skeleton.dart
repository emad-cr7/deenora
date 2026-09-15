import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../theme/app_colors.dart';
import '../../../widget/share_widget/build_prayer_share.dart';

class PrayerTimesSkeleton extends StatelessWidget {
  const PrayerTimesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.deepForest,
        highlightColor: Colors.white,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.deepForest,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepForest.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: BuildPrayerShare(
                label: 'PREVIOUS',
                labelColor: Colors.white60,
                prayerName: 'Prayer Name',
                prayerIcon: Icons.mosque,
                scheduledTime: '00:00 AM',
                relativeTimeLabel: '00 min ago',
                relativeIcon: Icons.history_rounded,
                iconColor: Colors.white70,
              ),
            ),
            Container(
              width: 1,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.white.withValues(alpha: 0.20),
            ),
            Expanded(
              child: BuildPrayerShare(
                label: 'UPCOMING',
                labelColor: AppColors.champagneGold,
                prayerName: 'Prayer Name',
                prayerIcon: Icons.mosque,
                scheduledTime: '00:00 AM',
                relativeTimeLabel: '00 min left',
                relativeIcon: Icons.timer_outlined,
                iconColor: AppColors.champagneGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
