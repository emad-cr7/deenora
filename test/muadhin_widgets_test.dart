import 'package:deenora/core/widget/share_widget/shared_segmented_switch.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_player_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'package:deenora/features/settings/muadhin/widgets/muadhin_card.dart';
import 'package:deenora/features/settings/muadhin/widgets/muadhin_inline_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleAdhan = MuadhinAudioModel(
    type: 'adhan',
    isAvailable: true,
    audioUrl: 'https://example.com/adhan.mp3',
    description: 'تسجيل الأذان من الحرم المكي الشريف',
    apiUrl: 'https://example.com/api/adhan',
  );

  const sampleIqama = MuadhinAudioModel(
    type: 'iqama',
    isAvailable: true,
    audioUrl: 'https://example.com/iqama.mp3',
    description: 'تسجيل الإقامة',
    apiUrl: 'https://example.com/api/iqama',
  );

  final sampleMuadhin = MuadhinModel(
    id: 'test-muadhin',
    nameEn: 'Sheikh Test',
    nameAr: 'الشيخ فاروق حضراوي',
    category: 'Muezzin',
    categoryAr: 'مؤذن الحرم المكي',
    isMosque: false,
    locationEn: 'Makkah',
    locationAr: 'المسجد الحرام، مكة المكرمة',
    region: 'Makkah',
    imageUrl: '',
    adhan: sampleAdhan,
    iqama: sampleIqama,
  );

  group('Muadhin Switch Tests', () {
    testWidgets('renders Adhan and Iqama tabs with SharedSegmentedSwitch', (
      tester,
    ) async {
      final tabController = TabController(
        length: 2,
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SharedSegmentedSwitch(
              controller: tabController,
              titles: const ['Adhan', 'Iqama'],
              icons: const [
                Icons.volume_up_rounded,
                Icons.notifications_active_rounded,
              ],
            ),
          ),
        ),
      );

      expect(find.text('Adhan'), findsWidgets);
      expect(find.text('Iqama'), findsWidgets);
    });
  });

  group('MuadhinCard & Inline Player Tests', () {
    testWidgets('renders card info and shows inline player when expanded', (
      tester,
    ) async {
      bool isExpanded = false;
      final playerController = MuadhinPlayerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MuadhinCard(
                  muadhin: sampleMuadhin,
                  selectedType: MuadhinType.adhan,
                  isExpanded: isExpanded,
                  isPlaying: false,
                  playerController: playerController,
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Card details rendered from API data (kept in original language)
      expect(find.text('الشيخ فاروق حضراوي'), findsOneWidget);
      expect(find.text('مؤذن الحرم المكي'), findsOneWidget);
      expect(find.text('المسجد الحرام، مكة المكرمة'), findsOneWidget);

      // Inline player should NOT be visible when not expanded
      expect(find.byType(MuadhinInlinePlayer), findsNothing);

      // Tap on card to expand
      await tester.tap(find.text('الشيخ فاروق حضراوي'));
      await tester.pumpAndSettle();

      // Inline player should NOW be visible inside the card
      expect(isExpanded, isTrue);
      expect(find.byType(MuadhinInlinePlayer), findsOneWidget);
      expect(find.text('تسجيل الأذان من الحرم المكي الشريف'), findsOneWidget);

      playerController.dispose();
    });
  });
}
