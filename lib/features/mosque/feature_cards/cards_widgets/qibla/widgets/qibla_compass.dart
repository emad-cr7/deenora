import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../controllers/qibla_controller.dart';

class QiblaCompass extends StatefulWidget {
  final QiblaController controller;
  final double size;

  const QiblaCompass({
    super.key,
    required this.controller,
    this.size = 290,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  double _lastHeadingRadians = 0.0;

  /// Ensures rotation always takes the shortest angular path across 0°/360°.
  double _interpolateAngle(double previous, double target) {
    double diff = (target - previous) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return previous + diff;
  }

  @override
  Widget build(BuildContext context) {
    final headingDeg = widget.controller.heading ?? 0.0;
    final qiblaDeg = widget.controller.qiblahBearing ?? 0.0;
    final isFacing = widget.controller.isFacingQibla;

    // Convert degrees to radians for dial rotation.
    // The dial rotates counter-clockwise by heading so physical North aligns properly.
    final targetDialRadians = -headingDeg * (math.pi / 180.0);
    _lastHeadingRadians = _interpolateAngle(_lastHeadingRadians, targetDialRadians);

    final compassSize = widget.size;

    return Center(
      child: SizedBox(
        width: compassSize,
        height: compassSize + 24, // Extra space at the top for the fixed pointer
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Rotating Compass Dial (ticks, cardinal points, degree numbers, Qibla marker)
            Positioned(
              top: 24,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _lastHeadingRadians),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, dialAngle, child) {
                  return Transform.rotate(
                    angle: dialAngle,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: compassSize,
                  height: compassSize,
                  child: CustomPaint(
                    painter: _CompassDialPainter(
                      isFacingQibla: isFacing,
                      qiblaBearingDeg: qiblaDeg,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Center Medallion with Kaaba Asset
            Positioned(
              top: 24 + (compassSize - compassSize * 0.36) / 2,
              child: Container(
                width: compassSize * 0.36,
                height: compassSize * 0.36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isFacing ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                    width: isFacing ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(compassSize * 0.075),
                    child: SvgPicture.asset(
                      'assets/images/qibla/kaaba.svg',
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        isFacing ? AppColors.primary : AppColors.primaryDark,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Completely FIXED Qibla Arrow at top-center (pointing downward towards the compass)
            // Stays completely stationary on the screen and does NOT rotate.
            Positioned(
              top: 6,
              child: CustomPaint(
                size: const Size(22, 20),
                painter: _FixedTopArrowPainter(
                  color: isFacing ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed downward-pointing arrow at the top-center of the screen.
/// Points directly toward the center of the rotating compass.
class _FixedTopArrowPainter extends CustomPainter {
  final Color color;

  const _FixedTopArrowPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw an elegant downward triangle arrow: ∇
    final path = Path()
      ..moveTo(size.width / 2, size.height) // tip pointing down
      ..lineTo(0, 0) // top left
      ..lineTo(size.width, 0) // top right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FixedTopArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Custom painter rendering the rotating compass rose:
/// - Outer circle ring
/// - Degree ticks every 5° (minor), 15° (medium), and 30° (major)
/// - Cardinal labels: N, E, S, W
/// - Rotating Qibla / Kaaba marker attached at `qiblaBearingDeg`
class _CompassDialPainter extends CustomPainter {
  final bool isFacingQibla;
  final double qiblaBearingDeg;

  _CompassDialPainter({
    required this.isFacingQibla,
    required this.qiblaBearingDeg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw outer circle ring
    final ringPaint = Paint()
      ..color = isFacingQibla
          ? AppColors.primary
          : AppColors.primaryDark.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFacingQibla ? 2.0 : 1.5;

    canvas.drawCircle(center, radius - 16, ringPaint);

    // Inner subtle guide circle
    final innerRingPaint = Paint()
      ..color = isFacingQibla
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 44, innerRingPaint);

    // 2. Draw degree tick marks
    // Degree markings turn to Deenora green (AppColors.primary) when aligned
    final minorTickPaint = Paint()
      ..color = isFacingQibla
          ? AppColors.primary.withValues(alpha: 0.5)
          : const Color(0xFF9BA8A4)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final mediumTickPaint = Paint()
      ..color = isFacingQibla
          ? AppColors.primary.withValues(alpha: 0.75)
          : AppColors.primaryDark.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = isFacingQibla
          ? AppColors.primary
          : AppColors.primaryDark
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final tickOuterRadius = radius - 18;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * (math.pi / 180.0);
      double tickLength;
      Paint paint;

      if (deg % 30 == 0) {
        tickLength = 10.0;
        paint = majorTickPaint;
      } else if (deg % 15 == 0) {
        tickLength = 7.0;
        paint = mediumTickPaint;
      } else {
        tickLength = 4.0;
        paint = minorTickPaint;
      }

      final startX = center.dx + (tickOuterRadius - tickLength) * math.sin(rad);
      final startY = center.dy - (tickOuterRadius - tickLength) * math.cos(rad);
      final endX = center.dx + tickOuterRadius * math.sin(rad);
      final endY = center.dy - tickOuterRadius * math.cos(rad);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // 3. Draw Cardinal Directions and Degree Numbers
    // When Qibla is aligned, compass numbers and degree markings turn Deenora green (AppColors.primary).
    // When unaligned, they return to their original color.
    final degreeNumberColor = isFacingQibla
        ? AppColors.primary
        : const Color(0xFF6B7280);

    final cardinalColor = isFacingQibla
        ? AppColors.primary
        : AppColors.primaryDark;

    final northColor = isFacingQibla
        ? AppColors.primary
        : const Color(0xFFC93B2B);

    final cardinalStyle = TextStyle(
      color: cardinalColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    final northStyle = TextStyle(
      color: northColor,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    final degreeNumberStyle = TextStyle(
      color: degreeNumberColor,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    // Cardinal directions
    _drawCompassText(canvas, center, radius - 32, 'N', angleDeg: 0, style: northStyle);
    _drawCompassText(canvas, center, radius - 32, 'E', angleDeg: 90, style: cardinalStyle);
    _drawCompassText(canvas, center, radius - 32, 'S', angleDeg: 180, style: cardinalStyle);
    _drawCompassText(canvas, center, radius - 32, 'W', angleDeg: 270, style: cardinalStyle);

    // Degree numbers around the compass dial
    const degreeAngles = [30, 60, 120, 150, 210, 240, 300, 330];
    for (final deg in degreeAngles) {
      _drawCompassText(
        canvas,
        center,
        radius - 32,
        '$deg',
        angleDeg: deg.toDouble(),
        style: degreeNumberStyle,
      );
    }

    // 4. Draw Existing Yellow Qibla Indicator on the rotating dial at `qiblaBearingDeg`
    // The existing yellow Qibla indicator remains completely unchanged in both normal and aligned states.
    // Shape, position, color, size, and animation stay exactly identical.
    final qiblaRad = qiblaBearingDeg * (math.pi / 180.0);
    final markerRadius = radius - 16;
    final markerX = center.dx + markerRadius * math.sin(qiblaRad);
    final markerY = center.dy - markerRadius * math.cos(qiblaRad);
    final markerCenter = Offset(markerX, markerY);

    // Yellow indicator base dot
    final basePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerCenter, 6.5, basePaint);

    // Yellow indicator center core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerCenter, 2.5, corePaint);
  }

  void _drawCompassText(
    Canvas canvas,
    Offset center,
    double textRadius,
    String text, {
    required double angleDeg,
    required TextStyle style,
  }) {
    final rad = angleDeg * (math.pi / 180.0);
    final textX = center.dx + textRadius * math.sin(rad);
    final textY = center.dy - textRadius * math.cos(rad);

    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      textX - textPainter.width / 2,
      textY - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return oldDelegate.isFacingQibla != isFacingQibla ||
        oldDelegate.qiblaBearingDeg != qiblaBearingDeg;
  }
}
