import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widget/error/error_screen.dart';
import 'controllers/prayer_times_controller.dart';
import 'prayer_times_screen.dart';
import 'widgets/location_banner.dart';
import 'widgets/prayer_progress_card.dart';
import 'widgets/prayer_times_skeleton.dart';

class MosqueScreen extends StatelessWidget {
  const MosqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerTimesController>(
      create: (_) => PrayerTimesController()..init(),
      child: const _MosqueScreenContent(),
    );
  }
}

class _MosqueScreenContent extends StatelessWidget {
  const _MosqueScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mosque'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: controller.isLoading
                    ? null
                    : () => controller.loadPrayerTimes(),
              ),
            ],
          ),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PrayerTimesController controller) {
    // 1. Initial Loading State
    if (controller.isLoading && controller.prayerTimes == null) {
      return const PrayerTimesSkeleton();
    }

    // 2. Error State (Network or service failure when no cached/loaded data exists)
    if (controller.hasError && controller.prayerTimes == null) {
      return AppErrorScreen(
        type: AppErrorType.serverError,
        onRetry: () => controller.loadPrayerTimes(),
      );
    }

    // 3. Loaded Data State with Pull-To-Refresh
    return RefreshIndicator(
      onRefresh: () => controller.loadPrayerTimes(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Location status banner (if fallback location is currently active)
          LocationBanner(controller: controller),

          // Compact two-column prayer progress card (Previous Prayer | Next Prayer)
          // Tapping this card navigates to the dedicated PrayerTimesScreen showing all 6 prayers
          PrayerProgressCard(
            controller: controller,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrayerTimesScreen(controller: controller),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
