import 'package:deenora/features/settings/settings_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/features/settings/muadhin/widgets/muadhin_selection_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          SettingsOptionTile(
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

