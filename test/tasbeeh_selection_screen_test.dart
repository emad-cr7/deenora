import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:deenora/features/tasbeeh/models/tasbih_dataset_model.dart';
import 'package:deenora/features/tasbeeh/screens/tasbeeh_screen.dart';
import 'package:deenora/features/tasbeeh/screens/tasbeeh_selection_screen.dart';
import 'package:deenora/features/tasbeeh/widgets/sheets/add_custom_dhikr_sheet.dart';
import 'package:deenora/features/tasbeeh/widgets/tiles/dhikr_list_tile.dart';
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
  final sampleDhikrs = [
    const DhikrModel(
      id: 'subhanallah',
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللَّهِ',
      narratedCount: 33,
    ),
    const DhikrModel(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      narratedCount: 33,
    ),
    const DhikrModel(
      id: 'allahu-akbar',
      name: 'Allahu Akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      narratedCount: 34,
    ),
  ];

  final sampleDataset = TasbihDatasetModel(
    attribution: 'Tasbih.info (https://tasbih.info)',
    dhikrList: sampleDhikrs,
  );

  group('TasbeehSelectionScreen Widget Tests', () {
    testWidgets(
      'Renders AppBar title Tasbeeh, Search, Dhikr items with inline count, and bottom Add Dhikr button',
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

        // 1. AppBar title "Tasbeeh"
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Tasbeeh'),
          ),
          findsOneWidget,
        );

        // 2. Search field at top
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search dhikr...'), findsOneWidget);

        // 3. Dhikr items with inline counts
        expect(find.byType(DhikrListTile), findsNWidgets(3));
        expect(find.text('SubhanAllah'), findsOneWidget);
        expect(find.text('33'), findsWidgets);
        expect(find.text('Allahu Akbar'), findsOneWidget);
        expect(find.text('34'), findsOneWidget);

        // Verify count is rendered on the same row as Dhikr name
        final subhanAllahY = tester.getCenter(find.text('SubhanAllah')).dy;
        final count33Center = tester.getCenter(find.text('33').first);
        expect((count33Center.dy - subhanAllahY).abs(), lessThan(10));

        // 4. Fixed Add Dhikr button at the bottom of the screen
        expect(
          find.widgetWithText(ElevatedButton, 'Add Dhikr'),
          findsOneWidget,
        );
        final listDy = tester.getTopLeft(find.byType(ListView)).dy;
        final buttonDy = tester
            .getTopLeft(find.widgetWithText(ElevatedButton, 'Add Dhikr'))
            .dy;
        expect(buttonDy, greaterThan(listDy));

        // 5. Built-in Dhikrs do NOT have popup menu (⋮)
        expect(find.byType(PopupMenuButton<String>), findsNothing);
      },
    );

    testWidgets('Search query filters Dhikr list dynamically and clears', (
      tester,
    ) async {
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

      // Search "alham"
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'alham');
      await tester.pumpAndSettle();

      expect(find.text('Alhamdulillah'), findsOneWidget);
      expect(find.text('SubhanAllah'), findsNothing);
      expect(find.text('Allahu Akbar'), findsNothing);

      // Search Arabic
      await tester.enterText(searchField, 'أَكْبَرُ');
      await tester.pumpAndSettle();
      expect(find.text('Allahu Akbar'), findsOneWidget);
      expect(find.text('Alhamdulillah'), findsNothing);

      // Clear search
      final clearButton = find.byIcon(Icons.clear_rounded);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.byType(DhikrListTile), findsNWidgets(3));
    });

    testWidgets(
      'Tapping Add Dhikr button opens streamlined bottom sheet and creates custom dhikr',
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

        // Tap fixed "Add Dhikr" button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Add Dhikr'));
        await tester.pumpAndSettle();

        // Verify streamlined AddCustomDhikrSheet
        expect(find.byType(AddCustomDhikrSheet), findsOneWidget);
        expect(find.text('Add Personal Dhikr'), findsOneWidget);

        // Verify yellow warning disclaimer is REMOVED
        expect(find.byIcon(Icons.info_outline_rounded), findsNothing);

        // Verify Cancel button is REMOVED
        expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);

        // Fill text and goal
        final inputFields = find.descendant(
          of: find.byType(AddCustomDhikrSheet),
          matching: find.byType(TextField),
        );
        expect(inputFields, findsNWidgets(2));
        await tester.enterText(inputFields.first, 'My Custom Dhikr');
        await tester.enterText(inputFields.last, '100');
        await tester.pumpAndSettle();

        // Submit with full-width Add Dhikr button inside sheet
        final submitButton = find.descendant(
          of: find.byType(AddCustomDhikrSheet),
          matching: find.widgetWithText(ElevatedButton, 'Add Dhikr'),
        );
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Navigates to TasbeehScreen
        expect(find.byType(TasbeehScreen), findsOneWidget);
        expect(find.text('My Custom Dhikr'), findsOneWidget);
        expect(find.text('Personal Goal: 100'), findsOneWidget);

        // Pop back to TasbeehSelectionScreen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(TasbeehSelectionScreen), findsOneWidget);

        // Verify custom dhikr is listed with inline count 100 and has popup menu
        expect(find.text('My Custom Dhikr'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      },
    );

    testWidgets(
      'Custom Dhikr can be edited and deleted with immediate UI update',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = TasbeehController(
          tasbeehService: _FakeTasbeehService(sampleDataset),
        );
        await controller.loadDhikr();
        controller.addCustomDhikr(text: 'Dhikr To Manage', count: 50);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<TasbeehController>.value(
              value: controller,
              child: const TasbeehSelectionScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify custom dhikr is present with count 50
        expect(find.text('Dhikr To Manage'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);

        // Open popup menu on the custom Dhikr
        final popupMenu = find.byType(PopupMenuButton<String>);
        expect(popupMenu, findsOneWidget);
        await tester.tap(popupMenu);
        await tester.pumpAndSettle();

        // Verify Edit and Delete options
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // 1. Test Edit
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Personal Dhikr'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);

        final editFields = find.descendant(
          of: find.byType(AddCustomDhikrSheet),
          matching: find.byType(TextField),
        );
        await tester.enterText(editFields.first, 'Updated Dhikr Name');
        await tester.enterText(editFields.last, '75');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
        await tester.pumpAndSettle();

        // Verify updated immediately in list
        expect(find.text('Updated Dhikr Name'), findsOneWidget);
        expect(find.text('75'), findsOneWidget);
        expect(find.text('Dhikr To Manage'), findsNothing);

        // 2. Test Delete
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Confirmation dialog appears
        expect(find.text('Delete Dhikr?'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete "Updated Dhikr Name"?'),
          findsOneWidget,
        );

        // Confirm deletion
        final confirmDeleteButton = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'Delete'),
        );
        await tester.tap(confirmDeleteButton);
        await tester.pumpAndSettle();

        // Verify removed from list immediately
        expect(find.text('Updated Dhikr Name'), findsNothing);
        expect(find.byType(PopupMenuButton<String>), findsNothing);
      },
    );
  });
}
