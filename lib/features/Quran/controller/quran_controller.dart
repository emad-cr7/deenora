import 'package:flutter/material.dart';
import '../../../core/data/local_data/hive_manager.dart';
import '../../../core/data/remote_data/quran_Reading_service.dart';
import '../../../core/models/surah_model.dart';

class QuranController extends ChangeNotifier {
  final QuranReadingService _service = QuranReadingService();
  final HiveManager _hiveManager = HiveManager();

  late Future<List<SurahModel>> futureQuran;

  void init() {
    futureQuran = _loadQuran();
    notifyListeners();
  }
  Future<List<SurahModel>> _loadQuran() async {
    final cached = _hiveManager.loadSurahs();
    if (cached.isNotEmpty) {
      return cached;
    }

    final response = await _service.getFullQuran();
    await _hiveManager.saveSurahs(response.surahs);
    return response.surahs;
  }
}