import 'package:hive_ce_flutter/adapters.dart';

import '../../../features/Azkar/azkar_model/azekr_category.dart';
import '../../../features/Quran/reading/models/surah_model.dart';
import '../../../features/tasbeeh/models/dhikr_model.dart';
import '../../../features/widget_prayer_times/models/prayer_times_model.dart';
import '../../../hive_registrar.g.dart';
import 'hive_config.dart';

class HiveManager {
  HiveManager._();

  static final HiveManager _instance = HiveManager._();

  factory HiveManager() => _instance;

  late Box<SurahModel> _quranBox;
  late Box<AzekrCategory> _azkarBox;
  late Box<DhikrModel> _tasbeehBox;
  late Box<DhikrModel> _defaultTasbeehBox;
  late Box<PrayerTimesModel> _prayerTimesBox;
  late Box<dynamic> _verseOfTheDayBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _quranBox  = await Hive.openBox<SurahModel>(HiveConfig.quranBox);
    _azkarBox   = await Hive.openBox<AzekrCategory>(HiveConfig.azkarBox);
    _tasbeehBox    = await Hive.openBox<DhikrModel>(HiveConfig.tasbeehBox);
    _defaultTasbeehBox = await Hive.openBox<DhikrModel>(HiveConfig.defaultTasbeehBox);
    _prayerTimesBox   = await Hive.openBox<PrayerTimesModel>(HiveConfig.prayerTimesBox);
    _verseOfTheDayBox = await Hive.openBox<dynamic>(HiveConfig.verseOfTheDayBox);
  }

  // -----------------------------Quran-----------------------------------

  Future<void> saveSurahs(List<SurahModel> list) async {
    await _quranBox.clear();
    await _quranBox.addAll(list);
  }

  List<SurahModel> loadSurahs() => _quranBox.values.toList();

  //--------------------------------Azkar-----------------------------------


  Future<void> saveAzkar(AzekrCategory category) async {
    await _azkarBox.clear();
    await _azkarBox.put(HiveConfig.azkarKey, category);
  }

  AzekrCategory? loadAzkar() => _azkarBox.get(HiveConfig.azkarKey);

  // ----------------------Tasbeeh — custom dhikrs---------------------------

  Future<void> saveCustomDhikr(DhikrModel dhikr) async {
    await _tasbeehBox.put(dhikr.id, dhikr);
  }

  List<DhikrModel> loadCustomDhikrs() => _tasbeehBox.values.toList();

  Future<void> deleteCustomDhikr(String id) async {
    await _tasbeehBox.delete(id);
  }

  // ---------------------Tasbeeh — default dhikrs-----------------------------

  Future<void> saveDefaultDhikrs(List<DhikrModel> dhikrs) async {
    await _defaultTasbeehBox.clear();
    await _defaultTasbeehBox.addAll(dhikrs);
  }

  List<DhikrModel> loadDefaultDhikrs() => _defaultTasbeehBox.values.toList();

  // ----------------------------- Prayer Times-----------------------------

  Future<void> savePrayerTimes(PrayerTimesModel model) async {
    await _prayerTimesBox.put(HiveConfig.prayerTimesKey, model);
  }

  PrayerTimesModel? loadPrayerTimes() =>
      _prayerTimesBox.get(HiveConfig.prayerTimesKey);

  // -----------------------Verse of the Day------------------------------

  Future<void> saveVerseOfTheDay(Map<String, dynamic> data) async {
    await _verseOfTheDayBox.clear();
    await _verseOfTheDayBox.put(HiveConfig.verseOfTheDayKey, data);
  }
  Map<String, dynamic>? loadVerseOfTheDay() {
    final raw = _verseOfTheDayBox.get(HiveConfig.verseOfTheDayKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  // ----------------------------lear all---------------------------------

  Future<void> clear() async {
    await _quranBox.clear();
    await _azkarBox.clear();
    await _tasbeehBox.clear();
    await _defaultTasbeehBox.clear();
    await _prayerTimesBox.clear();
  }
}
