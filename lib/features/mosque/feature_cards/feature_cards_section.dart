import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../../settings/settings_option_tile.dart';
import '../../tasbeeh/screens/tasbeeh_selection_screen.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Qibla & Tasbeeh
          const SizedBox(width: 10),
          SettingsOptionTile(
            title: 'Tasbeeh',
            subtitle: 'Count your dhikr and get closer to Allah',
            icon: FlutterIslamicIcons.solidTasbih,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TasbeehSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
