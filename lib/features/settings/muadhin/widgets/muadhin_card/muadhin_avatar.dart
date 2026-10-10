import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:deenora/core/theme/app_colors.dart';

class MuadhinAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isMosque;

  const MuadhinAvatar({
    super.key,
    required this.imageUrl,
    required this.isMosque,
  });

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFE8EFEA),
      alignment: Alignment.center,
      child: Icon(
        isMosque
            ? FlutterIslamicIcons.solidMosque
            : FlutterIslamicIcons.solidMuslim,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }

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
        child: imageUrl.trim().isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl.trim(),
                fit: BoxFit.cover,
                width: 58,
                height: 58,
                placeholder: (context, url) => Container(
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
                ),
                errorWidget: (context, url, error) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }
}
