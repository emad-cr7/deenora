import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../features/tasbeeh/models/tasbih_dataset_model.dart';
import '../dio/dio_config.dart';

class TasbeehService {
  final Dio _dio;

  static const String baseUrl = 'https://tasbih.info';

  TasbeehService({Dio? dio}) : _dio = dio ?? DioConfig.create(baseUrl);

  TasbihDatasetModel? _cachedDataset;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedDataset != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedDataset!;
    }

    try {
      final response = await _dio.get('/dhikr.json');

      if (response.data == null) {
        throw Exception('Received empty response from Tasbih API');
      }

      final Map<String, dynamic> json;
      if (response.data is Map<String, dynamic>) {
        json = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        json = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        throw Exception('Invalid JSON response format from Tasbih API');
      }

      final dataset = TasbihDatasetModel.fromJson(json);
      _cachedDataset = dataset;
      _lastFetchTime = DateTime.now();

      return dataset;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error loading Tasbeeh data: $e');
    }
  }
}
