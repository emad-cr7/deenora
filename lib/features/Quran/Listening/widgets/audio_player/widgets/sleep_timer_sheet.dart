import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio_player_controller.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  static const Color primaryColor = Color(0xFF1B5E4F);

  static Future<void> show(BuildContext context) {
    final controller = context.read<AudioPlayerController>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const SleepTimerSheet(),
      ),
    );
  }

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  bool _showCustomPicker = false;
  double _customMinutes = 20;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مقبض السحب العلوي
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // بطاقة المؤقت النشط
              if (controller.isSleepTimerActive) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SleepTimerSheet.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: SleepTimerSheet.primaryColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: SleepTimerSheet.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Timer Active',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: SleepTimerSheet.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Remaining: ${controller.sleepTimerFormatted}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => controller.cancelSleepTimer(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // خيارات المؤقت المقترحة
              ...SleepTimerOption.presets.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TimerOptionTile(
                    option: option,
                    isSelected: controller.sleepTimerOption == option,
                    onTap: () {
                      controller.setSleepTimer(option);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // خيار المدة المخصصة
              _TimerOptionTile(
                option: SleepTimerOption.custom,
                isSelected:
                    controller.sleepTimerOption == SleepTimerOption.custom,
                onTap: () =>
                    setState(() => _showCustomPicker = !_showCustomPicker),
                trailing: Icon(
                  _showCustomPicker
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: controller.sleepTimerOption == SleepTimerOption.custom
                      ? SleepTimerSheet.primaryColor
                      : Colors.grey[600],
                ),
              ),

              // منزلق تحديد المدة المخصصة
              if (_showCustomPicker) ...[
                const SizedBox(height: 12),
                _buildCustomDurationPicker(context, controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // منزلق ومحدد المدة المخصصة
  Widget _buildCustomDurationPicker(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SleepTimerSheet.primaryColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Custom duration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: SleepTimerSheet.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_customMinutes.toInt()} min',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _customMinutes,
            min: 5,
            max: 180,
            divisions: 35,
            activeColor: SleepTimerSheet.primaryColor,
            inactiveColor:
                SleepTimerSheet.primaryColor.withValues(alpha: 0.15),
            label: '${_customMinutes.toInt()} min',
            onChanged: (val) => setState(() => _customMinutes = val),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SleepTimerSheet.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              controller.setSleepTimer(
                SleepTimerOption.custom,
                customMinutes: _customMinutes.toInt(),
              );
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Set Custom Timer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// عنصر خيار مؤقت النوم الموحد
class _TimerOptionTile extends StatelessWidget {
  final SleepTimerOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _TimerOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.1)
            : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : Colors.grey.withValues(alpha: 0.15),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option.icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? primaryColor
                              : const Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    (isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: primaryColor,
                            size: 22,
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
