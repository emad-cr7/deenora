import 'package:hive_ce/hive.dart';
import 'azkar_model.dart';

part 'azekr_category.g.dart';

@HiveType(typeId: 4)
class AzekrCategory {
  @HiveField(0)
  final List<AzkarModel> morningAzkar;
  @HiveField(1)
  final List<AzkarModel> eveningAzkar;
  @HiveField(2)
  final List<AzkarModel> prayerAzkar;
  @HiveField(3)
  final List<AzkarModel> prayerLaterAzkar;
  @HiveField(4)
  final List<AzkarModel> sleepAzkar;
  @HiveField(5)
  final List<AzkarModel> wakeUpAzkar;
  @HiveField(6)
  final List<AzkarModel> mosqueAzkar;
  @HiveField(7)
  final List<AzkarModel> miscellaneousAzkar;
  @HiveField(8)
  final List<AzkarModel> adhanAzkar;
  @HiveField(9)
  final List<AzkarModel> wuduAzkar;
  @HiveField(10)
  final List<AzkarModel> homeAzkar;
  @HiveField(11)
  final List<AzkarModel> khalaAzkar;
  @HiveField(12)
  final List<AzkarModel> foodAzkar;
  @HiveField(13)
  final List<AzkarModel> hajjAndUmrahAzkar;

  AzekrCategory({
    required this.morningAzkar,
    required this.eveningAzkar,
    required this.prayerAzkar,
    required this.prayerLaterAzkar,
    required this.sleepAzkar,
    required this.wakeUpAzkar,
    required this.mosqueAzkar,
    required this.miscellaneousAzkar,
    required this.adhanAzkar,
    required this.wuduAzkar,
    required this.homeAzkar,
    required this.khalaAzkar,
    required this.foodAzkar,
    required this.hajjAndUmrahAzkar,
  });

  factory AzekrCategory.fromJson(Map<String, dynamic> json) {
    List<AzkarModel> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list.map((e) => AzkarModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return AzekrCategory(
      morningAzkar: parseList('morning_azkar'),
      eveningAzkar: parseList('evening_azkar'),
      prayerAzkar: parseList('prayer_azkar'),
      prayerLaterAzkar: parseList('prayer_later_azkar'),
      sleepAzkar: parseList('sleep_azkar'),
      wakeUpAzkar: parseList('wake_up_azkar'),
      mosqueAzkar: parseList('mosque_azkar'),
      miscellaneousAzkar: parseList('miscellaneous_azkar'),
      adhanAzkar: parseList('adhan_azkar'),
      wuduAzkar: parseList('wudu_azkar'),
      homeAzkar: parseList('home_azkar'),
      khalaAzkar: parseList('khala_azkar'),
      foodAzkar: parseList('food_azkar'),
      hajjAndUmrahAzkar: parseList('hajj_and_umrah_azkar'),
    );
  }
}