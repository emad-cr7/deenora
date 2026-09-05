import 'package:flutter/material.dart';
import '../../../core/data/local_data/hive_manager.dart';
import '../../../core/data/remote_data/quran/quran_Reading_service.dart';
import '../../../core/data/remote_data/quran/quran_listening_service.dart';
import '../../../core/models/surah_model.dart';
import '../Listening/models_listening/name_surah_model.dart';

class QuranController extends ChangeNotifier {
  final QuranReadingService _service = QuranReadingService();
  final HiveManager _hiveManager = HiveManager();
  final QuranListeningService _listeningService = QuranListeningService();

  late Future<List<NameSurahModel>> futureChapters;
  late Future<List<SurahModel>> futureQuran;

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



  void initSurah({int? reciterId}) {
    futureChapters = _loadChapters();
    if (reciterId != null) {
      futureReciterAudio = _loadReciterAudio(reciterId);
    }
    notifyListeners();
  }

  Future<List<NameSurahModel>> _loadChapters() async {
    final cached = _hiveManager.loadNameSurahs();
    if (cached.isNotEmpty) {
      return cached;
    }
    final response = await _listeningService.getChapters();
    await _hiveManager.saveNameSurahs(response);
    return response;
  }

  Future<Map<int, String>> _loadReciterAudio(int reciterId) async {
    final files = await _listeningService.getReciterAudioFiles(reciterId);
    return {for (final file in files) file.chapterId: file.audioUrl};
  }
}
