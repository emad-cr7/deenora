import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
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

  static const Color primaryColor = Color(0xFF1B5E4F);
  static const Color primaryDark = Color(0xFF103D33);

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      surah.revelationType == 'Meccan'
                          ? Icons.wb_sunny_rounded
                          : Icons.location_city_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      surah.revelationType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // شارة رقم السورة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FlutterIslamicIcons.solidQuran2,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Surah ${surah.number}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
            surah.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          // ترجمة اسم السورة وعدد الآيات
          Text(
            '${surah.englishNameTranslation} • ${surah.ayahs.length} verses',
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
