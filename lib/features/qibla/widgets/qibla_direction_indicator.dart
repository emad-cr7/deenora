import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';

class QiblaDirectionIndicator extends StatelessWidget {
  final QiblaController controller;

  const QiblaDirectionIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isAligned = controller.isFacingQibla;

    return SizedBox(
      height: 44,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.92,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(isAligned),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: isAligned
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAligned
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : Colors.orange.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              isAligned
                  ? '✓  Qibla direction is correct'
                  : 'Please turn your device towards the Qibla',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAligned
                    ? AppColors.primary
                    : Colors.orange.shade800,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}