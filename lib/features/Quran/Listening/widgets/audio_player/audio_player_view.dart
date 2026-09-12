import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio_player_controller.dart';
import 'widgets/main_player_controls_card.dart';
import 'widgets/player_error_view.dart';
import 'widgets/sleep_timer_and_extras_card.dart';
import 'widgets/sleep_timer_sheet.dart';
import 'widgets/surah_artwork_card.dart';
import 'widgets/surah_sequence_bar.dart';

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              controller.currentSurah.englishName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              controller.reciter.name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: controller.hasError
          ? PlayerErrorView(
              errorMessage: controller.errorMessage,
              onRetry: () => controller.retry(),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 70,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SurahArtworkCard(
                          surah: controller.currentSurah,
                          reciter: controller.reciter,
                        ),
                        SizedBox(height: 30,),
                        SurahSequenceBar(
                          hasPrevious: controller.hasPrevious,
                          previousSurah: controller.previousSurah,
                          onPreviousPressed: controller.hasPrevious &&
                                  !controller.isLoadingSurah
                              ? () => controller.playPreviousSurah()
                              : null,
                          hasNext: controller.hasNext,
                          nextSurah: controller.nextSurah,
                          onNextPressed: controller.hasNext &&
                                  !controller.isLoadingSurah
                              ? () => controller.playNextSurah()
                              : null,
                        ),
                        SizedBox(height: 30,),

                        MainPlayerControlsCard(controller: controller),
                        SizedBox(height: 30,),
                        SleepTimerAndExtrasCard(
                          isSleepTimerActive:
                              controller.isSleepTimerActive,
                          sleepTimerFormatted:
                              controller.sleepTimerFormatted,
                          onSleepTimerTap: () =>
                              SleepTimerSheet.show(context),
                          onCancelSleepTimer: () =>
                              controller.cancelSleepTimer(),
                          isLooping: controller.isLoopingSurah,
                          onToggleLoop: () => controller.toggleLoop(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}