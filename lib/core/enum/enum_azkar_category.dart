import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'azkar_model/azkar_model.dart';
import 'azkar_model/zekr_category.dart';

enum AzkarCategory {
  morning(
    arabicName: 'أذكار الصباح',
    englishName: 'Morning Azkar',
    icon: Icons.wb_sunny_outlined,
  ),
  evening(
    arabicName: 'أذكار المساء',
    englishName: 'Evening Azkar',
    icon: FlutterIslamicIcons.solidCrescentMoon,
  ),
  prayer(
    arabicName: 'أذكار قبل الصلاة',
    englishName: 'Prayer Azkar',
    icon: FlutterIslamicIcons.solidPrayer,
  ),
  prayerLater(
    arabicName: 'أذكار بعد الصلاة',
    englishName: 'After Prayer Azkar',
    icon: FlutterIslamicIcons.solidTasbih,
  ),
  sleep(
    arabicName: 'أذكار النوم',
    englishName: 'Sleep Azkar',
    icon: FlutterIslamicIcons.crescentMoon, // outline، عشان تتفرق بصريًا عن المساء
  ),
  wakeUp(
    arabicName: 'أذكار الاستيقاظ',
    englishName: 'Wake Up Azkar',
    icon: Icons.alarm,
  ),
  mosque(
    arabicName: 'أذكار المسجد',
    englishName: 'Mosque Azkar',
    icon: FlutterIslamicIcons.solidMosque,
  ),
  adhan(
    arabicName: 'أذكار الأذان',
    englishName: 'Adhan Azkar',
    icon: FlutterIslamicIcons.solidTakbir,
  ),
  wudu(
    arabicName: 'أذكار الوضوء',
    englishName: 'Wudu Azkar',
    icon: FlutterIslamicIcons.solidWudhu,
  ),
  home(
    arabicName: 'أذكار المنزل',
    englishName: 'Home Azkar',
    icon: FlutterIslamicIcons.solidFamily,
  ),
  khala(
    arabicName: 'أذكار الخلاء',
    englishName: 'Khala Azkar',
    icon: Icons.wc,
  ),
  food(
    arabicName: 'أذكار الطعام',
    englishName: 'Food Azkar',
    icon: Icons.restaurant,
  ),
  hajjAndUmrah(
    arabicName: 'أذكار الحج والعمرة',
    englishName: 'Hajj & Umrah Azkar',
    icon: FlutterIslamicIcons.solidKaaba,
  ),
  miscellaneous(
    arabicName: 'أذكار متفرقة',
    englishName: 'Miscellaneous Azkar',
    icon: Icons.menu_book_outlined,
  );

  const AzkarCategory({
    required this.arabicName,
    required this.englishName,
    required this.icon,
  });

  final String arabicName;
  final String englishName;
  final IconData icon;

  List<AzkarModel> getList(ZekrCategory model) {
    switch (this) {
      case AzkarCategory.morning:
        return model.morningAzkar;
      case AzkarCategory.evening:
        return model.eveningAzkar;
      case AzkarCategory.prayer:
        return model.prayerAzkar;
      case AzkarCategory.prayerLater:
        return model.prayerLaterAzkar;
      case AzkarCategory.sleep:
        return model.sleepAzkar;
      case AzkarCategory.wakeUp:
        return model.wakeUpAzkar;
      case AzkarCategory.mosque:
        return model.mosqueAzkar;
      case AzkarCategory.adhan:
        return model.adhanAzkar;
      case AzkarCategory.wudu:
        return model.wuduAzkar;
      case AzkarCategory.home:
        return model.homeAzkar;
      case AzkarCategory.khala:
        return model.khalaAzkar;
      case AzkarCategory.food:
        return model.foodAzkar;
      case AzkarCategory.hajjAndUmrah:
        return model.hajjAndUmrahAzkar;
      case AzkarCategory.miscellaneous:
        return model.miscellaneousAzkar;
    }
  }
}
