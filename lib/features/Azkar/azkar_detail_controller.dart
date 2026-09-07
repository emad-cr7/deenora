import 'package:flutter/material.dart';

import '../../core/enum/azkar_model/azkar_model.dart';

class AzkarDetailController extends ChangeNotifier {
  final String title;
  final List<AzkarModel> zekrList;

  AzkarDetailController(this.title, this.zekrList);

  late List<int> remainingCounts;

  void init() {
    remainingCounts = zekrList.map((zekr) => zekr.count).toList();
    notifyListeners();
  }

  void decreaseCount(int index) {
    if (remainingCounts[index] <= 0) return;
    remainingCounts[index]--;
    notifyListeners();
  }
}
