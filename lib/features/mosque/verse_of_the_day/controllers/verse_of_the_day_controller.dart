import 'package:flutter/material.dart';

import '../../../../core/data/local_data/hive_manager.dart';
import '../models/verse_of_the_day_model.dart';
import '../services/verse_of_the_day_service.dart';

class VerseOfTheDayController extends ChangeNotifier {
  final VerseOfTheDayService _service = VerseOfTheDayService();
  final HiveManager _hiveManager = HiveManager();
  late Future<VerseOfTheDayModel> verseOfTheDayFuture;

  void init() {
    verseOfTheDayFuture = _loadVerseOfTheDay();
  }

  Future<VerseOfTheDayModel> _loadVerseOfTheDay() async {
    final today = DateTime.now().toString().split(' ').first;
    final cached = _hiveManager.loadVerseOfTheDay();

    if (cached != null && cached['savedDate'] == today) {
      return VerseOfTheDayModel.fromStoredMap(cached);
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
