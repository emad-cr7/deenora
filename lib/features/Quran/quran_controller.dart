import 'package:flutter/material.dart';

import '../../core/data/remote_data/quran_service.dart';
import '../../core/models/quran_response_model.dart';

class QuranController extends ChangeNotifier {

  final QuranService _service = QuranService();
  late Future<QuranResponseModel> futureQuran;

  @override
  void init() {
    futureQuran = _service.getFullQuran();
    notifyListeners();
  }


}