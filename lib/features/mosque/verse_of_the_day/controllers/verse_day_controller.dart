import 'package:flutter/material.dart';
import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/verse_day/verse_day_service.dart';
import '../models/verse_day_model.dart';

class VerseDayController extends ChangeNotifier {
  final VerseOfTheDayService _service = VerseOfTheDayService();
  final HiveManager _hiveManager = HiveManager();
  late Future<VerseDayModel> verseOfTheDayFuture;

  void init() {
    verseOfTheDayFuture = _loadVerseOfTheDay();
  }

  Future<VerseDayModel> _loadVerseOfTheDay() async {
    final today = DateTime.now().toString().split(' ').first;
    final cached = _hiveManager.loadVerseOfTheDay();

    if (cached != null && cached['savedDate'] == today) {
      return VerseDayModel.fromStoredMap(cached);
    }
    final verse = await _service.getVerseOfTheDay(savedDate: today);
    await _hiveManager.saveVerseOfTheDay(verse.toStoredMap());
    return verse;
  }

  void retry() {
    verseOfTheDayFuture = _loadVerseOfTheDay();
    notifyListeners();
  }
}
