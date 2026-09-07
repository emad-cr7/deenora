import 'package:flutter/cupertino.dart';

import '../../core/data/local_data/hive_manager.dart';
import '../../core/data/remote_data/azkara/azkara_service.dart';
import 'azkar_model/azekr_category.dart';

class AzkarController extends ChangeNotifier {
  final AzkaraService _service = AzkaraService();
  final HiveManager _hiveManager = HiveManager();

  late Future<AzekrCategory> azkarFuture;

  void init() {
    azkarFuture = _loadAzkar();
  }

  Future<AzekrCategory> _loadAzkar() async {
    final cached = _hiveManager.loadAzkar();
    if (cached != null) {
      return cached;
    }
    final data = await _service.getAzkar();
    await _hiveManager.saveAzkar(data);
    return data;
  }
}