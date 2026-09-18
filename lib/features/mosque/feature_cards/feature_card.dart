import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? colorBorder;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.onTap,
    this.color,
    this.colorBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon container with Islamic colors
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: color ?? AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorBorder ?? AppColors.champagneGold,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: AppColors.champagneGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),
                  // Small circular arrow button
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
