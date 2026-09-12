import 'package:flutter/material.dart';
import '../../../../../../core/data/remote_data/quran/quran_listening_service.dart';
import '../../../models_listening/reciter_model.dart';

class ReciterAudioHandler extends ChangeNotifier {
  ReciterModel _currentReciter;
  Map<int, String>? _audioMap;
  final QuranListeningService _listeningService;

  ReciterAudioHandler({
    ReciterModel? initialReciter,
    Map<int, String>? initialAudioMap,
    QuranListeningService? listeningService,
  })  : _currentReciter = initialReciter ?? reciters.first,
        _audioMap = initialAudioMap,
        _listeningService = listeningService ?? QuranListeningService();

  ReciterModel get currentReciter => _currentReciter;
  Map<int, String>? get audioMap => _audioMap;

  void setReciter(ReciterModel newReciter) {
    if (_currentReciter.id == newReciter.id) return;
    _currentReciter = newReciter;
    _audioMap = null;
    notifyListeners();
  }

  void setAudioMap(Map<int, String> map) {
    _audioMap = map;
    notifyListeners();
  }

  /// Resolves the audio streaming URL for a given [surahNumber]
  Future<String?> getAudioUrl(int surahNumber) async {
    if (_audioMap == null || !_audioMap!.containsKey(surahNumber)) {
      _audioMap = await _listeningService.getReciterAudioFiles(_currentReciter.id);
    }
    return _audioMap?[surahNumber];
  }
}
