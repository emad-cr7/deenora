import 'package:flutter/material.dart';

import '../Quran/Listening/widgets/main_audio/quran_listening.dart';
import '../Quran/reading/quran_reading.dart';
import '../Quran/switch/switch_screen.dart';

class SwitchQuran extends StatefulWidget {
  const SwitchQuran({super.key});

  @override
  State<SwitchQuran> createState() => _SwitchQuranState();
}

class _SwitchQuranState extends State<SwitchQuran>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: Column(
        children: [
          SharedSegmentedSwitch(
            controller: _tabController,
            titles: const ['reading', 'listening'],
            icons: const [Icons.menu_book_rounded, Icons.headphones_rounded],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [QuranReading(), QuranListening()],
            ),
          ),
        ],
      ),
    );
  }
}
