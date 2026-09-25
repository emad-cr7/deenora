import 'package:flutter/material.dart';

import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/hadith_day/hadith_day_service.dart';
import '../models/hadith_day_model.dart';

class HadithDayController extends ChangeNotifier {
  final HadithDayService _service = HadithDayService();
  final HiveManager _hiveManager = HiveManager();

  late Future<HadithDayModel> hadithOfTheDayFuture;

  HadithDayModel? hadith;
  bool isLoading = false;
  Object? error;

  void init() {
    hadithOfTheDayFuture = _loadHadithOfTheDay();
  }

  Future<HadithDayModel> _loadHadithOfTheDay() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final today = DateTime.now().toString().split(' ').first;
      final cached = _hiveManager.loadHadithOfTheDay();

      if (cached != null && cached['savedDate'] == today) {
        hadith = HadithDayModel.fromJson(cached);
        return hadith!;
      }

      final fetched = await _service.getHadithOfTheDay(savedDate: today);

      await _hiveManager.saveHadithOfTheDay(fetched.toJson());

      hadith = fetched;

      return hadith!;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void retry() {
    hadithOfTheDayFuture = _loadHadithOfTheDay();
    notifyListeners();
  }
}
