import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/audio_player_coordinator.dart';
import '../widgets/main_player_controls_card.dart';
import '../widgets/player_error_view.dart';
import '../widgets/sleep_timer_and_extras_card.dart';
import '../widgets/sleep_timer_sheet.dart';
import '../widgets/surah_artwork_card.dart';
import '../widgets/surah_sequence_bar.dart';

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            Selector<
              AudioPlayerCoordinator,
              ({String englishName, String reciterName})
            >(
              selector: (_, c) => (
                englishName: c.currentSurah.englishName,
                reciterName: c.reciter.name,
              ),
              builder: (context, info, _) {
                return Column(
                  children: [
                    Text(
                      info.englishName,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.reciterName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
      body: Consumer<AudioPlayerCoordinator>(
        builder: (context, coordinator, _) {
          if (coordinator.hasError) {
            return PlayerErrorView(
              errorMessage: coordinator.errorMessage,
              onRetry: () => coordinator.retry(),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SurahArtworkCard(
                        surah: coordinator.currentSurah,
                        reciter: coordinator.reciter,
                      ),
                      const SizedBox(height: 30),
                      SurahSequenceBar(
                        hasPrevious: coordinator.hasPrevious,
                        previousSurah: coordinator.previousSurah,
                        onPreviousPressed: coordinator.canPlayPrevious
                            ? () => coordinator.playPreviousSurah()
                            : null,
                        hasNext: coordinator.hasNext,
                        nextSurah: coordinator.nextSurah,
                        onNextPressed: coordinator.canPlayNext
                            ? () => coordinator.playNextSurah()
                            : null,
                      ),
                      const SizedBox(height: 30),
                      MainPlayerControlsCard(coordinator: coordinator),
                      const SizedBox(height: 30),
                      SleepTimerAndExtrasCard(
                        isSleepTimerActive: coordinator.isSleepTimerActive,
                        sleepTimerFormatted: coordinator.sleepTimerFormatted,
                        onSleepTimerTap: () => SleepTimerSheet.show(
                          context,
                          onTimerComplete: () =>
                              coordinator.playerController.pause(),
                        ),
                        onCancelSleepTimer: () =>
                            coordinator.cancelSleepTimer(),
                        isLooping: coordinator.isLoopingSurah,
                        onToggleLoop: () => coordinator.toggleLoop(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
