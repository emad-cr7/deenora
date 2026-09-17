import 'package:deenora/features/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../features/Azkar/azkar_screen.dart';
import '../features/Quran/switch/switch_screen.dart';
import '../features/Quran/Listening/widgets/mini_player/mini_player.dart';
import '../features/mosque/mosque_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    MosqueScreen(),
    SwitchScreen(),
    AzkarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
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
                icon: Icon(FlutterIslamicIcons.solidTasbih),
                selectedIcon: Icon(FlutterIslamicIcons.solidTasbih),
                label: 'Azkar',
              ),
              NavigationDestination(
                icon: Icon(FlutterIslamicIcons.solidMuslim),
                selectedIcon: Icon(FlutterIslamicIcons.solidMuslim),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
