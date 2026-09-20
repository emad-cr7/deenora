import 'package:flutter/material.dart';
import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/verse_day/verse_day_service.dart';
import '../../../../main.dart';
import '../../../Quran/reading/utils/quran_navigation_helper.dart';
import '../models/verse_day_model.dart';

class VerseDayController extends ChangeNotifier {
  final VerseOfTheDayService _service = VerseOfTheDayService();
  final HiveManager _hiveManager = HiveManager();

  late Future<VerseDayModel> verseOfTheDayFuture;

  VerseDayModel? verse;
  bool isLoading = false;
  Object? error;

  void init() {
    verseOfTheDayFuture = _loadVerseOfTheDay();
  }

  Future<VerseDayModel> _loadVerseOfTheDay() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final today = DateTime.now().toString().split(' ').first;
      final cached = _hiveManager.loadVerseOfTheDay();

      if (cached != null && cached['savedDate'] == today) {
        verse = VerseDayModel.fromStoredMap(cached);
        return verse!;
      }

      final fetched = await _service.getVerseOfTheDay(savedDate: today);

      await _hiveManager.saveVerseOfTheDay(
        fetched.toStoredMap(),
      );

      verse = fetched;

      return verse!;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void retry() {
    verseOfTheDayFuture = _loadVerseOfTheDay();
    notifyListeners();
  }

  void navigateToVerse(VerseDayModel verse) {
    QuranNavigationHelper.navigateToSurah(
      navigatorKey.currentContext!,
      surahNumber: verse.surahNumber,
    );
  }
}