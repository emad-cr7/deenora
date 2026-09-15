import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';

class QiblaStatusCard extends StatelessWidget {
  final QiblaController controller;

  const QiblaStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final qiblaBearing = controller.qiblahBearing?.round() ?? 0;
    final heading = controller.heading?.round() ?? 0;
    final isFacing = controller.isFacingQibla;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 1. Qibla Bearing Card
          Expanded(
            child: _buildMetricTile(
              value: '$qiblaBearing°',
              label: 'Qibla Direction',
              icon: Icons.explore_rounded,
              highlightColor: isFacing ? AppColors.primary : AppColors.gold,
            ),
          ),
          const SizedBox(width: 14),

          // 2. Current Device Heading Card
          Expanded(
            child: _buildMetricTile(
              value: '$heading°',
              label: 'Device Heading',
              icon: Icons.navigation_outlined,
              highlightColor: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String value,
    required String label,
    required IconData icon,
    required Color highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: highlightColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: highlightColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
