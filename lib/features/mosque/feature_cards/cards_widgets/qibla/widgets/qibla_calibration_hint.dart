import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class QiblaCalibrationHint extends StatelessWidget {
  const QiblaCalibrationHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                fontSize: 12,
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
