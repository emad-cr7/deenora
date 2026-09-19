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
      create: (_) => VerseOfTheDayController()..loadVerseOfTheDay(),
      child: _buildConsumer(context),
    );
  }

  Widget _buildConsumer(BuildContext context) {
    return Consumer<VerseOfTheDayController>(
      builder: (context, c, _) => _buildBody(context, c),
    );
  }

  Widget _buildBody(BuildContext context, VerseOfTheDayController controller) {
    if (controller.isLoading && controller.verse == null) {
      return const VerseCardSkeleton();
    }

    if (controller.hasError && controller.verse == null) {
      return VerseCardError(
        onRetry: () {
          controller.loadVerseOfTheDay(forceRefresh: true);
        },
      );
    }

    final verse = controller.verse;

    if (verse == null) {
      return const SizedBox.shrink();
    }

    return VerseCardContent(
      verse: verse,
      onTap: () => _handleTap(context, verse),
    );
  }
}
