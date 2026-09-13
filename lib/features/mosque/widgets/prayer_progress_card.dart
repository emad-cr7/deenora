import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/prayer_times_controller.dart';
import '../models/models.dart';

/// Reusable compact two-column prayer card showing the previous (started)
/// prayer on the left and the next (upcoming) prayer on the right, separated
/// by a vertical divider line.
///
/// Under the previous prayer: Passed HH:mm:ss (increases every second).
/// Under the next prayer: Remaining HH:mm:ss (decreases every second).
///
/// Uses [ValueListenableBuilder] listening directly to [controller.countdownNotifier]
/// to ensure only this card rebuilds every second without rebuilding parent screens
/// or the prayer list.
class PrayerProgressCard extends StatelessWidget {
  final PrayerTimesController controller;
  final VoidCallback? onTap;

  const PrayerProgressCard({
    super.key,
    required this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NextPrayerCountdown?>(
      valueListenable: controller.countdownNotifier,
      builder: (context, countdown, _) {
        if (countdown == null) {
          return const SizedBox.shrink();
        }

        final cardContent = Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            boxShadow: [
              BoxShadow(
                color: AppColors.deepForest.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Previous / Currently Completed Prayer
              Expanded(
                child: _buildPrayerColumn(
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
                height: 84,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: Colors.white.withValues(alpha: 0.20),
              ),

              // Right Column: Next Upcoming Prayer
              Expanded(
                child: _buildPrayerColumn(
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

  Widget _buildPrayerColumn({
    required String label,
    required Color labelColor,
    required String prayerName,
    required IconData prayerIcon,
    required String scheduledTime,
    required String relativeTimeLabel,
    required IconData relativeIcon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Label (PREVIOUS / UPCOMING)
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),

        // Prayer Icon & Name Row
        Row(
          children: [
            Icon(
              prayerIcon,
              size: 20,
              color: AppColors.champagneGold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),

        // Scheduled 12-hour Time
        Text(
          scheduledTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.champagneGold,
          ),
        ),
        const SizedBox(height: 10),

        // Live Relative-time Badge (Passed HH:mm:ss / Remaining HH:mm:ss)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                relativeIcon,
                size: 13,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    relativeTimeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
