import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class UserLocation {
  final double latitude;
  final double longitude;
  final LocationStatus status;
  final bool isFallback;
  final String? message;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.isFallback,
    this.message,
  });

  /// Default explicit fallback (Cairo, Egypt: 30.0444° N, 31.2357° E)
  static const double fallbackLatitude = 30.0444;
  static const double fallbackLongitude = 31.2357;

  factory UserLocation.fallback({
    required LocationStatus status,
    String? message,
  }) {
    return UserLocation(
      latitude: fallbackLatitude,
      longitude: fallbackLongitude,
      status: status,
      isFallback: true,
      message: message,
    );
  }

  factory UserLocation.actual({
    required double latitude,
    required double longitude,
  }) {
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      status: LocationStatus.success,
      isFallback: false,
    );
  }

  @override
  String toString() {
    return 'UserLocation(lat: $latitude, lng: $longitude, status: $status, isFallback: $isFallback, message: $message)';
  }
}

class LocationService {
  /// Determines the user's position safely.
  /// If permissions are not granted or services are disabled, returns a safe fallback.
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return UserLocation.fallback(
          status: LocationStatus.serviceDisabled,
          message: 'Location services are disabled on this device.',
        );
      }

      // 2. Check current permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return UserLocation.fallback(
            status: LocationStatus.permissionDenied,
            message: 'Location permission was denied by the user.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return UserLocation.fallback(
          status: LocationStatus.permissionDeniedForever,
          message: 'Location permission is permanently denied in settings.',
        );
      }

      // 3. Attempt to fetch current position with timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: timeout,
          ),
        );
        return UserLocation.actual(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } on TimeoutException {
        // Fallback to last known position if current request timed out
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return UserLocation.actual(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
          );
        }
        return UserLocation.fallback(
          status: LocationStatus.error,
          message: 'Location request timed out and no cached position found.',
        );
      }
    } catch (e) {
      return UserLocation.fallback(
        status: LocationStatus.error,
        message: 'Unexpected location error: ${e.toString()}',
      );
    }
  }

  /// Opens the device app settings if permission is permanently denied.
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Opens the device location service settings if location service is disabled.
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }
}
