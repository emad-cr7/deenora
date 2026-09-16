import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class TasbeehActionsBar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelectDhikr;

  const TasbeehActionsBar({
    super.key,
    required this.onReset,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDhikr,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Reset, Previous, Next navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onTap: onPrevious,
              ),
              _ActionButton(
                icon: Icons.restart_alt_rounded,
                label: 'Reset',
                onTap: onReset,
              ),

              _ActionButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                onTap: onNext,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 2: Select Dhikr (Prominent full-width button below navigation)
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSelectDhikr,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 20,
                        color: AppColors.champagneGold,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Select Dhikr',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 25,
                color: AppColors.deepForest,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF71807B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
