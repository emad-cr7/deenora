import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../../../../../../core/theme/app_colors.dart';

class CounterButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isCompleted;

  const CounterButton({
    super.key,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = 175.0;

    return Center(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 0.9,
                colors: widget.isCompleted
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
                color: widget.isCompleted
                    ? AppColors.gold
                    : AppColors.champagneGold.withValues(alpha: 0.65),
                width: widget.isCompleted ? 3.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isCompleted
                      ? AppColors.gold.withValues(alpha: 0.35)
                      : AppColors.deepForest.withValues(alpha: 0.38),
                  blurRadius: widget.isCompleted ? 24 : 18,
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
                // Subtle inner decorative ring
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

                // Button Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FlutterIslamicIcons.solidTasbih,
                      size: 38,
                      color: widget.isCompleted
                          ? AppColors.gold
                          : AppColors.champagneGold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TAP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                        color: widget.isCompleted
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
      ),
    );
  }
}
