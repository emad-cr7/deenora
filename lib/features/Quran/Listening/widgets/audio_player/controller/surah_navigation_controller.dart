import 'package:flutter/material.dart';
import '../../../../../../core/data/local_data/hive_manager.dart';
import '../../../../reading/models/surah_model.dart';
import '../services/surah_navigation_service.dart';

class SurahNavigationController extends ChangeNotifier {
  final SurahNavigationService _service;

  SurahNavigationController({
    required SurahModel initialSurah,
    List<SurahModel>? surahList,
    SurahNavigationService? service,
  }) : _service = service ??
            SurahNavigationService(
              initialSurah: initialSurah,
              surahList: surahList,
            );

  SurahModel get currentSurah => _service.currentSurah;
  List<SurahModel> get surahList => _service.surahList;
  int get currentSurahIndex => _service.currentSurahIndex;
  bool get hasPrevious => _service.hasPrevious;
  bool get hasNext => _service.hasNext;
  SurahModel? get previousSurah => _service.previousSurah;
  SurahModel? get nextSurah => _service.nextSurah;

  void updateCurrentSurah(SurahModel surah) {
    if (_service.currentSurah.number == surah.number) return;
    _service.updateCurrentSurah(surah);
    notifyListeners();
  }

  void updateSurahList(List<SurahModel> list) {
    _service.updateSurahList(list);
    notifyListeners();
  }

  void ensureSurahListLoaded({HiveManager? hiveManager}) {
    if (_service.surahList.isEmpty) {
      final manager = hiveManager ?? HiveManager();
      final cached = manager.loadSurahs();
      if (cached.isNotEmpty) {
        _service.updateSurahList(cached);
        notifyListeners();
      }
    }
  }

  bool isValidSurahNumber(int number) => _service.isValidSurahNumber(number);

  SurahModel? getNextSurah() => _service.nextSurah;

  SurahModel? getPreviousSurah() => _service.previousSurah;
}
