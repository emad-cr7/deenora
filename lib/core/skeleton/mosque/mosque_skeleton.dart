import 'package:deenora/core/skeleton/mosque/widegets/cards_skeleton.dart';
import 'package:deenora/core/skeleton/mosque/widegets/prayer_times_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../features/mosque/feature_cards/feature_cards_section.dart';
import '../../theme/app_colors.dart';

class MosqueSkeleton extends StatelessWidget {
  const MosqueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5),
        PrayerTimesSkeleton(),
        CardsSkeleton(),
      ],
    );
  }
}
