import 'package:deenora/features/widget_prayer_times/widgets/prayer_progress_card.dart';
import 'package:deenora/features/widget_prayer_times/widgets/prayer_times_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/prayer_times_controller.dart';

class PrayerTimesScreen extends StatelessWidget {
  final PrayerTimesController? controller;

  const PrayerTimesScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<PrayerTimesController>.value(
        value: controller!,
        child: const _PrayerTimesContent(),
      );
    }
    return const _PrayerTimesContent();
  }
}

class _PrayerTimesContent extends StatelessWidget {
  const _PrayerTimesContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesController>(
      builder: (context, controller, child) {
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
