import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import 'prayer_progress_card.dart';

class NextPrayerCountdownCard extends StatelessWidget {
  final PrayerTimesController controller;

  const NextPrayerCountdownCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PrayerProgressCard(controller: controller);
  }
}
