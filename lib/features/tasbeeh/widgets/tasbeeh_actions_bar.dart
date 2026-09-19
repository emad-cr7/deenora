import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widget/share_widget/action_button.dart';

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
              ActionButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onTap: onPrevious,
              ),
              ActionButton(
                icon: Icons.restart_alt_rounded,
                label: 'Reset',
                onTap: onReset,
              ),

              ActionButton(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 20,
                        color: AppColors.champagneGold,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Select Dhikr',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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

