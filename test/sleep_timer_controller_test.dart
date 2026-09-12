import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/sleep_timer_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/models/sleep_timer_option.dart';

void main() {
  group('SleepTimerController Tests', () {
    // اختبار تهيئة المؤقت بحالة غير نشطة
    test('Initial timer state is inactive', () {
      final timerController = SleepTimerController();
      expect(timerController.isActive, isFalse);
      expect(timerController.selectedOption, isNull);
      expect(timerController.remainingSeconds, 0);
      expect(timerController.formattedRemainingTime, '00:00');
      timerController.dispose();
    });

    // اختبار بدء مؤقت محدد بمدة زمنية وتنسيق الوقت
    test('Starting preset timer sets remaining seconds and formatted string', () {
      final timerController = SleepTimerController();
      timerController.startTimer(
        SleepTimerOption.fifteenMin,
        onTimerComplete: () {},
      );

      expect(timerController.isActive, isTrue);
      expect(timerController.selectedOption, SleepTimerOption.fifteenMin);
      expect(timerController.remainingSeconds, 900);
      expect(timerController.formattedRemainingTime, '15:00');

      timerController.cancelTimer();
      expect(timerController.isActive, isFalse);
      expect(timerController.selectedOption, isNull);
      timerController.dispose();
    });

    // اختبار خيار نهاية السورة
    test('End of Surah option formats correctly without countdown', () {
      final timerController = SleepTimerController();
      timerController.startTimer(
        SleepTimerOption.endOfSurah,
        onTimerComplete: () {},
      );

      expect(timerController.isActive, isTrue);
      expect(timerController.selectedOption, SleepTimerOption.endOfSurah);
      expect(timerController.formattedRemainingTime, 'End of Surah');

      timerController.cancelTimer();
      timerController.dispose();
    });

    // اختبار المدة المخصصة
    test('Custom timer duration sets custom seconds properly', () {
      final timerController = SleepTimerController();
      timerController.startTimer(
        SleepTimerOption.custom,
        customMinutes: 75,
        onTimerComplete: () {},
      );

      expect(timerController.isActive, isTrue);
      expect(timerController.remainingSeconds, 4500);
      expect(timerController.formattedRemainingTime, '01:15:00');

      timerController.cancelTimer();
      timerController.dispose();
    });
  });
}
