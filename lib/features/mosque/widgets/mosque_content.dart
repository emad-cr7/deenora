import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget_prayer_times/controllers/prayer_times_controller.dart';
import '../../widget_prayer_times/widgets/location_banner.dart';
import '../feature_cards/feature_cards_section.dart';
import '../verse_of_the_day/widgets/verse_of_the_day_card.dart';
import 'mosque_prayer_section.dart';

class MosqueContent extends StatelessWidget {
  const MosqueContent({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
          const VerseOfTheDayCard(),
        ],
      ),
    );
  }
}
