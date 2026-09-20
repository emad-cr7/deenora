import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:tactile/tactile.dart';

import '../../../../core/theme/app_colors.dart';

class CounterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isCompleted;

  const CounterButton({
    super.key,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 175.0;

    return Center(
      child: Tactile(
        enabled: !isCompleted,
        onTap: onTap,
        haptics: TactileHaptics.light,
        depress: 0.07,
        tilt: 0,
        glare: false,
        pressDuration: const Duration(milliseconds: 10),
        springBack: true,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.2, -0.3),
              radius: 0.9,
              colors: isCompleted
                  ? [
                      AppColors.primary,
                      AppColors.primaryDark,
                      AppColors.deepForest,
                    ]
                  : [
                      const Color(0xFF237664),
                      AppColors.primary,
                      AppColors.deepForest,
                    ],
            ),
            border: Border.all(
              color: isCompleted
                  ? AppColors.gold
                  : AppColors.champagneGold.withValues(alpha: 0.65),
              width: isCompleted ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : AppColors.deepForest.withValues(alpha: 0.38),
                blurRadius: isCompleted ? 24 : 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: buttonSize - 26,
                height: buttonSize - 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FlutterIslamicIcons.solidTasbih,
                    size: 38,
                    color: isCompleted
                        ? AppColors.gold
                        : AppColors.borderSubtle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TAP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: isCompleted
                          ? AppColors.champagneGold
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
