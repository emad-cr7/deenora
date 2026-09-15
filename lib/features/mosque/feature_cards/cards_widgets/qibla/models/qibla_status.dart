/// Represents the various lifecycle and sensor states of the Qibla compass.
enum QiblaStatus {
  /// Initializing hardware checks and awaiting sensor stream data.
  loading,

  /// Active and receiving live heading and Qibla calculations.
  ready,

  /// Location permission was denied by the user.
  permissionDenied,

  /// Location permission is permanently denied in device settings.
  permissionDeniedForever,

  /// Location service (GPS) is turned off on the device.
  serviceDisabled,

  /// Device hardware lacks the required rotation/magnetometer sensor.
  sensorUnavailable,

  /// An unexpected error occurred while accessing compass or location data.
  error,
}
