import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Quran/reading/utils/quran_navigation_helper.dart';
import '../controllers/verse_of_the_day_controller.dart';
import '../models/verse_of_the_day_model.dart';
import 'verse_card_content.dart';
import 'verse_card_error.dart';
import 'verse_card_skeleton.dart';

class VerseOfTheDayCard extends StatelessWidget {
  final void Function(VerseOfTheDayModel verse)? onCardTap;
  final VerseOfTheDayController? controller;

  const VerseOfTheDayCard({super.key, this.onCardTap, this.controller});

  void _handleTap(BuildContext context, VerseOfTheDayModel verse) {
    if (onCardTap != null) {
      onCardTap!(verse);
      return;
    }

    QuranNavigationHelper.navigateToSurah(
      context,
      surahNumber: verse.surahNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<VerseOfTheDayController>.value(
        value: controller!,
        child: _buildConsumer(context),
      );
    }

    VerseOfTheDayController? ancestorController;
    try {
      ancestorController = Provider.of<VerseOfTheDayController>(
        context,
        listen: false,
      );
    } catch (_) {
      ancestorController = null;
    }

    if (ancestorController != null) {
      return _buildConsumer(context);
    }

    return ChangeNotifierProvider<VerseOfTheDayController>(
      create: (_) => VerseOfTheDayController()..init(),
      child: _buildConsumer(context),
    );
  }

  Widget _buildConsumer(BuildContext context) {
    return Consumer<VerseOfTheDayController>(
      builder: (context, c, _) => FutureBuilder<VerseOfTheDayModel>(
        future: c.verseOfTheDayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const VerseCardSkeleton();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return VerseCardError(onRetry: c.retry);
          }

          return VerseCardContent(
            verse: snapshot.data!,
            onTap: () => _handleTap(context, snapshot.data!),
          );
        },
      ),
    );
  }
}
