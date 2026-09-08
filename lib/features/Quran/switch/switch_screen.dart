import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

import '../Listening/widgets/main_audio/quran_listening.dart';
import '../reading/quran_reading.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const Color primaryColor = Color(0xFF1B5E4F);
  static const Color unselectedColor = Color(0xFF6B6B6B);
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
      appBar: AppBar(title: const Text('Quran'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: SizedBox(
              height: 45,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: SegmentedTabControl(
                  controller: _tabController,
                  barDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorDecoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  tabTextColor: unselectedColor,
                  selectedTabTextColor: Colors.white,

                  tabs: [
                    SegmentTab(
                      label: 'reading',
                      labelBuilder: (context, color) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 20,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'reading',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SegmentTab(
                      label: 'listening',
                      labelBuilder: (context, color) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.headphones_rounded,
                              size: 20,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'listening',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
