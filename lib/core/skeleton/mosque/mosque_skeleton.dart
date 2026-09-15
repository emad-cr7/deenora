import 'package:deenora/core/skeleton/mosque/widegets/prayer_times_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../theme/app_colors.dart';

class MosqueSkeleton extends StatelessWidget {
  const MosqueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.deepForest,
        highlightColor: AppColors.champagneGold.withValues(alpha: 0.4),
        duration: const Duration(milliseconds: 1200),
      ),
      child: Column(children: [PrayerTimesSkeleton()]),
    );
  }
}
