import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/view/audio_player_view.dart';
import 'package:deenora/features/Quran/Listening/widgets/mini_player/mini_player.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSurah1 = SurahModel(
    number: 1,
    name: 'سورة الفاتحة',
    englishName: 'Al-Faatiha',
    englishNameTranslation: 'The Opening',
    revelationType: 'Meccan',
    ayahs: const [],
  );

  final testSurah2 = SurahModel(
    number: 2,
    name: 'سورة البقرة',
    englishName: 'Al-Baqara',
    englishNameTranslation: 'The Cow',
    revelationType: 'Medinan',
    ayahs: const [],
  );

  const testReciter = ReciterModel(
    id: 51,
    name: 'Abdul Basit Abdus Samad',
    imagePath: 'assets/images/Abdul Basit Abdus Samad.png',
    country: 'Egypt',
    birthDate: '1927',
    description: 'Reciter',
  );

  Widget createTestWidget(AudioPlayerCoordinator coordinator) {
    return ChangeNotifierProvider<AudioPlayerCoordinator>.value(
      value: coordinator,
      child: const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Page Content')),
          bottomNavigationBar: MiniPlayer(),
        ),
      ),
    );
  }

  testWidgets('MiniPlayer is hidden when hasActiveSession is false', (tester) async {
    final coordinator = AudioPlayerCoordinator();

    await tester.pumpWidget(createTestWidget(coordinator));
    await tester.pump();

    expect(coordinator.hasActiveSession, isFalse);
    expect(find.byType(MiniPlayerView), findsNothing);

    coordinator.dispose();
  });

  testWidgets('MiniPlayer is visible and displays surah, reciter, controls, progress', (tester) async {
    final coordinator = AudioPlayerCoordinator(
      initialSurah: testSurah1,
      initialReciter: testReciter,
      initialAudioUrl: 'https://example.com/001.mp3',
      surahList: [testSurah1, testSurah2],
    );

    await tester.pumpWidget(createTestWidget(coordinator));
    await tester.pump(const Duration(milliseconds: 350));

    expect(coordinator.hasActiveSession, isTrue);
    expect(find.byType(MiniPlayerView), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('Abdul Basit Abdus Samad'), findsOneWidget);
    expect(find.byType(MiniPlayerAvatar), findsOneWidget);
    expect(find.byType(MiniPlayerControls), findsOneWidget);
    expect(find.byType(MiniPlayerProgress), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

    coordinator.dispose();
  });

  testWidgets('Tapping Next surah button updates to next surah', (tester) async {
    final coordinator = AudioPlayerCoordinator(
      initialSurah: testSurah1,
      initialReciter: testReciter,
      initialAudioUrl: 'https://example.com/001.mp3',
      surahList: [testSurah1, testSurah2],
      audioMap: {
        1: 'https://example.com/001.mp3',
        2: 'https://example.com/002.mp3',
      },
    );

    await tester.pumpWidget(createTestWidget(coordinator));
    await tester.pump(const Duration(milliseconds: 350));

    expect(coordinator.currentSurah.number, 1);
    expect(find.text('Al-Faatiha'), findsOneWidget);

    // Tap the next button
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump(const Duration(milliseconds: 350));

    expect(coordinator.currentSurah.number, 2);
    expect(find.text('Al-Baqara'), findsOneWidget);

    coordinator.dispose();
  });

  testWidgets('Tapping MiniPlayerView opens AudioPlayerView', (tester) async {
    final coordinator = AudioPlayerCoordinator(
      initialSurah: testSurah1,
      initialReciter: testReciter,
      initialAudioUrl: 'https://example.com/001.mp3',
      surahList: [testSurah1, testSurah2],
    );

    await tester.pumpWidget(createTestWidget(coordinator));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(AudioPlayerView), findsNothing);

    // Tap on the MiniPlayer card
    await tester.tap(find.byType(MiniPlayerView));
    await tester.pumpAndSettle();

    expect(find.byType(AudioPlayerView), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsAtLeast(1));

    coordinator.dispose();
  });
}
