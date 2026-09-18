import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddCustomDhikrSheet extends StatefulWidget {
  final void Function(String text, int count) onAdd;

  const AddCustomDhikrSheet({super.key, required this.onAdd});

  static Future<void> show({
    required BuildContext context,
    required void Function(String text, int count) onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCustomDhikrSheet(onAdd: onAdd),
    );
  }

  @override
  State<AddCustomDhikrSheet> createState() => _AddCustomDhikrSheetState();
}

class _AddCustomDhikrSheetState extends State<AddCustomDhikrSheet> {
  final _textController = TextEditingController();
  final _countController = TextEditingController(text: '33');
  String? _textError;
  String? _countError;

  final List<int> _presetCounts = const [33, 100, 500, 1000];

  @override
  void dispose() {
    _textController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    final count = int.tryParse(_countController.text.trim());

    setState(() {
      _textError = text.isEmpty ? 'Please enter a dhikr phrase' : null;
      if (count == null || count <= 0) {
        _countError = 'Count must be a positive number greater than 0';
      } else {
        _countError = null;
      }
    });

    if (text.isNotEmpty && count != null && count > 0) {
      widget.onAdd(text, count);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DDD8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Personal Dhikr',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.deepForest,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Important Distinction Disclaimer
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE58F)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFD48800),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a custom personal dhikr. The repetition number is treated as your Personal Goal, not a religiously narrated Sunnah count.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.darkGold,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Dhikr Text Input
            Text(
              'Dhikr Text',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.deepForest,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _textController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: 'e.g. SubhanAllah or Rabbi Zidni Ilma',
                errorText: _textError,
                filled: true,
                fillColor: AppColors.luminousIvory,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Repetition Count Input
            Text(
              'Personal Goal (Repetition Count)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.deepForest,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 33',
                errorText: _countError,
                filled: true,
                fillColor: AppColors.luminousIvory,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Quick Preset Chips
            Wrap(
              spacing: 8,
              children: _presetCounts.map((preset) {
                return ActionChip(
                  label: Text('$preset'),
                  backgroundColor: const Color(0xFFF0F4F2),
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepForest,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  onPressed: () {
                    _countController.text = preset.toString();
                    setState(() {
                      _countError = null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _submit,
                    child: Text(
                      'Add Dhikr',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
