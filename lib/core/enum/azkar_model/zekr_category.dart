import 'azkar_model.dart';

class ZekrCategory {
  final List<AzkarModel> morningAzkar;
  final List<AzkarModel> eveningAzkar;
  final List<AzkarModel> prayerAzkar;
  final List<AzkarModel> prayerLaterAzkar;
  final List<AzkarModel> sleepAzkar;
  final List<AzkarModel> wakeUpAzkar;
  final List<AzkarModel> mosqueAzkar;
  final List<AzkarModel> miscellaneousAzkar;
  final List<AzkarModel> adhanAzkar;
  final List<AzkarModel> wuduAzkar;
  final List<AzkarModel> homeAzkar;
  final List<AzkarModel> khalaAzkar;
  final List<AzkarModel> foodAzkar;
  final List<AzkarModel> hajjAndUmrahAzkar;

  ZekrCategory({
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

  factory ZekrCategory.fromJson(Map<String, dynamic> json) {
    List<AzkarModel> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => AzkarModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ZekrCategory(
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