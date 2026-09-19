import 'package:flutter/material.dart';
import '../../../core/data/remote_data/quran/quran_listening_service.dart';
import '../reading/models/surah_model.dart';
import '../reading/repository/quran_repository.dart';

class QuranController extends ChangeNotifier {
  final QuranRepository _repository;
  final QuranListeningService _listeningService = QuranListeningService();

  QuranController({QuranRepository? repository})
    : _repository = repository ?? QuranRepository();

  late Future<List<SurahModel>> futureQuran;

  Future<Map<int, String>>? futureReciterAudio;

  void initSurahQuran() {
    futureQuran = _repository.getSurahs();
    notifyListeners();
  }

  //---------------------------initSurahAudio--------------------------------

  void initSurah({int? reciterId}) {
    futureQuran = _repository.getSurahs();
    if (reciterId != null) {
      futureReciterAudio = _loadReciterAudio(reciterId);
    }
    notifyListeners();
  }

  Future<Map<int, String>> _loadReciterAudio(int reciterId) async {
    return await _listeningService.getReciterAudioFiles(reciterId);
  }

  Future<String?> getAudioUrl(int surahNumber) async {
    final map = await futureReciterAudio;
    return map?[surahNumber];
  }
}
