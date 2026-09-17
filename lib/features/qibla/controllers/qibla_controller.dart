import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../../core/services/location_service.dart';
import '../enum/qibla_status.dart';

class QiblaController extends ChangeNotifier {
  final LocationService _locationService;

  QiblaController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  QiblaStatus _status = QiblaStatus.loading;
  double? _heading;
  double? _qiblahBearing;
  double? _offset;
  bool _isFacingQibla = false;
  String? _errorMessage;
  StreamSubscription<QiblahDirection>? _qiblahSubscription;

  // Alignment threshold in degrees (±4 degrees)
  static const double alignmentThreshold = 4.0;

  QiblaStatus get status => _status;
  double? get heading => _heading;
  double? get qiblahBearing => _qiblahBearing;
  double? get offset => _offset;
  bool get isFacingQibla => _isFacingQibla;
  String? get errorMessage => _errorMessage;

  /// Returns the signed shortest angular difference from current heading to Qibla:
  /// Positive means Qibla is to the right.
  /// Negative means Qibla is to the left.
  double get relativeOffset {
    if (_heading == null || _qiblahBearing == null) return 0.0;
    double diff = (_qiblahBearing! - _heading!) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Shortest absolute difference in degrees from device heading to Qibla bearing.
  double get angleDifference => relativeOffset.abs();

  void init() {
    startCompass();
  }

  /// Initializes sensors, verifies location availability, and starts streaming Qibla data.
  Future<void> startCompass() async {
    _status = QiblaStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Check Android hardware sensor support if on Android
      if (Platform.isAndroid) {
        final sensorSupported =
            await FlutterQiblah.androidDeviceSensorSupport();
        if (sensorSupported == false) {
          _status = QiblaStatus.sensorUnavailable;
          notifyListeners();
          return;
        }
      }

      // 2. Check if Location Services (GPS) are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _status = QiblaStatus.serviceDisabled;
        notifyListeners();
        return;
      }

      // 3. Check and request location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _status = QiblaStatus.permissionDenied;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _status = QiblaStatus.permissionDeniedForever;
        notifyListeners();
        return;
      }

      // 4. Start listening to the live Qiblah stream
      _subscribeToQiblahStream();
    } catch (e) {
      _status = QiblaStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _subscribeToQiblahStream() {
    _qiblahSubscription?.cancel();

    _qiblahSubscription = FlutterQiblah.qiblahStream.listen(
      (QiblahDirection data) {
        _heading = data.direction;
        _qiblahBearing = (data.offset % 360.0 + 360.0) % 360.0;
        _offset = data.offset;

        // Calculate circular difference to determine if facing Qibla
        _isFacingQibla = angleDifference <= alignmentThreshold;

        if (_status != QiblaStatus.ready) {
          _status = QiblaStatus.ready;
        }

        notifyListeners();
      },
      onError: (error) {
        _status = QiblaStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Retries initializing sensors and requesting permissions
  Future<void> retry() async {
    await startCompass();
  }

  /// Opens the device settings page for this application
  Future<bool> openAppSettings() async {
    return _locationService.openAppSettings();
  }

  /// Opens the device location settings page
  Future<bool> openLocationSettings() async {
    return _locationService.openLocationSettings();
  }

  @override
  void dispose() {
    _qiblahSubscription?.cancel();
    _qiblahSubscription = null;
    super.dispose();
  }
}
