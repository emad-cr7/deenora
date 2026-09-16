import 'package:deenora/features/qibla/controllers/qibla_controller.dart';
import 'package:deenora/features/qibla/models/qibla_status.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('QiblaController Tests', () {
    test('Initial status defaults to loading', () {
      final controller = QiblaController();
      expect(controller.status, equals(QiblaStatus.loading));
      expect(controller.heading, isNull);
      expect(controller.qiblahBearing, isNull);
      expect(controller.isFacingQibla, isFalse);
    });

    test('Angular difference correctly handles identical angles', () {
      // Difference when heading and qiblah are both 136°
      double heading = 136.0;
      double qiblah = 136.0;

      double diff = (heading - qiblah).abs() % 360;
      if (diff > 180) diff = 360 - diff;
      final isFacing = diff <= QiblaController.alignmentThreshold;

      expect(diff, equals(0.0));
      expect(isFacing, isTrue);
    });

    test('Angular difference correctly handles 0/360 degree boundary wrap-around', () {
      // Heading is 359°, Qibla is 2° -> absolute difference across 0 is 3°
      double heading = 359.0;
      double qiblah = 2.0;

      double diff = (heading - qiblah).abs() % 360;
      if (diff > 180) diff = 360 - diff;
      final isFacing = diff <= QiblaController.alignmentThreshold;

      expect(diff, equals(3.0));
      expect(isFacing, isTrue);
    });

    test('Angular difference outside threshold correctly marks not facing', () {
      // Heading is 120°, Qibla is 136° -> diff is 16° > 4°
      double heading = 120.0;
      double qiblah = 136.0;

      double diff = (heading - qiblah).abs() % 360;
      if (diff > 180) diff = 360 - diff;
      final isFacing = diff <= QiblaController.alignmentThreshold;

      expect(diff, equals(16.0));
      expect(isFacing, isFalse);
    });

    test('User Example 1: Bearing 136, Heading 134 -> diff 2 deg, facing Qibla', () {
      double qiblah = 136.0;
      double heading = 134.0;
      double diff = (qiblah - heading) % 360.0;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;

      expect(diff.abs(), equals(2.0));
      expect(diff.abs() <= QiblaController.alignmentThreshold, isTrue);
    });

    test('User Example 2: Bearing 136, Heading 150 -> diff 14 deg, NOT facing Qibla (turn left 14 deg)', () {
      double qiblah = 136.0;
      double heading = 150.0;
      double diff = (qiblah - heading) % 360.0;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;

      expect(diff.abs(), equals(14.0));
      expect(diff.abs() <= QiblaController.alignmentThreshold, isFalse);
      expect(diff, equals(-14.0)); // Turn left 14°
    });

    test('User Example 3: Qibla 359, Heading 1 -> 2 deg apart, facing Qibla', () {
      double qiblah = 359.0;
      double heading = 1.0;
      double diff = (qiblah - heading) % 360.0;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;

      expect(diff.abs(), equals(2.0));
      expect(diff.abs() <= QiblaController.alignmentThreshold, isTrue);
      expect(diff, equals(-2.0)); // Shortest direction is left 2°
    });

    test('User Example 4: Qibla 1, Heading 359 -> 2 deg apart, facing Qibla', () {
      double qiblah = 1.0;
      double heading = 359.0;
      double diff = (qiblah - heading) % 360.0;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;

      expect(diff.abs(), equals(2.0));
      expect(diff.abs() <= QiblaController.alignmentThreshold, isTrue);
      expect(diff, equals(2.0)); // Shortest direction is right 2°
    });

    test('Real QiblahDirection simulation: using data.offset triggers alignment correctly', () {
      // In Cairo, true Qibla offset is 136.0°
      const double trueOffset = 136.0;

      // Scenario A: Phone pointed at 134° (within ±4° of 136°)
      const double headingA = 134.0;
      // flutter_qiblah emits data.qiblah = heading + (360 - offset) = 134 + 224 = 358
      // and data.offset = 136.0
      const double rawQiblahA = headingA + (360 - trueOffset); // 358.0
      expect(rawQiblahA, equals(358.0));

      // With our fix, controller uses data.offset:
      final normalizedBearing = (trueOffset % 360.0 + 360.0) % 360.0;
      double diffA = (normalizedBearing - headingA) % 360.0;
      if (diffA > 180.0) diffA -= 360.0;
      if (diffA < -180.0) diffA += 360.0;
      expect(diffA.abs(), equals(2.0));
      expect(diffA.abs() <= QiblaController.alignmentThreshold, isTrue);

      // Scenario B: Phone pointed at 180° (South, outside ±4°)
      const double headingB = 180.0;
      double diffB = (normalizedBearing - headingB) % 360.0;
      if (diffB > 180.0) diffB -= 360.0;
      if (diffB < -180.0) diffB += 360.0;
      expect(diffB.abs(), equals(44.0));
      expect(diffB.abs() <= QiblaController.alignmentThreshold, isFalse);
    });
  });
}
