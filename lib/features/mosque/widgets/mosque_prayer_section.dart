import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/skeleton/mosque/widegets/prayer_times_skeleton.dart';
import '../../widget_prayer_times/controllers/prayer_times_controller.dart';
import '../../widget_prayer_times/prayer_times_screen.dart';
import '../../widget_prayer_times/widgets/prayer_progress_card.dart';
import 'prayer_times_error_card.dart';

class MosquePrayerSection extends StatelessWidget {
  const MosquePrayerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.prayerTimes == null) {
          return const PrayerTimesSkeleton();
        }

        if (controller.hasError && controller.prayerTimes == null) {
          return PrayerTimesErrorCard(
            errorMessage: controller.errorMessage,
            onRetry: controller.loadPrayerTimes,
          );
        }

        if (controller.prayerTimes != null) {
          return PrayerProgressCard(
            controller: controller,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChangeNotifierProvider<PrayerTimesController>.value(
                        value: controller,
                        child: const PrayerTimesScreen(),
                      ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
