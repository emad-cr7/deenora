import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widget/error/verse_card_error.dart';
import '../../../../core/skeleton/mosque/widegets/verse_card_skeleton.dart';
import '../../../../core/widget/share_widget/future_builder_share.dart';

import '../controllers/verse_day_controller.dart';
import '../models/verse_day_model.dart';
import 'verse_card_content.dart';

class VerseDayCard extends StatelessWidget {
  final void Function(VerseDayModel verse)? onCardTap;

  const VerseDayCard({super.key, this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VerseDayController>();

    return FutureBuilderShare<VerseDayModel>(
      future: controller.verseOfTheDayFuture,
      loading: const VerseCardSkeleton(),
      error: VerseCardError(onRetry: controller.retry),
      builder: (verse) {
        return VerseCardContent(
          verse: verse,
          onTap: () {
            if (onCardTap != null) {
              onCardTap!(verse);
              return;
            }
            controller.navigateToVerse(verse);
          },
        );
      },
    );
  }
}
