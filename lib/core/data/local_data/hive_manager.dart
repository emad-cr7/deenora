import 'package:hive_ce_flutter/adapters.dart';

import '../../../features/Azkar/azkar_model/azekr_category.dart';
import '../../../features/Quran/reading/models/surah_model.dart';
import '../../../features/tasbeeh/models/dhikr_model.dart';
import '../../../features/widget_prayer_times/models/prayer_times_model.dart';
import '../../../hive_registrar.g.dart';
import 'hive_config.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._();

  HiveManager._();

  factory HiveManager() {
    return _instance;
  }

  late Box<SurahModel> _quranBox;
  late Box<AzekrCategory> _azkarBox;
  late Box<DhikrModel> _tasbeehBox;
  late Box<PrayerTimesModel> _prayerTimesBox;
  late Box<DhikrModel> _defaultTasbeehBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _quranBox = await Hive.openBox<SurahModel>(HiveConfig.quranBox);
    _azkarBox = await Hive.openBox<AzekrCategory>(HiveConfig.azkarBox);
    _tasbeehBox = await Hive.openBox<DhikrModel>(HiveConfig.tasbeehBox);
    _prayerTimesBox = await Hive.openBox<PrayerTimesModel>(
      HiveConfig.prayerTimesBox,
    );
    _defaultTasbeehBox = await Hive.openBox<DhikrModel>(
      HiveConfig.defaultTasbeehBox,
    );
  }

  Future<void> saveSurahs(List<SurahModel> list) async {
    await _quranBox.clear();
    await _quranBox.addAll(list);
  }

  Future<void> saveAzkar(AzekrCategory category) async {
    await _azkarBox.clear();
    await _azkarBox.put('azkar_data', category);
  }

  List<SurahModel> loadSurahs() {
    return _quranBox.values.toList();
  }

  AzekrCategory? loadAzkar() {
    return _azkarBox.get('azkar_data');
  }

  bool get _isTasbeehBoxOpen {
    try {
      return Hive.isBoxOpen(HiveConfig.tasbeehBox);
    } catch (_) {
      return false;
    }
  }

  bool get _isPrayerTimesBoxOpen {
    try {
      return Hive.isBoxOpen(HiveConfig.prayerTimesBox);
    } catch (_) {
      return false;
    }
  }

  bool get _isDefaultTasbeehBoxOpen {
    try {
      return Hive.isBoxOpen(HiveConfig.defaultTasbeehBox);
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCustomDhikr(DhikrModel dhikr) async {
    if (!_isTasbeehBoxOpen) return;
    await _tasbeehBox.put(dhikr.id, dhikr);
  }

  List<DhikrModel> loadCustomDhikrs() {
    if (!_isTasbeehBoxOpen) return [];
    return _tasbeehBox.values.toList();
  }

  Future<void> savePrayerTimes(PrayerTimesModel model) async {
    if (!_isPrayerTimesBoxOpen) return;
    await _prayerTimesBox.put('latest_prayer_times', model);
  }

  PrayerTimesModel? loadPrayerTimes() {
    if (!_isPrayerTimesBoxOpen) return null;
    return _prayerTimesBox.get('latest_prayer_times');
  }

  Future<void> saveDefaultDhikrs(List<DhikrModel> dhikrs) async {
    if (!_isDefaultTasbeehBoxOpen) return;
    await _defaultTasbeehBox.clear();
    await _defaultTasbeehBox.addAll(dhikrs);
  }

  List<DhikrModel> loadDefaultDhikrs() {
    if (!_isDefaultTasbeehBoxOpen) return [];
    return _defaultTasbeehBox.values.toList();
  }

  Future<void> clear() async {
    try {
      if (Hive.isBoxOpen(HiveConfig.quranBox)) await _quranBox.clear();
    } catch (_) {}
    try {
      if (Hive.isBoxOpen(HiveConfig.azkarBox)) await _azkarBox.clear();
    } catch (_) {}
    if (_isTasbeehBoxOpen) await _tasbeehBox.clear();
    if (_isPrayerTimesBoxOpen) await _prayerTimesBox.clear();
    if (_isDefaultTasbeehBoxOpen) await _defaultTasbeehBox.clear();
  }
}
