import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/models.dart';
import 'prayer_time_tile.dart';

class PrayerTimesList extends StatelessWidget {
  final List<PrayerTimeItem> items;

  const PrayerTimesList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prayer Schedule',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.deepTeal),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${items.length} Timings',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // List of Prayer Tiles
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return PrayerTimeTile(item: item);
          },
        ),
      ],
    );
  }
}
