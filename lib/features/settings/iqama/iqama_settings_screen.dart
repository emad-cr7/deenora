import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'iqama_settings_controller.dart';

class IqamaSettingsScreen extends StatefulWidget {
  const IqamaSettingsScreen({super.key});

  @override
  State<IqamaSettingsScreen> createState() => _IqamaSettingsScreenState();
}

class _IqamaSettingsScreenState extends State<IqamaSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IqamaSettingsController(),
      child: Consumer<IqamaSettingsController>(
        builder: (context, controller, _) => Scaffold(
          appBar: AppBar(title: const Text('Iqama settings')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Minutes after each prayer starts (0–180).'),
                  const Text(
                    'Reminder preference only. Reminders are not scheduled yet.',
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Iqama reminders'),
                    value: controller.enabled,
                    onChanged: controller.isSaving
                        ? null
                        : controller.setEnabled,
                  ),
                  for (final prayer in IqamaSettings.defaultDelays.keys)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        key: ValueKey(prayer),
                        initialValue: controller.delays[prayer],
                        enabled: !controller.isSaving,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: prayer.englishName,
                          suffixText: 'min',
                        ),
                        validator: controller.validateDelay,
                        onChanged: (value) =>
                            controller.setDelay(prayer, value),
                      ),
                    ),
                  if (controller.errorMessage != null)
                    Text(controller.errorMessage!),
                  FilledButton(
                    onPressed: controller.isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final saved = await controller.save();
                            if (saved && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: Text(controller.isSaving ? 'Saving…' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
