import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/skeleton/quran_skeleton_screen.dart';
import '../../../../../core/widget/error/error_screen.dart';
import '../../../controller/quran_controller.dart';
import '../../models_listening/name_surah_model.dart';
import '../audio_player/audio_player_screen.dart';
import '../../models_listening/reciter_model.dart';

class SurahNameListening extends StatelessWidget {
  final ReciterModel reciter;
  const SurahNameListening({super.key, required this.reciter});
  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuranController>(
      create: (BuildContext context) =>
          QuranController()..initSurah(reciterId: reciter.id),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Consumer<QuranController>(
          builder: (context, controller, _) {
            return FutureBuilder<List<NameSurahModel>>(
              future: controller.futureChapters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return QuranSkeletonScreen();
                }

                if (snapshot.hasError) {
                  return AppErrorScreen(type: AppErrorType.serverError);
                }

                final List<NameSurahModel> chapters = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    final bool isMeccan = chapter.revelationPlace == 'makkah';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(27),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(27),
                          onTap: () async {
                            final audioMap = await controller.futureReciterAudio;
                            final audioUrl = audioMap?[chapter.id];
                            if (audioUrl == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'التلاوة دي مش متاحة للشيخ ده',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AudioPlayerScreen(
                                    chapter: chapter,
                                    reciter: reciter,
                                    audioUrl: audioUrl,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1B5E4F,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${chapter.id}',
                                      style: const TextStyle(
                                        color: Color(0xFF1B5E4F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chapter.nameSimple,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B1B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${chapter.versesCount} verses',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMeccan
                                        ? Colors.orange.withValues(alpha: 0.12)
                                        : Colors.blue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isMeccan ? 'Meccan' : 'Medinan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isMeccan
                                          ? Colors.orange[900]
                                          : Colors.blue[900],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
