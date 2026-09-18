import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../theme/app_colors.dart';

class AzkarItemSkeleton extends StatelessWidget {
  const AzkarItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(duration: Duration(milliseconds: 1200)),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.emerald.withValues(alpha: 0.07),
                    AppColors.amberGold.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald.withValues(alpha: 0.10),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "category.arabicName",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.deepTeal),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.amberGold.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: AppColors.emerald,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
