import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/core/theme/app_colors.dart';

/// Circular avatar widget for displaying the Muadhin's picture or a fallback Islamic icon.
class MuadhinAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isMosque;

  const MuadhinAvatar({
    super.key,
    required this.imageUrl,
    required this.isMosque,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _FallbackAvatar(isMosque: isMosque),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFF1F5F3),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              )
            : _FallbackAvatar(isMosque: isMosque),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final bool isMosque;

  const _FallbackAvatar({required this.isMosque});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EFEA),
      child: Icon(
        isMosque ? FlutterIslamicIcons.solidMosque : FlutterIslamicIcons.solidMuslim,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}
