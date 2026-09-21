import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../widget_prayer_times/controllers/prayer_times_controller.dart';
import '../widget_prayer_times/widgets/location_banner.dart';
import 'feature_cards/feature_cards_section.dart';
import 'verse_of_the_day/controllers/verse_day_controller.dart';
import 'verse_of_the_day/widgets/verse_day_card.dart';
import 'widgets/mosque_prayer_section.dart';

class MosqueScreen extends StatelessWidget {
  final PrayerTimesController? controller;
  final VerseDayController? verseDayController;

  const MosqueScreen({
    super.key,
    this.controller,
    this.verseDayController,
  });

  @override
  Widget build(BuildContext context) {
    final existingPrayerController =
        controller ?? Provider.of<PrayerTimesController?>(context, listen: false);
    final existingVerseController =
        verseDayController ?? Provider.of<VerseDayController?>(context, listen: false);

    final providers = <SingleChildWidget>[
      if (existingPrayerController == null)
        ChangeNotifierProvider<PrayerTimesController>(
          create: (_) => PrayerTimesController()..init(),
        )
      else if (controller != null)
        ChangeNotifierProvider<PrayerTimesController>.value(
          value: controller!,
        ),
      if (existingVerseController == null)
        ChangeNotifierProvider<VerseDayController>(
          create: (_) => VerseDayController()..init(),
        )
      else if (verseDayController != null)
        ChangeNotifierProvider<VerseDayController>.value(
          value: verseDayController!,
        ),
    ];

    Widget content = const _MosqueScreenContent();

    if (providers.isNotEmpty) {
      content = MultiProvider(
        providers: providers,
        child: content,
      );
    }

    return content;
  }
}

class _MosqueScreenContent extends StatelessWidget {
  const _MosqueScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mosque')),
      body: RefreshIndicator(
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
      ),
    );
  }
}
