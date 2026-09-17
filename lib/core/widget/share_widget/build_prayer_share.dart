import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BuildPrayerShare extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String prayerName;
  final IconData prayerIcon;
  final String scheduledTime;
  final String relativeTimeLabel;
  final IconData relativeIcon;
  final Color iconColor;

  const BuildPrayerShare({
    super.key,
    required this.label,
    required this.labelColor,
    required this.prayerName,
    required this.prayerIcon,
    required this.scheduledTime,
    required this.relativeTimeLabel,
    required this.relativeIcon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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

        Row(
          children: [
            Icon(prayerIcon, size: 20, color: AppColors.champagneGold),
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

        Text(
          scheduledTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.champagneGold,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(relativeIcon, size: 13, color: iconColor),
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
