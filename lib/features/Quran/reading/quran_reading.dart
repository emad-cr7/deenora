import 'package:deenora/features/Quran/controller/quran_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/skeleton/quran_skeleton_screen.dart';
import '../../../core/widget/error/error_screen.dart';
import '../../../core/widget/share_widget/future_builder_share.dart';
import '../../../core/widget/share_widget/surah_list_item_card.dart';
import 'details/surah_details_screen.dart';
import 'models/surah_model.dart';

class QuranReading extends StatelessWidget {
  const QuranReading({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuranController>(
      create: (BuildContext context) => QuranController()..initSurahQuran(),
      child: Scaffold(
        body: Consumer<QuranController>(
          builder: (context, controller, Widget? child) {
            return FutureBuilderShare<List<SurahModel>>(
              future: controller.futureQuran,
              loading: const QuranSkeletonScreen(),
              error: AppErrorScreen(
                type: AppErrorType.serverError,
                onRetry: () => controller.initSurahQuran(),
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
