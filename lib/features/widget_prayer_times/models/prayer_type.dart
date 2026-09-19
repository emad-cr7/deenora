import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'prayer_type.g.dart';

@HiveType(typeId: 5)
enum PrayerType {
  @HiveField(0)
  fajr,
  @HiveField(1)
  sunrise,
  @HiveField(2)
  dhuhr,
  @HiveField(3)
  asr,
  @HiveField(4)
  maghrib,
  @HiveField(5)
  isha;

  String get englishName {
    switch (this) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.dhuhr:
        return 'Dhuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
    }
  }

  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerType.fajr:
        return FlutterIslamicIcons.solidPrayingPerson;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return FlutterIslamicIcons.solidMosque;
      case PrayerType.asr:
        return FlutterIslamicIcons.solidMinaret;
      case PrayerType.maghrib:
        return FlutterIslamicIcons.solidCrescentMoon;
      case PrayerType.isha:
        return FlutterIslamicIcons.solidPrayer;
    }
  }

  /// Whether this is one of the 5 mandatory prayers (Sunrise is not an obligatory prayer).
  bool get isFardPrayer => this != PrayerType.sunrise;

  /// The prayer immediately preceding this prayer in the daily cycle.
  PrayerType get previousPrayer {
    switch (this) {
      case PrayerType.fajr:
        return PrayerType.isha;
      case PrayerType.sunrise:
        return PrayerType.fajr;
      case PrayerType.dhuhr:
        return PrayerType.sunrise;
      case PrayerType.asr:
        return PrayerType.dhuhr;
      case PrayerType.maghrib:
        return PrayerType.asr;
      case PrayerType.isha:
        return PrayerType.maghrib;
    }
  }
}
