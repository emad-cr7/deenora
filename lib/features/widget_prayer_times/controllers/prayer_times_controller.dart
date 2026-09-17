import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/data/remote_data/prayer_times/prayer_times_service.dart';
import '../../../../core/services/location_service.dart';
import '../models/models.dart';
import '../utils/prayer_time_calculator.dart';

class PrayerTimesController extends ChangeNotifier {
  final LocationService _locationService;
  final PrayerTimesService _prayerTimesService;

  PrayerTimesController({
    LocationService? locationService,
    PrayerTimesService? prayerTimesService,
  }) : _locationService = locationService ?? LocationService(),
       _prayerTimesService = prayerTimesService ?? PrayerTimesService();

  Timer? _ticker;
  bool _isLoading = false;
  String? _errorMessage;
  UserLocation? _userLocation;
  PrayerTimesModel? _prayerTimes;
  List<PrayerTimeItem> _prayerItems = [];
  DateTime? _lastLoadedDate;

  /// Dedicated ValueNotifier for the 1-second countdown ticker.
  /// Listening to this allows isolated widget rebuilds for the timer
  /// without triggering full-screen or list rebuilds every second.
  final ValueNotifier<NextPrayerCountdown?> _countdownNotifier =
      ValueNotifier<NextPrayerCountdown?>(null);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  UserLocation? get userLocation => _userLocation;
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  List<PrayerTimeItem> get prayerItems => _prayerItems;
  ValueListenable<NextPrayerCountdown?> get countdownNotifier =>
      _countdownNotifier;
  NextPrayerCountdown? get countdown => _countdownNotifier.value;

  CurrentAndPreviousPrayer? get currentAndPreviousPrayer {
    if (_prayerTimes == null) return null;
    return PrayerTimeCalculator.calculateCurrentAndPrevious(
      _prayerTimes!,
      DateTime.now(),
    );
  }

  void init() {
    loadPrayerTimes();
  }

  /// Loads the user's location and fetches prayer times from the API.
  Future<void> loadPrayerTimes({bool refreshLocation = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (refreshLocation || _userLocation == null) {
        _userLocation = await _locationService.determinePosition();
      }

      final latitude = _userLocation!.latitude;
      final longitude = _userLocation!.longitude;

      _prayerTimes = await _prayerTimesService.getPrayerTimesByCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      final now = DateTime.now();
      _lastLoadedDate = DateTime(now.year, now.month, now.day);
      _updateCalculations(now);
      _startTicker();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _stopTicker();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-triggers location permission request and reloads if granted.
  Future<void> retryWithPermissionRequest() async {
    await loadPrayerTimes(refreshLocation: true);
  }

  /// Opens application settings on the device.
  Future<bool> openAppSettings() async {
    return _locationService.openAppSettings();
  }

  /// Opens device location settings.
  Future<bool> openLocationSettings() async {
    return _locationService.openLocationSettings();
  }

  void _updateCalculations(DateTime now) {
    if (_prayerTimes == null) return;
    _countdownNotifier.value = PrayerTimeCalculator.calculateCountdown(
      _prayerTimes!,
      now,
    );
    _prayerItems = PrayerTimeCalculator.calculatePrayerItems(
      _prayerTimes!,
      now,
    );
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onTick() {
    if (_prayerTimes == null) return;
    final now = DateTime.now();

    // 1. Midnight day rollover detection
    if (_lastLoadedDate != null && now.day != _lastLoadedDate!.day) {
      _lastLoadedDate = DateTime(now.year, now.month, now.day);
      loadPrayerTimes(refreshLocation: false);
      return;
    }

    final previousNextPrayer = _countdownNotifier.value?.nextPrayer;

    // 2. Update countdown (ticks every second via ValueNotifier only)
    final newCountdown = PrayerTimeCalculator.calculateCountdown(
      _prayerTimes!,
      now,
    );
    _countdownNotifier.value = newCountdown;

    // 3. If the prayer transitioned (e.g. from Asr to Maghrib), update list states
    if (newCountdown.nextPrayer != previousNextPrayer) {
      _prayerItems = PrayerTimeCalculator.calculatePrayerItems(
        _prayerTimes!,
        now,
      );
      notifyListeners();
      return;
    }

    // 4. Every full minute (at second 0), update elapsed minutes on list items
    if (now.second == 0) {
      _prayerItems = PrayerTimeCalculator.calculatePrayerItems(
        _prayerTimes!,
        now,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTicker();
    _countdownNotifier.dispose();
    super.dispose();
  }
}
