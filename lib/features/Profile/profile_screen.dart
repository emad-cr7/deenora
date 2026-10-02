import 'package:deenora/features/Profile/profile_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';
import 'package:deenora/features/Profile/muadhin/widgets/muadhin_selection_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Section Title
          const Text(
            'Settings & Preferences',
            style: TextStyle(
              fontSize: AppSizes.sp14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Muadhin Selection Option Tile
          ProfileOptionTile(
            icon: FlutterIslamicIcons.solidMuslim,
            title: 'Select Muadhin',
            subtitle: 'Choose preferred Adhan and Iqama audio',
            onTap: () => MuadhinSelectionBottomSheet.show(context),
          ),
        ],
      ),
    );
  }
}

/// Backwards-compatibility alias for the Settings screen
typedef ProfileScreen = SettingsScreen;

