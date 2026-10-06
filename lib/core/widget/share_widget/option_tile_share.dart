import 'package:flutter/material.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';

class OptionTileShare extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accentColor;

  const OptionTileShare({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    final textDirection = Directionality.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent,
                          Color.lerp(accent, Colors.black, 0.25)!,
                        ],
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: textDirection,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: AppSizes.sp16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: AppSizes.sp12,
                                      height: 1.35,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded,
                              size: 20,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}