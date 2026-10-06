import 'package:flutter/material.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';
import 'package:deenora/core/widget/share_widget/icon_text_widget.dart';

/// Displays the textual information of a Muadhin (Name, Category tag, Location).
class MuadhinCardInfo extends StatelessWidget {
  final String name;
  final String category;
  final String location;

  const MuadhinCardInfo({
    super.key,
    required this.name,
    required this.category,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: AppSizes.sp15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: 4),

        // Category tag
        if (category.isNotEmpty)
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppSizes.sp12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),

        const SizedBox(height: 4),

        // Location
        if (location.isNotEmpty)
          IconTextWidget(
            icon: Icons.location_on_outlined,
            text: location,
            iconSize: 13,
            iconColor: AppColors.textMuted,
            spacing: 4,
          ),
      ],
    );
  }
}
