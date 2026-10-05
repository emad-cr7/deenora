import 'package:dio/dio.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import '../dio/dio_config.dart';

class MuadhinService {
  final Dio _dio= DioConfig.create('https://adhan-iqama-api.vercel.app/api/');

  Future<List<MuadhinModel>> getAllMuadhins() async {
    try {
      final response = await _dio.get('all');
      final data = response.data;

      if (data is Map<String, dynamic> && data['sheikhs'] is List) {
        final List<dynamic> list = data['sheikhs'] as List<dynamic>;
        return list
            .map((item) => MuadhinModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Invalid data format received');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error loading muadhin data: $e');
    }
  }
}
