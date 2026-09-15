import 'package:deenora/features/mosque/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:deenora/features/mosque/widget_prayer_times/prayer_times_screen.dart';
import 'package:deenora/features/mosque/widget_prayer_times/widgets/location_banner.dart';
import 'package:deenora/features/mosque/widget_prayer_times/widgets/prayer_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feature_cards/widgets/feature_cards_section.dart';
import '../../core/skeleton/mosque/mosque_skeleton.dart';
import '../../core/widget/error/error_screen.dart';


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
          ),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PrayerTimesController controller) {
    // 1. Initial Loading State
    if (controller.isLoading && controller.prayerTimes == null) {
      return const MosqueSkeleton();
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
        padding: const EdgeInsets.symmetric(vertical: 5),
        children: [
          LocationBanner(controller: controller),
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
          const FeatureCardsSection(),
        ],
      ),
    );
  }
}
