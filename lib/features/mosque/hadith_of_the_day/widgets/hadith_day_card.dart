import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/skeleton/mosque/widegets/hadith_card_skeleton.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widget/error/verse_card_error.dart';
import '../../../../core/widget/share_widget/future_builder_share.dart';
import '../controllers/hadith_day_controller.dart';
import '../models/hadith_day_model.dart';
import 'hadith_card_content.dart';
import 'hadith_details_bottom_sheet.dart';

class HadithDayCard extends StatelessWidget {
  final void Function(HadithDayModel hadith)? onCardTap;

  const HadithDayCard({super.key, this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HadithDayController>();

    return FutureBuilderShare<HadithDayModel>(
      future: controller.hadithOfTheDayFuture,
      loading: const HadithCardSkeleton(),
      error: VerseCardError(
        onRetry: controller.retry,
        message: 'Unable to load daily hadith',
        color: AppColors.darkGold,
      ),
      builder: (hadith) {
        return HadithCardContent(hadith: hadith);
      },
    );
  }
}
