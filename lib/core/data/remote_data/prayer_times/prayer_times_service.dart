import 'package:dio/dio.dart';
import '../../../../features/widget_prayer_times/models/prayer_times_model.dart';
import '../dio/dio_config.dart';

class PrayerTimesService {
  final Dio _dio = DioConfig.create('https://api.aladhan.com/v1');

  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    try {
      final datePath = date != null
          ? '/timings/${date.day}-${date.month}-${date.year}'
          : '/timings';

      final response = await _dio.get(
        datePath,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return PrayerTimesModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to load prayer times: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching prayer times: $e');
    }
  }

  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 5,
    DateTime? date,
  }) async {
    try {
      final datePath = date != null
          ? '/timingsByCity/${date.day}-${date.month}-${date.year}'
          : '/timingsByCity';

      final response = await _dio.get(
        datePath,
        queryParameters: {'city': city, 'country': country, 'method': method},
      );

      final data = response.data as Map<String, dynamic>;
      return PrayerTimesModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to load prayer times for $city: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching prayer times: $e');
    }
  }
}
