import 'package:flutter/material.dart';
import '../details/surah_details_screen.dart';
import '../repository/quran_repository.dart';

/// Helper utility to handle Quran reading navigation from any feature.
class QuranNavigationHelper {
  /// Resolves the [SurahModel] for [surahNumber] and pushes [SurahDetailsScreen].
  static Future<void> navigateToSurah(
    BuildContext context, {
    required int surahNumber,
    QuranRepository? repository,
  }) async {
    final repo = repository ?? QuranRepository();

    try {
      final surah = await repo.getSurahByNumber(surahNumber);
      if (!context.mounted) return;

      if (surah != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahDetailsScreen(surah: surah),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Surah. Please check connection.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
