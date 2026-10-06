import 'package:deenora/core/widget/share_widget/shared_segmented_switch.dart';
import 'package:deenora/features/settings/muadhin/widgets/option_muadhin/muadhin_selection_bottom_sheet.dart';
import 'package:deenora/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'SettingsScreen renders Muadhin option and opens BottomSheet on tap',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Verify Settings Screen elements in English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Select Muadhin'), findsOneWidget);
      expect(find.text('Choose preferred Adhan and Iqama audio'), findsOneWidget);

      // Tap on Muadhin option
      await tester.tap(find.text('Select Muadhin'));
      await tester.pumpAndSettle();

      // Verify MuadhinSelectionBottomSheet is opened
      expect(find.byType(MuadhinSelectionBottomSheet), findsOneWidget);
      expect(find.text('Listen and choose Adhan or Iqama audio'), findsOneWidget);
      expect(find.byType(SharedSegmentedSwitch), findsOneWidget);
      expect(find.text('Adhan'), findsWidgets);
      expect(find.text('Iqama'), findsWidgets);

      // Tap on Iqama tab inside the bottom sheet
      await tester.tap(find.text('Iqama').first);
      await tester.pumpAndSettle();

      // Close the bottom sheet via close button
      final closeBtn = find.byIcon(Icons.close_rounded);
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      // BottomSheet is dismissed and we are back on SettingsScreen
      expect(find.byType(MuadhinSelectionBottomSheet), findsNothing);
      expect(find.text('Select Muadhin'), findsOneWidget);
    },
  );
}
