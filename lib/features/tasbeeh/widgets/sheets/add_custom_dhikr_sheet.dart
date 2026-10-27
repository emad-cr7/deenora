
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AddCustomDhikrSheet extends StatefulWidget {
  final void Function(String text, int count) onAdd;
  final String? initialText;
  final int? initialCount;
  final String? buttonText;

  const AddCustomDhikrSheet({
    super.key,
    required this.onAdd,
    this.initialText,
    this.initialCount,
    this.buttonText,
  });

  static Future<void> show({
    required BuildContext context,
    required void Function(String text, int count) onAdd,
    String? initialText,
    int? initialCount,
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
      _countError = count == null || count <= 0
          ? 'Count must be a positive number greater than 0'
          : null;
    });

    if (text.isNotEmpty && count != null && count > 0) {
      widget.onAdd(text, count);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 16,
            bottom: 25 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 55,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4DDD8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 25,
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

              const SizedBox(height: 14),

              Text(
                'Dhikr Text',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'e.g. SubhanAllah or Rabbi Zidni Ilma',
                  errorText: _textError,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Personal Goal ',
                style: Theme.of(context).textTheme.titleSmall,
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

              const SizedBox(height: 24),

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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}