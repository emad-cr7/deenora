import 'package:flutter/material.dart';
class SleepTimerAndExtrasCard extends StatelessWidget {
  final bool isSleepTimerActive;
  final String sleepTimerFormatted;
  final VoidCallback onSleepTimerTap;
  final VoidCallback onCancelSleepTimer;
  final bool isLooping;
  final VoidCallback onToggleLoop;

  const SleepTimerAndExtrasCard({
    super.key,
    required this.isSleepTimerActive,
    required this.sleepTimerFormatted,
    required this.onSleepTimerTap,
    required this.onCancelSleepTimer,
    required this.isLooping,
    required this.onToggleLoop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SleepTimerRow(
            isActive: isSleepTimerActive,
            formattedTime: sleepTimerFormatted,
            onTap: onSleepTimerTap,
            onCancel: onCancelSleepTimer,
          ),
          const Divider(height: 16, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RepeatToggleButton(
                isLooping: isLooping,
                onToggle: onToggleLoop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _SleepTimerRow extends StatelessWidget {
  final bool isActive;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _SleepTimerRow({
    required this.isActive,
    required this.formattedTime,
    required this.onTap,
    required this.onCancel,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? primaryColor.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.snooze_rounded : Icons.snooze_outlined,
                size: 25,
                color: isActive ? primaryColor : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sleep Timer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive
                        ? 'Active: $formattedTime remaining'
                        : 'Tap to set automatic sleep timer',
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? primaryColor : Colors.grey[600],
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: Colors.red[600],
                tooltip: 'Cancel Timer',
                onPressed: onCancel,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[800],
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _RepeatToggleButton extends StatelessWidget {
  final bool isLooping;
  final VoidCallback onToggle;

  const _RepeatToggleButton({
    required this.isLooping,
    required this.onToggle,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Row(
          children: [
            Icon(
              isLooping ? Icons.repeat_one_rounded : Icons.repeat_rounded,
              size: 18,
              color: isLooping ? primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              isLooping ? 'Repeat One' : 'Repeat Off',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isLooping ? FontWeight.bold : FontWeight.w500,
                color: isLooping ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
