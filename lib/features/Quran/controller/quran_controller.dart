import 'package:flutter/material.dart';
import '../../../core/data/local_data/hive_manager.dart';
import '../../../core/data/remote_data/quran_Reading_service.dart';
import '../../../core/data/remote_data/quran_listening_service.dart';
import '../../../core/models/surah_model.dart';
import '../Listening/models_listening/name_surah_model.dart';

class QuranController extends ChangeNotifier {
  final QuranReadingService _service = QuranReadingService();
  final HiveManager _hiveManager = HiveManager();
  final QuranListeningService _listeningService = QuranListeningService();

  late Future<List<NameSurahModel>> futureChapters;
  late Future<List<SurahModel>> futureQuran;

  /// Map من chapter id لرابط الصوت، لتلاوة شيخ معين.
  Future<Map<int, String>>? futureReciterAudio;

  void initSurahQuran() {
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
//---------------------------initSurahAudio--------------------------------


  /// لو معدي reciterId، هيتحمّل معاها كمان روابط تلاوة الشيخ ده لكل السور.
  ///
  void initSurah({int? reciterId}) {
    futureChapters = loadChapters();
    if (reciterId != null) {
      futureReciterAudio = loadReciterAudio(reciterId);
    }
    notifyListeners();
  }

  Future<Map<int, String>> loadReciterAudio(int reciterId) async {
    final files = await _listeningService.getReciterAudioFiles(reciterId);
    return {for (final file in files) file.chapterId: file.audioUrl};
  }



  Future<List<NameSurahModel>> loadChapters() async {
    final cached = _hiveManager.loadNameSurahs();
    if (cached.isNotEmpty) {
      return cached;
    }
    final response = await _listeningService.getChapters();
    await _hiveManager.saveNameSurahs(response);
    return response;
  }
}
