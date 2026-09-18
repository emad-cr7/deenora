import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';
import '../enum/qibla_status.dart';

class QiblaErrorView extends StatelessWidget {
  final QiblaController controller;

  const QiblaErrorView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String title;
    final String description;
    final String buttonLabel;
    final VoidCallback onAction;

    switch (controller.status) {
      case QiblaStatus.permissionDenied:
        icon = Icons.location_off_rounded;
        title = 'Location Permission Required';
        description =
            'Please grant location access so Deenora can accurately determine the Qibla direction for your position.';
        buttonLabel = 'Allow Location';
        onAction = () => controller.retry();
        break;

      case QiblaStatus.permissionDeniedForever:
        icon = Icons.settings_suggest_rounded;
        title = 'Permission Permanently Denied';
        description =
            'Location access has been permanently disabled for Deenora. Please enable it in your device settings.';
        buttonLabel = 'Open Settings';
        onAction = () => controller.openAppSettings();
        break;

      case QiblaStatus.serviceDisabled:
        icon = Icons.gps_off_rounded;
        title = 'Location Services Disabled';
        description =
            'Your device GPS / Location services are turned off. Please turn them on to calculate the Qibla.';
        buttonLabel = 'Turn On Location';
        onAction = () => controller.openLocationSettings();
        break;

      case QiblaStatus.sensorUnavailable:
        icon = Icons.sensors_off_rounded;
        title = 'Sensor Unavailable';
        description =
            'Your device lacks the physical magnetic compass sensors required for live directional tracking.';
        buttonLabel = 'Retry Detection';
        onAction = () => controller.retry();
        break;

      case QiblaStatus.error:
      default:
        icon = Icons.error_outline_rounded;
        title = 'Unable to Start Compass';
        description =
            controller.errorMessage ??
            'An unexpected error occurred while reading compass sensors. Please try again.';
        buttonLabel = 'Try Again';
        onAction = () => controller.retry();
        break;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  buttonLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
