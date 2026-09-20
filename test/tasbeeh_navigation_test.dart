import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/features/mosque/feature_cards/feature_cards_section.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:deenora/features/tasbeeh/models/tasbih_dataset_model.dart';
import 'package:deenora/features/tasbeeh/screens/tasbeeh_screen.dart';
import 'package:deenora/features/tasbeeh/screens/tasbeeh_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeTasbeehService extends TasbeehService {
  final TasbihDatasetModel dataset;
  _FakeTasbeehService(this.dataset);

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    return dataset;
  }
}

void main() {
  final sampleDataset = TasbihDatasetModel(
    attribution: 'Tasbih.info (https://tasbih.info)',
    dhikrList: const [
      DhikrModel(
        id: 'subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        narratedCount: 33,
      ),
      DhikrModel(
        id: 'alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        narratedCount: 33,
      ),
    ],
  );

  testWidgets(
    'Tapping Tasbeeh FeatureCard pushes TasbeehSelectionScreen and back button pops',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeatureCardsSection())),
      );
      await tester.pumpAndSettle();

      // Verify Tasbeeh card is visible
      expect(find.text('Tasbeeh'), findsOneWidget);

      // Tap on Tasbeeh card
      await tester.tap(find.text('Tasbeeh'));
      await tester.pumpAndSettle();

      // Verify TasbeehSelectionScreen is now displayed (not TasbeehScreen directly)
      expect(find.byType(TasbeehSelectionScreen), findsOneWidget);
      expect(find.byType(TasbeehScreen), findsNothing);

      // Tap back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify back on Mosque / FeatureCardsSection screen
      expect(find.byType(TasbeehSelectionScreen), findsNothing);
      expect(find.byType(FeatureCardsSection), findsOneWidget);
    },
  );

  testWidgets(
    'Full Navigation Flow: FeatureCard -> TasbeehSelectionScreen -> TasbeehScreen -> Back -> Back',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = TasbeehController(
        tasbeehService: _FakeTasbeehService(sampleDataset),
      );
      await controller.loadDhikr();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChangeNotifierProvider<TasbeehController>.value(
                              value: controller,
                              child: const TasbeehSelectionScreen(),
                            ),
                      ),
                    );
                  },
                  child: const Text('Open Tasbeeh'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Navigate to TasbeehSelectionScreen
      await tester.tap(find.text('Open Tasbeeh'));
      await tester.pumpAndSettle();
      expect(find.byType(TasbeehSelectionScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Tasbeeh'),
        ),
        findsOneWidget,
      );
      expect(find.text('SubhanAllah'), findsOneWidget);
      expect(find.text('Alhamdulillah'), findsOneWidget);

      // 2. Tap on "Alhamdulillah" to select and navigate to TasbeehScreen
      await tester.tap(find.text('Alhamdulillah'));
      await tester.pumpAndSettle();

      // Verify TasbeehScreen is now displayed with Alhamdulillah active
      expect(find.byType(TasbeehScreen), findsOneWidget);
      expect(controller.selectedIndex, 1);
      expect(controller.currentDhikr?.name, 'Alhamdulillah');

      // 3. Tap AppBar Back button on TasbeehScreen
      final backButtonOnTasbeeh = find.byType(BackButton);
      expect(backButtonOnTasbeeh, findsOneWidget);
      await tester.tap(backButtonOnTasbeeh);
      await tester.pumpAndSettle();

      // Verify returned to TasbeehSelectionScreen
      expect(find.byType(TasbeehScreen), findsNothing);
      expect(find.byType(TasbeehSelectionScreen), findsOneWidget);

      // 4. Tap AppBar Back button on TasbeehSelectionScreen
      final backButtonOnSelection = find.byType(BackButton);
      expect(backButtonOnSelection, findsOneWidget);
      await tester.tap(backButtonOnSelection);
      await tester.pumpAndSettle();

      // Verify returned to root screen
      expect(find.byType(TasbeehSelectionScreen), findsNothing);
      expect(find.text('Open Tasbeeh'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Select Dhikr in TasbeehActionsBar returns to TasbeehSelectionScreen',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = TasbeehController(
        tasbeehService: _FakeTasbeehService(sampleDataset),
      );
      await controller.loadDhikr();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TasbeehController>.value(
            value: controller,
            child: const TasbeehSelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select SubhanAllah
      await tester.tap(find.text('SubhanAllah'));
      await tester.pumpAndSettle();
      expect(find.byType(TasbeehScreen), findsOneWidget);

      // Tap Select Dhikr in TasbeehActionsBar
      await tester.tap(find.text('Select Dhikr'));
      await tester.pumpAndSettle();

      // Verify returned to TasbeehSelectionScreen
      expect(find.byType(TasbeehScreen), findsNothing);
      expect(find.byType(TasbeehSelectionScreen), findsOneWidget);
    },
  );
}
