import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_controller.dart';

// نافذة اختيار مؤقت النوم
class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  static const Color primaryColor = Color(0xFF1B5E4F);

  // إظهار نافذة مؤقت النوم السفلية
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

              // ترويسة النافذة
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SleepTimerSheet.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.snooze_rounded,
                      color: SleepTimerSheet.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep Timer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Automatically pause audio playback',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF71807B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
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
                        onPressed: () {
                          controller.cancelSleepTimer();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // خيارات المؤقت المقترحة
              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.tenMin,
                title: '10 minutes',
                subtitle: 'Pause playback in 10 minutes',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 8),

              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.fifteenMin,
                title: '15 minutes',
                subtitle: 'Pause playback in 15 minutes',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 8),

              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.thirtyMin,
                title: '30 minutes',
                subtitle: 'Pause playback in 30 minutes',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 8),

              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.fortyFiveMin,
                title: '45 minutes',
                subtitle: 'Pause playback in 45 minutes',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 8),

              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.oneHour,
                title: '1 hour',
                subtitle: 'Pause playback in 60 minutes',
                icon: Icons.hourglass_bottom_rounded,
              ),
              const SizedBox(height: 8),

              _buildOptionTile(
                context: context,
                controller: controller,
                option: SleepTimerOption.endOfSurah,
                title: 'End of current Surah',
                subtitle: 'Pause when the current Surah finishes',
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 8),

              // خيار المدة المخصصة
              _buildCustomOptionTile(context, controller),

              // منزلق تحديد المدة المخصصة
              if (_showCustomPicker) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SleepTimerSheet.primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Custom duration:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
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
                        onChanged: (val) {
                          setState(() {
                            _customMinutes = val;
                          });
                        },
                      ),
                      Wrap(
                        spacing: 8,
                        children: [5, 20, 45, 60, 90, 120].map((m) {
                          final isSelected = _customMinutes.toInt() == m;
                          return ChoiceChip(
                            label: Text('$m min'),
                            selected: isSelected,
                            selectedColor: SleepTimerSheet.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF1B1B1B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _customMinutes = m.toDouble();
                              });
                            },
                          );
                        }).toList(),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // بناء عنصر اختيار خيار المؤقت
  Widget _buildOptionTile({
    required BuildContext context,
    required AudioPlayerController controller,
    required SleepTimerOption option,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = controller.sleepTimerOption == option;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? SleepTimerSheet.primaryColor.withValues(alpha: 0.1)
            : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? SleepTimerSheet.primaryColor
              : Colors.grey.withValues(alpha: 0.15),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            controller.setSleepTimer(option);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SleepTimerSheet.primaryColor
                        : Colors.grey.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? SleepTimerSheet.primaryColor
                              : const Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? SleepTimerSheet.primaryColor.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: SleepTimerSheet.primaryColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء عنصر اختيار المدة المخصصة
  Widget _buildCustomOptionTile(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    final isSelected = controller.sleepTimerOption == SleepTimerOption.custom;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? SleepTimerSheet.primaryColor.withValues(alpha: 0.1)
            : const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? SleepTimerSheet.primaryColor
              : Colors.grey.withValues(alpha: 0.15),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _showCustomPicker = !_showCustomPicker;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SleepTimerSheet.primaryColor
                        : Colors.grey.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
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
                        'Custom Duration',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? SleepTimerSheet.primaryColor
                              : const Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Set duration in minutes',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? SleepTimerSheet.primaryColor.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showCustomPicker
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isSelected
                      ? SleepTimerSheet.primaryColor
                      : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

