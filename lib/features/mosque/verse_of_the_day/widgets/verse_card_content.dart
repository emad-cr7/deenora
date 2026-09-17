import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widget/share_widget/icon_text_widget.dart';
import '../models/verse_of_the_day_model.dart';

/// Pure presentation widget displaying the verse card content:
/// header, Arabic verse text with brackets, and Surah / Ayah reference.
class VerseCardContent extends StatelessWidget {
  final VerseOfTheDayModel verse;
  final VoidCallback onTap;

  const VerseCardContent({super.key, required this.verse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EBE7), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withValues(alpha: 0.12),
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
                // Header: ✦ Ayah of the Day (reusing shared IconTextWidget)
                const IconTextWidget(
                  icon: Icons.auto_awesome,
                  iconColor: AppColors.primary,
                  iconSize: 14,
                  text: 'Ayah of the Day',
                  textStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.1,
                  ),
                  spacing: 6,
                ),

                const SizedBox(height: 12),

                // Arabic Quran verse: ﴿ verse text ﴾
                Text(
                  '﴿ ${verse.text} ﴾',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2923),
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 12),

                // Reference: — Surah Name • Ayah X —
                Text(
                  '— ${verse.displaySurahName} • Ayah ${verse.numberInSurah} —',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF71807B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
