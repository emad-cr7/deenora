import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import 'prayer_progress_card.dart';

class MosquePrayerCard extends StatelessWidget {
  final PrayerTimesController controller;
  final VoidCallback onTap;

  const MosquePrayerCard({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PrayerProgressCard(
      controller: controller,
      onTap: onTap,
    );
  }
}

