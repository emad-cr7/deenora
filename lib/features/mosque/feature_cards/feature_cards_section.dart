import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../../qibla/qibla_screen.dart';
import '../../tasbeeh/screens/tasbeeh_selection_screen.dart';
import 'feature_card.dart';

/// The 2x2 grid section assembling the four Islamic feature cards:
/// Qibla, Tasbeeh, Quran, and Duas using the single reusable [FeatureCard].
class FeatureCardsSection extends StatelessWidget {
  final VoidCallback? onQiblaTap;
  final VoidCallback? onTasbeehTap;
  final VoidCallback? onQuranTap;
  final VoidCallback? onDuasTap;

  const FeatureCardsSection({
    super.key,
    this.onQiblaTap,
    this.onTasbeehTap,
    this.onQuranTap,
    this.onDuasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Qibla & Tasbeeh
          Row(
            children: [
              Expanded(
                child: FeatureCard(
                  title: 'Qibla',
                  description: 'Find the direction of the Kaaba',
                  icon: FlutterIslamicIcons.solidQibla,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QiblaScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FeatureCard(
                  title: 'Tasbeeh',
                  description: 'Count your dhikr and get closer to Allah',
                  icon: FlutterIslamicIcons.solidTasbih,
                  onTap: onTasbeehTap ?? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TasbeehSelectionScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
