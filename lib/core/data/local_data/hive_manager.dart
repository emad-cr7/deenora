import 'package:hive_ce_flutter/adapters.dart';

import '../../models/surah_model.dart';
import '../../../hive_registrar.g.dart';
import '../remote_data/hive_config.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._();

  HiveManager._();

  factory HiveManager() {
    return _instance;
  }

  late Box<SurahModel> _quranBox;

  init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _quranBox = await Hive.openBox<SurahModel>(HiveConfig.quranBox);
  }

  saveSurahs(List<SurahModel> list) async {
    await _quranBox.clear();
    await _quranBox.addAll(list);
  }

  List<SurahModel> loadSurahs() {
    return _quranBox.values.toList();
  }

  clear() async {
    await _quranBox.clear();
  }
}