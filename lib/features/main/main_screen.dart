import 'package:deenora/features/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../Azkar/azkar_screen.dart';
import '../Quran/Listening/widgets/mini_player/mini_player.dart';
import '../Quran/switch/switch_screen.dart';
import '../mosque/mosque_screen.dart';
import '../qibla/qibla_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Widget>? pages;

  const MainScreen({super.key, this.pages});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> pages =
      widget.pages ??
      const [MosqueScreen(), SwitchScreen(), QiblaScreen(), AzkarScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(FlutterIslamicIcons.solidMosque),
                selectedIcon: Icon(FlutterIslamicIcons.solidMosque),
                label: 'mosque',
              ),
              NavigationDestination(
                icon: Icon(FlutterIslamicIcons.solidQuran2),
                selectedIcon: Icon(FlutterIslamicIcons.solidQuran2),
                label: 'Quran',
              ),
              NavigationDestination(
                icon: Icon(FlutterIslamicIcons.solidQibla),
                selectedIcon: Icon(FlutterIslamicIcons.solidQibla),
                label: 'Qibla',
              ),
              NavigationDestination(
                icon: Icon(FlutterIslamicIcons.solidTasbih),
                selectedIcon: Icon(FlutterIslamicIcons.solidTasbih),
                label: 'Azkar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
