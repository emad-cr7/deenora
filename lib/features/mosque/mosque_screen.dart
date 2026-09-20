import 'package:deenora/features/mosque/verse_of_the_day/widgets/verse_day_card.dart';
import 'package:deenora/features/mosque/widgets/mosque_prayer_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget_prayer_times/controllers/prayer_times_controller.dart';
import '../widget_prayer_times/widgets/location_banner.dart';
import 'feature_cards/feature_cards_section.dart';

class MosqueScreen extends StatelessWidget {
  const MosqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerTimesController>(
      create: (_) => PrayerTimesController()..init(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mosque')),
        body:  RefreshIndicator(
          onRefresh: () => context.read<PrayerTimesController>().loadPrayerTimes(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 5),
            children: [
              Consumer<PrayerTimesController>(
                builder: (context, controller, _) =>
                    LocationBanner(controller: controller),
              ),
              const MosquePrayerSection(),
              const FeatureCardsSection(),
              const VerseDayCard(),
            ],
          ),
        )
      ),
    );
  }
}
