import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class QiblaCalibrationHint extends StatelessWidget {
  const QiblaCalibrationHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'If the compass seems inaccurate, wave your phone in a figure-eight (∞) motion to calibrate.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
