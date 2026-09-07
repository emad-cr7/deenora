import 'package:flutter/cupertino.dart';

import '../../core/data/remote_data/azkara/azkara_service.dart';
import 'azkar_model/azekr_category.dart';

class AzkarController extends ChangeNotifier {
  final AzkaraService _service = AzkaraService();
  late Future<AzekrCategory> azkarFuture;

  void init() {
    azkarFuture = _service.getAzkar();
  }

}