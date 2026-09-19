import 'package:deenora/features/mosque/feature_cards/feature_cards_section.dart';
import 'package:deenora/features/tasbeeh/tasbeeh_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Tapping Tasbeeh FeatureCard pushes TasbeehScreen and back button pops',
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

      // Verify TasbeehScreen is now displayed
      expect(find.byType(TasbeehScreen), findsOneWidget);
      expect(find.text('Tasbeeh'), findsWidgets); // In AppBar and/or card

      // Tap back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify back on Mosque / FeatureCardsSection screen
      expect(find.byType(TasbeehScreen), findsNothing);
      expect(find.byType(FeatureCardsSection), findsOneWidget);
    },
  );
}
