import 'package:flutter/material.dart';

import '../azkar_model/azkar_model.dart';


class AzkarDetailsController extends ChangeNotifier {
  final String title;
  final List<AzkarModel> zekrList;

  AzkarDetailsController(this.title, this.zekrList);

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
