import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../features/mosque/feature_cards/feature_card.dart';
import '../../../theme/app_colors.dart';

class CardsSkeleton extends StatelessWidget {
  const CardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    color: Colors.grey.shade300,
                    color_border: Colors.grey.shade300 ,
                    title: 'Qibla',
                    description: 'Find the direction of the Kaaba',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeatureCard(
                    color: Colors.grey.shade300,
                    color_border: Colors.grey.shade300 ,
                    title: 'Tasbeeh',
                    description: 'Count your dhikr and get closer to Allah',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    color: Colors.grey.shade300,
                    color_border: Colors.grey.shade300 ,
                    title: 'Quran',
                    description: 'Read and listen to the Quran',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeatureCard(
                    color: Colors.grey.shade300,
                    color_border: Colors.grey.shade300 ,
                    title: 'Duas',
                    description: 'Daily duas and supplications',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
