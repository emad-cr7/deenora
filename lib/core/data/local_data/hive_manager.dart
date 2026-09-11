import 'package:hive_ce_flutter/adapters.dart';

import '../../../features/Azkar/azkar_model/azekr_category.dart';
import '../../../features/Quran/reading/models/surah_model.dart';
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

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _quranBox = await Hive.openBox<SurahModel>(HiveConfig.quranBox);
    _azkarBox = await Hive.openBox<AzekrCategory>(HiveConfig.azkarBox);
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

  Future<void> clear() async {
    await _quranBox.clear();
  }
}