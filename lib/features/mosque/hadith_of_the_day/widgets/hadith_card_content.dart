import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widget/share_widget/icon_text_widget.dart';
import '../models/hadith_day_model.dart';

class HadithCardContent extends StatelessWidget {
  final HadithDayModel hadith;
  final VoidCallback onTap;

  const HadithCardContent({
    super.key,
    required this.hadith,
    required this.onTap,
  });

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
            color: AppColors.amberGold.withValues(alpha: 0.18),
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
                  iconColor: AppColors.darkGold,
                  iconSize: 14,
                  text: 'Hadith of the Day',
                  textStyle: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: AppColors.darkGold),
                  spacing: 6,
                ),

                const SizedBox(height: 15),

                // Arabic Hadith text: « hadith text »
                Text(
                  '« ${hadith.textArabic} »',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                // Attribution: — Collection • Hadith Number —
                Text(
                  '— ${_formatCollection(hadith.collection)} • Hadith ${hadith.hadithNumber} —',
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

  String _formatCollection(String slug) {
    switch (slug.toLowerCase().trim()) {
      case 'bukhari':
        return 'Sahih al-Bukhari';
      case 'muslim':
        return 'Sahih Muslim';
      case 'nasai':
        return "Sunan an-Nasa'i";
      case 'tirmidhi':
        return "Jami` at-Tirmidhi";
      case 'abudawud':
        return 'Sunan Abi Dawud';
      case 'ibnmajah':
        return 'Sunan Ibn Majah';
      case 'malik':
        return 'Muwatta Malik';
      case 'ahmad':
        return 'Musnad Ahmad';
      default:
        if (slug.isEmpty) return 'Hadith';
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }
}
