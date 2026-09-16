import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';

class QiblaDirectionIndicator extends StatelessWidget {
  final QiblaController controller;

  const QiblaDirectionIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isAligned = controller.isFacingQibla;

    return SizedBox(
      height: 32,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: isAligned
              ? const Text(
                  '✓ Qibla direction is correct',
                  key: ValueKey('qibla_aligned_text'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.2,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('qibla_unaligned_empty')),
        ),
      ),
    );
  }
}
