import 'package:dio/dio.dart';
import '../../../../features/mosque/models/models.dart';
import '../dio/dio_config.dart';

class PrayerTimesService {
  final Dio _dio;

  PrayerTimesService({Dio? dio})
      : _dio = dio ?? DioConfig.create('https://api.aladhan.com/v1');

  /// Fetches prayer times using dynamic device coordinates (latitude, longitude).
  /// [method] defaults to 5 (Egyptian General Authority of Survey).
  /// [date] defaults to current date if null.
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

  /// Optional fallback to fetch prayer times by city and country names.
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
        queryParameters: {
          'city': city,
          'country': country,
          'method': method,
        },
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
