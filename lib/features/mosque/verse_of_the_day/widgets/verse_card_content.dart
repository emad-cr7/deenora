import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widget/share_widget/icon_text_widget.dart';
import '../models/verse_day_model.dart';

/// Pure presentation widget displaying the verse card content:
/// header, Arabic verse text with brackets, and Surah / Ayah reference.
class VerseCardContent extends StatelessWidget {
  final VerseDayModel verse;
  final VoidCallback onTap;

  const VerseCardContent({super.key, required this.verse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTextWidget(
                  icon: FlutterIslamicIcons.islam,
                  iconColor: AppColors.primary,
                  iconSize: 14,
                  text: 'Ayah of the Day',
                  textStyle: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                  spacing: 6,
                ),

                const SizedBox(height: 15),

                // Arabic Quran verse: ﴿ verse text ﴾
                Text(
                  '﴿ ${verse.text} ﴾',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                Text(
                  '— ${verse.surahEnglishName} • Ayah ${verse.numberInSurah} —',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
