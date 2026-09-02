import 'package:deenora/features/Quran/controller/quran_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/surah_model.dart';
import '../../../core/skeleton/quran_skeleton_screen.dart';
import '../../../core/widget/error/error_screen.dart';
import 'details/surah_details_screen.dart';

class QuranReading extends StatelessWidget {
  const QuranReading({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuranController>(
      create: (BuildContext context) => QuranController()..init(),
      child: Scaffold(
        body: Consumer<QuranController>(
          builder: (context, controller, Widget? child) {
            return FutureBuilder<List<SurahModel>>(
              future: controller.futureQuran,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return QuranSkeletonScreen();
                }

                if (snapshot.hasError) {
                  return AppErrorScreen(
                    type: AppErrorType.serverError,
                    onRetry: () => controller.init(),
                  );
                }

                final quran = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: quran.length,
                  itemBuilder: (context, index) {
                    final surah = quran[index];
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
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SurahDetailsScreen(surah: surah),
                              ),
                            );
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
                                      '${surah.number}',
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
                                        surah.englishName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B1B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${surah.englishNameTranslation} • ${surah.ayahs.length} verses',
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
                                    color: surah.revelationType == 'Meccan'
                                        ? Colors.orange.withValues(alpha: 0.12)
                                        : Colors.blue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    surah.revelationType,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: surah.revelationType == 'Meccan'
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
