import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sleep_timer_option.dart';

class SleepTimerController extends ChangeNotifier {
  Timer? _timer;
  SleepTimerOption? _selectedOption;
  int _remainingSeconds = 0;

  bool get isActive => _selectedOption != null;

  SleepTimerOption? get selectedOption => _selectedOption;

  int get remainingSeconds => _remainingSeconds;

  bool get isEndOfSurah => _selectedOption == SleepTimerOption.endOfSurah;

  String get formattedRemainingTime {
    if (_selectedOption == SleepTimerOption.endOfSurah) {
      return 'End of Surah';
    }
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h.toString().padLeft(2, '0')}:${remM.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startTimer(
    SleepTimerOption option, {
    int? customMinutes,
    required VoidCallback onTimerComplete,
  }) {
    cancelTimer(notify: false);
    _selectedOption = option;

    if (option == SleepTimerOption.endOfSurah) {
      notifyListeners();
      return;
    }

    final totalMinutes =
        option == SleepTimerOption.custom ? (customMinutes ?? 15) : option.minutes;
    _remainingSeconds = totalMinutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        cancelTimer();
        onTimerComplete();
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void cancelTimer({bool notify = true}) {
    _timer?.cancel();
    _timer = null;
    _selectedOption = null;
    _remainingSeconds = 0;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
