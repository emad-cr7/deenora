import 'dart:async';
import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:deenora/features/tasbeeh/models/tasbih_dataset_model.dart';
import 'package:deenora/features/tasbeeh/screens/tasbeeh_screen.dart';
import 'package:deenora/features/tasbeeh/widgets/sheets/add_custom_dhikr_sheet.dart';
import 'package:deenora/features/tasbeeh/widgets/buttons/counter_button.dart';
import 'package:deenora/features/tasbeeh/widgets/display/counter_display.dart';
import 'package:deenora/features/tasbeeh/widgets/cards/dhikr_card.dart';
import 'package:deenora/features/tasbeeh/widgets/skeletons/tasbeeh_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeTasbeehService extends TasbeehService {
  final TasbihDatasetModel dataset;
  FakeTasbeehService(this.dataset);

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    return dataset;
  }
}

class PendingTasbeehService extends TasbeehService {
  final Completer<TasbihDatasetModel> completer =
      Completer<TasbihDatasetModel>();

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) {
    return completer.future;
  }
}

void main() {
  final sampleDhikrList = [
    const DhikrModel(
      id: 'subhanallah',
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللَّهِ',
      narratedCount: 33,
    ),
    const DhikrModel(
      id: 'two-heavy-words',
      name: 'The two heavy words',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      narratedCount: null, // Nullable!
    ),
  ];

  final sampleDataset = TasbihDatasetModel(
    attribution: 'Tasbih.info (https://tasbih.info)',
    dhikrList: sampleDhikrList,
  );

  group('TasbeehScreen UI Widget Tests', () {
    testWidgets('Displays TasbeehSkeleton when loading with no data', (
      tester,
    ) async {
      final pendingService = PendingTasbeehService();
      final controller = TasbeehController(tasbeehService: pendingService);
      unawaited(controller.loadDhikr());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TasbeehController>.value(
            value: controller,
            child: const TasbeehScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TasbeehSkeleton), findsOneWidget);

      pendingService.completer.complete(sampleDataset);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'Displays full Tasbeeh UI with DhikrCard, Counter, and Button when loaded',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final service = FakeTasbeehService(sampleDataset);
        final controller = TasbeehController(tasbeehService: service);
        await controller.loadDhikr();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<TasbeehController>.value(
              value: controller,
              child: const TasbeehScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header & Components
        expect(find.text('Tasbeeh'), findsOneWidget);
        expect(find.byType(DhikrCard), findsOneWidget);
        expect(find.byType(CounterDisplay), findsOneWidget);
        expect(find.byType(CounterButton), findsOneWidget);

        // Verify AppBar has NO info button
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byIcon(Icons.info_outline_rounded),
          ),
          findsNothing,
        );
        expect(find.byIcon(Icons.info_outline_rounded), findsNothing);

        // Verify Main Dhikr Card does not show unnecessary info/source UI
        expect(find.text('Hadith Details'), findsNothing);
        expect(find.text('Sahih Muslim 597a'), findsNothing);

        // Verify Target button is completely removed from the UI
        expect(find.text('Target'), findsNothing);

        // Verify Select Dhikr is present and placed BELOW the Next / Previous buttons
        expect(find.text('Select Dhikr'), findsOneWidget);
        final nextDy = tester.getTopLeft(find.text('Next')).dy;
        final selectDhikrDy = tester.getTopLeft(find.text('Select Dhikr')).dy;
        expect(selectDhikrDy, greaterThan(nextDy));

        // Verify English title is visible on the card
        expect(find.text('SubhanAllah'), findsWidgets);

        // Verify Arabic text is NOT visible in current UI
        expect(find.text('سُبْحَانَ اللَّهِ'), findsNothing);

        // Verify Arabic data is preserved internally in the controller/model
        expect(controller.currentDhikr?.arabic, 'سُبْحَانَ اللَّهِ');
        expect(controller.attribution, contains('Tasbih.info'));

        expect(find.text('Narrated: 33'), findsOneWidget);
        expect(find.text('/ 33'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);

        // Test tapping CounterButton
        await tester.tap(find.byType(CounterButton));
        await tester.pumpAndSettle();
        expect(controller.count, 1);
        expect(find.text('1'), findsOneWidget);

        // Test reaching target (33) and stopping
        for (int i = 0; i < 32; i++) {
          await tester.tap(find.byType(CounterButton));
        }
        await tester.pumpAndSettle();
        expect(controller.count, 33);
        expect(find.text('33'), findsOneWidget);
        expect(find.text('Target Reached · Masha\'Allah'), findsOneWidget);

        // Additional tap: MUST NOT increase to 34
        await tester.tap(find.byType(CounterButton));
        await tester.pumpAndSettle();
        expect(controller.count, 33);
        expect(find.text('33'), findsOneWidget);
        expect(find.text('34'), findsNothing);

        // Test Reset button
        final resetButton = find.text('Reset');
        expect(resetButton, findsOneWidget);
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        // Confirm reset dialog appears
        expect(find.text('Reset Counter?'), findsOneWidget);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset'));
        await tester.pumpAndSettle();
        expect(controller.count, 0);
        expect(find.text('0'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays Open Counter for Dhikr without narrated count without fabricating target',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final service = FakeTasbeehService(sampleDataset);
        final controller = TasbeehController(tasbeehService: service);
        await controller.loadDhikr();

        // Select index 1 which has narratedCount == null
        controller.selectDhikr(1);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<TasbeehController>.value(
              value: controller,
              child: const TasbeehScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that no fabricated target count is displayed
        expect(find.text('No Narrated Count'), findsOneWidget);
        expect(find.text('Open Counter'), findsOneWidget);
        expect(find.textContaining('/ 33'), findsNothing);

        // Verify English title is shown and Arabic is hidden
        expect(find.text('The two heavy words'), findsOneWidget);
        expect(
          find.textContaining('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'),
          findsNothing,
        );

        // Custom personal target setting
        controller.addCustomDhikr(text: 'The two heavy words', count: 50);
        await tester.pumpAndSettle();

        expect(find.text('Personal Goal: 50'), findsOneWidget);
        expect(find.text('/ 50'), findsOneWidget);
      },
    );

    testWidgets(
      'Add Custom Dhikr sheet creates and selects custom Dhikr in English UI',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final service = FakeTasbeehService(sampleDataset);
        final controller = TasbeehController(tasbeehService: service);
        await controller.loadDhikr();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<TasbeehController>.value(
              value: controller,
              child: const TasbeehScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Select Dhikr button in action bar
        await tester.tap(find.text('Select Dhikr'));
        await tester.pumpAndSettle();

        // Verify Add Dhikr is displayed
        expect(
          find.widgetWithText(ElevatedButton, 'Add Dhikr'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Dhikr'));
        await tester.pumpAndSettle();

        // Verify Add Personal Dhikr sheet opens
        expect(find.text('Add Personal Dhikr'), findsOneWidget);

        // Enter Dhikr Text and Count
        final textFields = find.descendant(
          of: find.byType(AddCustomDhikrSheet),
          matching: find.byType(TextField),
        );
        expect(textFields, findsNWidgets(2));
        await tester.enterText(
          textFields.first,
          'Astaghfirullah wa atubu ilayh',
        );
        await tester.enterText(textFields.last, '10');
        await tester.pumpAndSettle();

        // Submit
        final submitButton = find.descendant(
          of: find.byType(AddCustomDhikrSheet),
          matching: find.widgetWithText(ElevatedButton, 'Add Dhikr'),
        );
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should now be on main screen with the custom dhikr selected
        expect(find.text('Astaghfirullah wa atubu ilayh'), findsOneWidget);
        expect(find.text('Personal Dhikr'), findsOneWidget);
        expect(find.text('Personal Goal: 10'), findsOneWidget);
        expect(find.text('/ 10'), findsOneWidget);
        expect(controller.isCustomDhikr(controller.currentDhikr!), isTrue);
        expect(controller.currentDhikr?.narratedCount, isNull);
        expect(
          controller.currentDhikr?.arabic,
          'Astaghfirullah wa atubu ilayh',
        );
      },
    );
  });
}
