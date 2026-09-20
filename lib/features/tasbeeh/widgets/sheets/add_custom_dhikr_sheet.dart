import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AddCustomDhikrSheet extends StatefulWidget {
  final void Function(String text, int count) onAdd;
  final String? initialText;
  final int? initialCount;
  final String? title;
  final String? buttonText;

  const AddCustomDhikrSheet({
    super.key,
    required this.onAdd,
    this.initialText,
    this.initialCount,
    this.title,
    this.buttonText,
  });

  static Future<void> show({
    required BuildContext context,
    required void Function(String text, int count) onAdd,
    String? initialText,
    int? initialCount,
    String? title,
    String? buttonText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCustomDhikrSheet(
        onAdd: onAdd,
        initialText: initialText,
        initialCount: initialCount,
        title: title,
        buttonText: buttonText,
      ),
    );
  }

  @override
  State<AddCustomDhikrSheet> createState() => _AddCustomDhikrSheetState();
}

class _AddCustomDhikrSheetState extends State<AddCustomDhikrSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _countController;
  String? _textError;
  String? _countError;

  final List<int> _presetCounts = const [33, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    _countController = TextEditingController(
      text: (widget.initialCount ?? 33).toString(),
    );
  }

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
                      widget.title ?? 'Add Personal Dhikr',
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

            const SizedBox(height: 14),

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

            const SizedBox(height: 24),

            // Full-width Add / Submit Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                child: Text(
                  widget.buttonText ?? 'Add Dhikr',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
