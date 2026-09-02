import 'package:deenora/features/Quran/controller/quran_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/surah_model.dart';
import '../../../core/skeleton/quran_skeleton_screen.dart';
import '../../../core/widget/error/error_screen.dart';
import '../../../core/widget/share_widget/surah_list_share.dart';
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
                    return SurahListShare(
                      surah: surah,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SurahDetailsScreen(surah: surah),
                          ),
                        );
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