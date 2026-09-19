import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget_prayer_times/controllers/prayer_times_controller.dart';
import 'widgets/mosque_content.dart';

class MosqueScreen extends StatelessWidget {
  const MosqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerTimesController>(
      create: (_) => PrayerTimesController()..init(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mosque')),
        body: const MosqueContent(),
      ),
    );
  }
}
