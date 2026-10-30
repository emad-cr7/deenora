import 'package:flutter/foundation.dart';

import '../../../core/data/local_data/hive_manager.dart';
import '../../widget_prayer_times/models/prayer_type.dart';

class IqamaSettingsController extends ChangeNotifier {
  final HiveManager hiveManager;
  late IqamaSettings savedSettings;
  late bool enabled;
  late final Map<PrayerType, String> delays;
  bool isSaving = false;
  String? errorMessage;
  bool disposed = false;

  IqamaSettingsController({HiveManager? hiveManager})
    : hiveManager = hiveManager ?? HiveManager() {
    savedSettings = IqamaSettings.fromStorage(
      this.hiveManager.loadIqamaSettings(),
    );
    enabled = savedSettings.enabled;
    delays = {
      for (final entry in savedSettings.delays.entries)
        entry.key: entry.value.toString(),
    };
  }

  void setEnabled(bool value) {
    if (isSaving || enabled == value) return;
    enabled = value;
    notifyListeners();
  }

  void setDelay(PrayerType prayer, String value) {
    if (isSaving || !delays.containsKey(prayer) || delays[prayer] == value) {
      return;
    }
    delays[prayer] = value;
    notifyListeners();
  }

  String? validateDelay(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');
    return minutes != null && IqamaSettings.isValidDelay(minutes)
        ? null
        : 'Enter a whole number from 0 to 180';
  }

  Future<bool> save() async {
    if (isSaving) return false;
    if (delays.values.any((value) => validateDelay(value) != null)) {
      errorMessage = 'Enter a whole number from 0 to 180';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    final newSettings = IqamaSettings(
      enabled: enabled,
      delays: {
        for (final entry in delays.entries)
          entry.key: int.parse(entry.value.trim()),
      },
    );
    if (savedSettings.enabled == newSettings.enabled &&
        mapEquals(savedSettings.delays, newSettings.delays)) {
      notifyListeners();
      return true;
    }
    isSaving = true;
    notifyListeners();
    try {
      await hiveManager.saveIqamaSettings(newSettings.toStorage());
      savedSettings = newSettings;
      return true;
    } catch (_) {
      errorMessage = 'Could not save Iqama settings. Please try again.';
      return false;
    } finally {
      isSaving = false;
      if (!disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class IqamaSettings {
  static const defaultDelays = {
    PrayerType.fajr: 20,
    PrayerType.dhuhr: 15,
    PrayerType.asr: 15,
    PrayerType.maghrib: 5,
    PrayerType.isha: 15,
  };
  static const maxDelayMinutes = 180;

  final bool enabled;
  final Map<PrayerType, int> delays;

  IqamaSettings({this.enabled = false, Map<PrayerType, int> delays = const {}})
    : delays = Map.unmodifiable({...defaultDelays, ...delays}) {
    if (delays.entries.any(
      (entry) => !entry.key.isFardPrayer || !isValidDelay(entry.value),
    )) {
      throw ArgumentError('Iqama delays must be between 0 and 180 minutes.');
    }
  }

  static bool isValidDelay(int minutes) =>
      minutes >= 0 && minutes <= maxDelayMinutes;

  factory IqamaSettings.fromStorage(Object? raw) {
    if (raw is! Map) return IqamaSettings();

    final delays = Map<PrayerType, int>.of(defaultDelays);
    final storedDelays = raw['delays'];
    if (storedDelays is Map) {
      for (final prayer in delays.keys) {
        final minutes = storedDelays[prayer.name];
        if (minutes is int && isValidDelay(minutes)) {
          delays[prayer] = minutes;
        }
      }
    }
    return IqamaSettings(enabled: raw['enabled'] == true, delays: delays);
  }

  Map<String, dynamic> toStorage() => {
    'enabled': enabled,
    'delays': {for (final entry in delays.entries) entry.key.name: entry.value},
  };
}
