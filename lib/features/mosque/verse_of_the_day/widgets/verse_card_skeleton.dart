import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/widget/share_widget/icon_text_widget.dart';

/// Shimmer skeleton widget for the Verse of the Day loading state.
class VerseCardSkeleton extends StatelessWidget {
  const VerseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5EBE7), width: 1),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTextWidget(
              icon: Icons.auto_awesome,
              iconSize: 14,
              text: 'Ayah of the Day',
              spacing: 6,
            ),
            SizedBox(height: 12),
            Text(
              '﴿ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text('— سورة الشرح • Ayah 5 —', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
