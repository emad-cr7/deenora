import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/skeleton/quran_skeleton_screen.dart';
import '../../../../../core/widget/error/error_screen.dart';
import '../../../../../core/widget/share_widget/future_builder_share.dart';
import '../../../../../core/widget/share_widget/surah_list_item_card.dart';
import '../../../controller/quran_controller.dart';
import '../../../reading/models/surah_model.dart';
import '../audio_player/view/audio_player_screen.dart';
import '../audio_player/search/audio_search_view.dart';
import '../../models_listening/reciter_model.dart';

class SurahNameListening extends StatelessWidget {
  final ReciterModel reciter;

  const SurahNameListening({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuranController>(
      create: (BuildContext context) =>
          QuranController()..initSurah(reciterId: reciter.id),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(reciter.imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                reciter.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Consumer<QuranController>(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search Quran',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (searchCtx) => AudioSearchView(
                          currentReciter: reciter,
                          onSurahSelected: (selectedSurah) async {
                            final audioUrl = await controller.getAudioUrl(
                              selectedSurah.number,
                            );
                            if (audioUrl == null) {
                              if (searchCtx.mounted) {
                                ScaffoldMessenger.of(searchCtx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'التلاوة دي مش متاحة للشيخ ده',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            final audioMap =
                                await controller.futureReciterAudio;
                            List<SurahModel>? surahList;
                            try {
                              surahList = await controller.futureQuran;
                            } catch (_) {}

                            if (searchCtx.mounted) {
                              Navigator.pushReplacement(
                                searchCtx,
                                MaterialPageRoute(
                                  builder: (_) => AudioPlayerScreen(
                                    surah: selectedSurah,
                                    reciter: reciter,
                                    audioUrl: audioUrl,
                                    surahList: surahList,
                                    audioMap: audioMap,
                                  ),
                                ),
                              );
                            }
                          },
                          onReciterSelected: (selectedReciter) {
                            Navigator.pushReplacement(
                              searchCtx,
                              MaterialPageRoute(
                                builder: (_) => SurahNameListening(
                                  reciter: selectedReciter,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<QuranController>(
          builder: (context, controller, _) {
            return FutureBuilderShare<List<SurahModel>>(
              future: controller.futureQuran,
              loading: const QuranSkeletonScreen(),
              error: AppErrorScreen(
                type: AppErrorType.serverError,
                onRetry: () => controller.initSurah(reciterId: reciter.id),
              ),
              builder: (quran) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: quran.length,
                  itemBuilder: (context, index) {
                    final surah = quran[index];

                    return SurahListItemCard(
                      surah: surah,
                      onTap: () async {
                        final audioUrl = await controller.getAudioUrl(
                          surah.number,
                        );
                        if (audioUrl == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('التلاوة دي مش متاحة للشيخ ده'),
                              ),
                            );
                          }
                          return;
                        }
                        final audioMap = await controller.futureReciterAudio;
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioPlayerScreen(
                                surah: surah,
                                reciter: reciter,
                                audioUrl: audioUrl,
                                surahList: quran,
                                audioMap: audioMap,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
