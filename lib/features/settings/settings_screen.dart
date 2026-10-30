import 'package:deenora/core/widget/share_widget/option_tile_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/features/settings/muadhin/widgets/option_muadhin/muadhin_selection_bottom_sheet.dart';
import 'iqama/iqama_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          OptionTileShare(
            icon: FlutterIslamicIcons.solidMuslim,
            title: 'Select Muadhin',
            subtitle: 'Choose preferred Adhan and Iqama audio',
            onTap: () => MuadhinSelectionBottomSheet.show(context),
          ),
          const SizedBox(height: 16),
          OptionTileShare(
            icon: Icons.notifications_active_rounded,
            title: 'Iqama settings',
            subtitle: 'Set reminder preference and delays for each prayer',
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const IqamaSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
