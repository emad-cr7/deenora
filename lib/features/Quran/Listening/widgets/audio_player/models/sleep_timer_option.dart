import 'package:flutter/material.dart';

enum SleepTimerOption {
  tenMin(10, '10 minutes', 'Stop playback after 10 minutes', Icons.hourglass_bottom_rounded),
  fifteenMin(15, '15 minutes', 'Stop playback after 15 minutes', Icons.hourglass_bottom_rounded),
  thirtyMin(30, '30 minutes', 'Stop playback after 30 minutes', Icons.hourglass_bottom_rounded),
  fortyFiveMin(45, '45 minutes', 'Stop playback after 45 minutes', Icons.hourglass_bottom_rounded),
  sixtyMin(60, '1 hour', 'Stop playback after 1 hour', Icons.hourglass_bottom_rounded),
  endOfSurah(0, 'End of current Surah', 'Stop at the end of this recitation', Icons.done_all_rounded),
  custom(-1, 'Custom duration', 'Choose your own duration', Icons.tune_rounded);

  final int minutes;
  final String title;
  final String subtitle;
  final IconData icon;

  const SleepTimerOption(this.minutes, this.title, this.subtitle, this.icon);

  static List<SleepTimerOption> get presets => [
    tenMin,
    fifteenMin,
    thirtyMin,
    fortyFiveMin,
    sixtyMin,
    endOfSurah,
  ];
}
