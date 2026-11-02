import 'package:flutter/material.dart';
import '../../core/widget/share_widget/shared_segmented_switch.dart';
import 'Listening/quran_listening.dart';
import 'reading/quran_reading.dart';

class SwitchQuran extends StatelessWidget {
  const SwitchQuran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: const SharedSegmentedSwitch(
        titles: ['reading', 'listening'],
        icons: [Icons.menu_book_rounded, Icons.headphones_rounded],
        children: [QuranReading(), QuranListening()],
      ),
    );
  }
}
