import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:deenora/core/theme/app_colors.dart';

class MuadhinSkeleton extends StatelessWidget {
  const MuadhinSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(duration: Duration(milliseconds: 1200)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                // Circular avatar placeholder
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
          
                // Name and info placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(width: 8),
          
                // Action button placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
