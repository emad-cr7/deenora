import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widget/share_widget/container_share.dart';
import '../../../../reading/models/surah_model.dart';
import '../../../models_listening/reciter_model.dart';

// بطاقة العرض الفنية للسورة الحالية ومعلومات القارئ بتصميم إسلامي
class SurahArtworkCard extends StatelessWidget {
  final SurahModel surah;
  final ReciterModel reciter;

  const SurahArtworkCard({
    super.key,
    required this.surah,
    required this.reciter,
  });

  static const Color primaryColor = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryDark],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط الشارات العلوية (نوع النزول ورقم السورة)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // شارة نوع النزول (مكية / مدنية)
              ContainerShare(
                icon: surah.revelationType == 'Meccan'
                    ? Icons.wb_sunny_rounded
                    : Icons.location_city_rounded,
                text: surah.revelationType,
              ),
              // شارة رقم السورة
              ContainerShare(
                icon: FlutterIslamicIcons.solidQuran2,
                text: 'Surah ${surah.number}',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // صورة القارئ داخل إطار دائري متوهج
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              backgroundImage: AssetImage(reciter.imagePath),
            ),
          ),
          const SizedBox(height: 10),

          // اسم السورة بالرسم العربي
          Text(
            surah.englishName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            '${surah.ayahs.length} verses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
