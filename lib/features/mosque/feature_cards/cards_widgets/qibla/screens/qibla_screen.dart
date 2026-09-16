import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';
import '../models/qibla_status.dart';
import '../widgets/qibla_calibration_hint.dart';
import '../widgets/qibla_compass.dart';
import '../widgets/qibla_direction_indicator.dart';
import '../widgets/qibla_error_view.dart';
import '../widgets/qibla_status_card.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QiblaController>(
      create: (_) => QiblaController()..init(),
      child: const _QiblaScreenContent(),
    );
  }
}

class _QiblaScreenContent extends StatelessWidget {
  const _QiblaScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: Consumer<QiblaController>(
        builder: (context, controller, _) {
          // 1. Loading State
          if (controller.status == QiblaStatus.loading &&
              controller.heading == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.inkDrop(
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Finding Qibla direction...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF71807B),
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. Error / Permission / Sensor Issue State
          if (controller.status != QiblaStatus.ready &&
              controller.heading == null) {
            return QiblaErrorView(controller: controller);
          }

          // 3. Active Qibla Compass State
          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive compass size based on screen dimensions
              final availableWidth = constraints.maxWidth;
              final compassSize = (availableWidth * 0.72).clamp(240.0, 320.0);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 1. Direction Guidance (Rotate phone / Facing Qibla)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: QiblaDirectionIndicator(
                              controller: controller,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 2. Hero Interactive Qibla Compass
                          QiblaCompass(
                            controller: controller,
                            size: compassSize,
                          ),

                          const SizedBox(height: 20),

                          // 3. Bearing & Heading Metrics Cards
                          QiblaStatusCard(controller: controller),

                          const SizedBox(height: 12),

                          // 4. Subtle Figure-8 Calibration Hint
                          const QiblaCalibrationHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
