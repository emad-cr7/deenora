import 'package:deenora/features/widget_prayer_times/widgets/prayer_progress_card.dart';
import 'package:deenora/features/widget_prayer_times/widgets/prayer_times_list.dart';
import 'package:flutter/material.dart';

import 'controllers/prayer_times_controller.dart';


class PrayerTimesScreen extends StatelessWidget {
  final PrayerTimesController controller;

  const PrayerTimesScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Prayer Times'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Prayer Times',
                onPressed: controller.isLoading
                    ? null
                    : () => controller.loadPrayerTimes(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => controller.loadPrayerTimes(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Top compact two-column prayer progress card (shared with MosqueScreen)
                PrayerProgressCard(controller: controller),

                const SizedBox(height: 6),

                // Dedicated schedule list showing all 6 prayers
                PrayerTimesList(items: controller.prayerItems),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
