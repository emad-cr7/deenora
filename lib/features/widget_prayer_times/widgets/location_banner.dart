import 'package:flutter/material.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/prayer_times_controller.dart';

class LocationBanner extends StatelessWidget {
  final PrayerTimesController controller;

  const LocationBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final location = controller.userLocation;
    if (location == null || !location.isFallback) {
      return const SizedBox.shrink();
    }

    String title;
    String description;
    String buttonText;
    VoidCallback onAction;

    switch (location.status) {
      case LocationStatus.serviceDisabled:
        title = 'Location Services Off';
        description =
            'Using Cairo prayer times as default. Enable location services for your city.';
        buttonText = 'Turn On';
        onAction = () => controller.openLocationSettings();
        break;

      case LocationStatus.permissionDeniedForever:
        title = 'Location Permission Needed';
        description =
            'Location permission is permanently denied. Enable in app settings for local times.';
        buttonText = 'Settings';
        onAction = () => controller.openAppSettings();
        break;

      case LocationStatus.permissionDenied:
        title = 'Location Access Denied';
        description =
            'Using Cairo prayer times as default. Allow location access for your local times.';
        buttonText = 'Allow';
        onAction = () => controller.retryWithPermissionRequest();
        break;

      case LocationStatus.error:
      case LocationStatus.success:
        title = 'Using Cairo Coordinates';
        description =
            'Could not determine your exact position. Tap to retry detecting location.';
        buttonText = 'Retry';
        onAction = () => controller.retryWithPermissionRequest();
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amberGold.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: AppColors.darkGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C4710),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A6224),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
