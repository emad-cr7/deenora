import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/share_widget/icon_text_widget.dart';

/// Shimmer skeleton widget for the Hadith of the Day loading state.
class HadithCardSkeleton extends StatelessWidget {
  const HadithCardSkeleton({super.key});

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
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconTextWidget(
              icon: Icons.menu_book_rounded,
              iconSize: 14,
              text: 'Hadith of the Day',
              spacing: 6,
            ),
            const SizedBox(height: 12),
            Text(
              '« مَنْ أَحَبَّ لِقَاءَ اللَّهِ أَحَبَّ اللَّهُ لِقَاءَهُ وَمَنْ كَرِهَ لِقَاءَ اللَّهِ كَرِهَ اللَّهُ لِقَاءَهُ »',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '— Sunan an-Nasa\'i • Hadith 1836 —',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
