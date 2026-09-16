import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeErrorTasbeehService extends TasbeehService {
  final String errorToThrow;
  FakeErrorTasbeehService(this.errorToThrow);

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    throw Exception(errorToThrow);
  }
}

void main() {
  group('TasbeehController Tests', () {
    test('Loads real API data and handles states correctly', () async {
      final controller = TasbeehController();
      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isFalse);
      expect(controller.dhikrList, isEmpty);

      final loadFuture = controller.loadDhikr();
      expect(controller.isLoading, isTrue);

      await loadFuture;
      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isFalse);
      expect(controller.dhikrList.length, 21);
      expect(controller.currentDhikr, isNotNull);
      expect(controller.attribution, contains('Tasbih.info'));
    });

    test('Preserves nullable narratedCount without fabricating numbers', () async {
      final controller = TasbeehController();
      await controller.loadDhikr();

      // First dhikr: SubhanAllah (narratedCount: 33)
      final firstDhikr = controller.dhikrList.firstWhere((d) => d.id == 'subhanallah');
      final firstIndex = controller.dhikrList.indexOf(firstDhikr);
      controller.selectDhikr(firstIndex);

      expect(controller.currentDhikr?.narratedCount, 33);
      expect(controller.targetCount, 33);
      expect(controller.hasTarget, isTrue);

      // Select dhikr without narrated count: The two heavy words
      final nullCountDhikr =
          controller.dhikrList.firstWhere((d) => d.id == 'subhanallahil-azim');
      final nullIndex = controller.dhikrList.indexOf(nullCountDhikr);
      controller.selectDhikr(nullIndex);

      expect(controller.currentDhikr?.narratedCount, isNull);
      expect(controller.targetCount, isNull);
      expect(controller.hasTarget, isFalse);

      // User sets custom target
      controller.setCustomTarget(100);
      expect(controller.targetCount, 100);
      expect(controller.hasTarget, isTrue);

      // Switching dhikr clears custom target
      controller.nextDhikr();
      expect(controller.count, 0);
    });

    test('Counter stops at narrated target (33 cannot become 34)', () async {
      final controller = TasbeehController();
      await controller.loadDhikr();

      // Select SubhanAllah (narratedCount: 33)
      final subhanAllah =
          controller.dhikrList.firstWhere((d) => d.id == 'subhanallah');
      controller.selectDhikr(controller.dhikrList.indexOf(subhanAllah));
      expect(controller.targetCount, 33);

      // Increment 32 times
      for (int i = 0; i < 32; i++) {
        controller.increment();
      }
      expect(controller.count, 32);
      expect(controller.isCompleted, isFalse);

      // 32 -> 33
      controller.increment();
      expect(controller.count, 33);
      expect(controller.isCompleted, isTrue);

      // Tap again: MUST remain 33 (cannot become 34)
      controller.increment();
      expect(controller.count, 33);
      controller.increment();
      expect(controller.count, 33);
    });

    test('Custom target stops at target, open-ended continues without limit', () async {
      final controller = TasbeehController();
      await controller.loadDhikr();

      // Open-ended Dhikr (subhanallahil-azim has narratedCount == null)
      final openDhikr =
          controller.dhikrList.firstWhere((d) => d.id == 'subhanallahil-azim');
      controller.selectDhikr(controller.dhikrList.indexOf(openDhikr));
      expect(controller.hasTarget, isFalse);

      // Increment past 33, 34, 35 without stopping
      for (int i = 0; i < 40; i++) {
        controller.increment();
      }
      expect(controller.count, 40);

      // Now set a custom personal target of 42
      controller.setCustomTarget(42);
      expect(controller.hasTarget, isTrue);
      expect(controller.targetCount, 42);

      controller.increment(); // 41
      expect(controller.count, 41);
      controller.increment(); // 42 -> completed
      expect(controller.count, 42);
      expect(controller.isCompleted, isTrue);

      // Tap again -> stops at 42
      controller.increment();
      expect(controller.count, 42);
    });

    test('Custom Dhikr: validation, creation, selection, and counter stop', () async {
      final controller = TasbeehController();
      await controller.loadDhikr();
      final initialLength = controller.dhikrList.length;

      // Validation rejects
      expect(controller.addCustomDhikr(text: '', count: 33), isFalse);
      expect(controller.addCustomDhikr(text: '   ', count: 33), isFalse);
      expect(controller.addCustomDhikr(text: 'Alhamdulillah', count: 0), isFalse);
      expect(controller.addCustomDhikr(text: 'Alhamdulillah', count: -10), isFalse);
      expect(controller.dhikrList.length, initialLength);

      // Valid Custom Dhikr creation
      final success = controller.addCustomDhikr(
        text: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد',
        count: 10,
      );
      expect(success, isTrue);
      expect(controller.dhikrList.length, initialLength + 1);

      // Custom Dhikr is selected at index 0
      expect(controller.selectedIndex, 0);
      final current = controller.currentDhikr;
      expect(current, isNotNull);
      expect(controller.isCustomDhikr(current!), isTrue);
      expect(current.arabic, 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد');
      expect(controller.getCustomGoal(current), 10);
      expect(current.narratedCount, isNull); // Never attributed to hadith!

      // Counter starts at 0, target is 10
      expect(controller.count, 0);
      expect(controller.targetCount, 10);
      expect(controller.hasTarget, isTrue);

      // Increment to 10
      for (int i = 0; i < 10; i++) {
        controller.increment();
      }
      expect(controller.count, 10);
      expect(controller.isCompleted, isTrue);

      // Tap again: stops at 10 (cannot become 11)
      controller.increment();
      expect(controller.count, 10);
    });

    test('Handles error states properly', () async {
      final controller = TasbeehController(
        tasbeehService: FakeErrorTasbeehService('Network connection error'),
      );

      await controller.loadDhikr();
      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorType, AppErrorType.noInternet);
    });
  });
}
