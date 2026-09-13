import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widget/share_widget/build_prayer_share.dart';
import '../controllers/prayer_times_controller.dart';
import '../models/models.dart';

class PrayerProgressCard extends StatelessWidget {
  final PrayerTimesController controller;
  final VoidCallback? onTap;

  const PrayerProgressCard({super.key, required this.controller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NextPrayerCountdown?>(
      valueListenable: controller.countdownNotifier,
      builder: (context, countdown, _) {
        if (countdown == null) {
          return const SizedBox.shrink();
        }

        final cardContent = Container(
          width: 5,
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
                  prayerName: countdown.previousPrayer.englishName,
                  prayerIcon: countdown.previousPrayer.icon,
                  scheduledTime: countdown.formattedPreviousPrayerTime,
                  relativeTimeLabel: countdown.formattedPassed,
                  relativeIcon: Icons.history_rounded,
                  iconColor: Colors.white70,
                ),
              ),

              // Vertical Divider Line between the two sections
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
                  prayerName: countdown.nextPrayer.englishName,
                  prayerIcon: countdown.nextPrayer.icon,
                  scheduledTime: countdown.formattedNextPrayerTime,
                  relativeTimeLabel: countdown.formattedRemaining,
                  relativeIcon: Icons.timer_outlined,
                  iconColor: AppColors.champagneGold,
                ),
              ),
            ],
          ),
        );

        if (onTap != null) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: cardContent,
            ),
          );
        }
        return cardContent;
      },
    );
  }
}
