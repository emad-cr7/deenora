import 'package:flutter/material.dart';

// خيارات مؤقت النوم المتاحة لتحديد مدة إيقاف الصوت تلقائياً
enum SleepTimerOption {
  tenMin(
    minutes: 10,
    label: '10 min',
    title: '10 minutes',
    subtitle: 'Pause playback in 10 minutes',
    icon: Icons.timer_outlined,
  ),
  fifteenMin(
    minutes: 15,
    label: '15 min',
    title: '15 minutes',
    subtitle: 'Pause playback in 15 minutes',
    icon: Icons.timer_outlined,
  ),
  thirtyMin(
    minutes: 30,
    label: '30 min',
    title: '30 minutes',
    subtitle: 'Pause playback in 30 minutes',
    icon: Icons.timer_outlined,
  ),
  fortyFiveMin(
    minutes: 45,
    label: '45 min',
    title: '45 minutes',
    subtitle: 'Pause playback in 45 minutes',
    icon: Icons.timer_outlined,
  ),
  oneHour(
    minutes: 60,
    label: '1 hour',
    title: '1 hour',
    subtitle: 'Pause playback in 60 minutes',
    icon: Icons.hourglass_bottom_rounded,
  ),
  endOfSurah(
    minutes: 0,
    label: 'End of Surah',
    title: 'End of current Surah',
    subtitle: 'Pause when the current Surah finishes',
    icon: Icons.check_circle_outline_rounded,
  ),
  custom(
    minutes: 0,
    label: 'Custom',
    title: 'Custom Duration',
    subtitle: 'Set duration in minutes',
    icon: Icons.tune_rounded,
  );

  final int minutes;
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  const SleepTimerOption({
    required this.minutes,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  /// الخيارات الجاهزة المعروضة في القائمة قبل الخيار المخصص
  static List<SleepTimerOption> get presets => [
        tenMin,
        fifteenMin,
        thirtyMin,
        fortyFiveMin,
        oneHour,
        endOfSurah,
      ];
}
