import 'package:flutter/material.dart';

import '../models/verse_of_the_day_model.dart';
import '../services/verse_of_the_day_service.dart';

class VerseOfTheDayController extends ChangeNotifier {
  final VerseOfTheDayService _service;

  VerseOfTheDayController({VerseOfTheDayService? service})
    : _service = service ?? VerseOfTheDayService();

  VerseOfTheDayModel? _verse;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  VerseOfTheDayModel? get verse => _verse;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  String? get errorMessage => _errorMessage;

  Future<void> loadVerseOfTheDay({bool forceRefresh = false}) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getVerseOfTheDay(
        forceRefresh: forceRefresh,
      );

      _verse = result;
      _isLoading = false;
      _hasError = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
