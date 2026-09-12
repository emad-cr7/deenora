import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/audio_player_controller.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/audio_player_view.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/main_player_controls_card.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/player_controls_row.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/player_progress_bar.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/sleep_timer_and_extras_card.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/surah_artwork_card.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/widgets/surah_sequence_bar.dart';
import 'package:deenora/features/Quran/reading/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AudioPlayerView renders all components cleanly', (tester) async {
    final testSurah = SurahModel(
      number: 1,
      name: 'سورة الفاتحة',
      englishName: 'Al-Faatiha',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: [],
    );

    const testReciter = ReciterModel(
      id: 51,
      name: 'Abdul Basit Abdus Samad',
      imagePath: 'assets/images/Abdul Basit Abdus Samad.png',
      country: 'Egypt',
      birthDate: '1927',
      description: 'Reciter',
    );

    final controller = AudioPlayerController(
      surah: testSurah,
      reciter: testReciter,
      audioUrl: 'https://example.com/audio.mp3',
      surahList: [testSurah],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AudioPlayerController>.value(
          value: controller,
          child: const AudioPlayerView(),
        ),
      ),
    );

    expect(find.byType(AudioPlayerView), findsOneWidget);
    expect(find.byType(SurahArtworkCard), findsOneWidget);
    expect(find.byType(SurahSequenceBar), findsOneWidget);
    expect(find.byType(MainPlayerControlsCard), findsOneWidget);
    expect(find.byType(PlayerProgressBar), findsOneWidget);
    expect(find.byType(PlayerControlsRow), findsOneWidget);
    expect(find.byType(SleepTimerAndExtrasCard), findsOneWidget);
  });
}
