import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/prayer_times/prayer_times_service.dart';
import '../../../../core/services/location_service.dart';
import '../models/models.dart';
import '../utils/prayer_time_calculator.dart';

class PrayerTimesController extends ChangeNotifier {
  // Services المسؤولين عن الموقع، API، والتخزين المحلي.
  final LocationService _locationService;
  final PrayerTimesService _prayerTimesService;
  final HiveManager _hiveManager;

  PrayerTimesController({
    LocationService? locationService,
    PrayerTimesService? prayerTimesService,
    HiveManager? hiveManager,
  }) : _locationService = locationService ?? LocationService(),
        _prayerTimesService = prayerTimesService ?? PrayerTimesService(),
        _hiveManager = hiveManager ?? HiveManager();

  // Timer لتحديث الـ Countdown كل ثانية.
  Timer? _ticker;

  // حالة التحميل والخطأ.
  bool _isLoading = false;
  String? _errorMessage;

  // بيانات الموقع ومواقيت الصلاة.
  UserLocation? _userLocation;
  PrayerTimesModel? _prayerTimes;

  // قائمة مواقيت الصلاة الجاهزة للـ UI.
  List<PrayerTimeItem> _prayerItems = [];

  // لمعرفة إذا انتقلنا ليوم جديد.
  DateTime? _lastLoadedDate;

  // يحدث الـ Countdown فقط بدون إعادة بناء الشاشة بالكامل.
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

  // معرفة الصلاة الحالية والسابقة حسب الوقت الحالي.
  CurrentAndPreviousPrayer? get currentAndPreviousPrayer {
    if (_prayerTimes == null) return null;

    return PrayerTimeCalculator.calculateCurrentAndPrevious(
      _prayerTimes!,
      DateTime.now(),
    );
  }

  // بداية تشغيل الـ Controller وتحميل مواقيت الصلاة.
  void init() {
    loadPrayerTimes();
  }

  // تحميل الموقع + مواقيت الصلاة + حفظها + تشغيل الـ Timer.
  Future<void> loadPrayerTimes({bool refreshLocation = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // الحصول على موقع المستخدم إذا لزم الأمر.
      if (refreshLocation || _userLocation == null) {
        try {
          _userLocation = await _locationService.determinePosition();
        } catch (_) {
          _userLocation = null;
        }
      }

      // استخدام الموقع الاحتياطي إذا فشل تحديد الموقع.
      _userLocation ??= UserLocation.fallback(
        status: LocationStatus.error,
        message: 'Unable to detect location.',
      );

      final latitude = _userLocation!.latitude;
      final longitude = _userLocation!.longitude;

      // جلب مواقيت الصلاة من الـ API.
      _prayerTimes = await _prayerTimesService.getPrayerTimesByCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      // حفظ المواقيت محليًا لاستخدامها عند فشل الـ API.
      await _hiveManager.savePrayerTimes(_prayerTimes!);

      final now = DateTime.now();
      _lastLoadedDate = DateTime(now.year, now.month, now.day);

      // حساب الـ Countdown وقائمة الصلاة.
      _updateCalculations(now);

      // بدء التحديث كل ثانية.
      _startTicker();
    } catch (e) {
      // لو الـ API فشل، استخدم البيانات المحفوظة في Hive.
      final cached = _hiveManager.loadPrayerTimes();

      if (cached != null) {
        _prayerTimes = cached;
        _errorMessage = null;

        final now = DateTime.now();
        _lastLoadedDate = DateTime(now.year, now.month, now.day);

        _updateCalculations(now);
        _startTicker();
      } else {
        // لا يوجد API ولا Cache → عرض الخطأ.
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _stopTicker();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إعادة طلب الموقع وتحميل المواقيت من جديد.
  Future<void> retryWithPermissionRequest() async {
    await loadPrayerTimes(refreshLocation: true);
  }

  // فتح إعدادات التطبيق.
  Future<bool> openAppSettings() async {
    return _locationService.openAppSettings();
  }

  // فتح إعدادات الموقع.
  Future<bool> openLocationSettings() async {
    return _locationService.openLocationSettings();
  }

  // تحديث الـ Countdown وقائمة مواقيت الصلاة.
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

  // تشغيل Timer يعمل كل ثانية.
  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _onTick(),
    );
  }

  // إيقاف الـ Timer.
  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  // يتنفذ كل ثانية لتحديث الـ Countdown ومراقبة تغير الصلاة واليوم.
  void _onTick() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();

    // لو دخلنا يوم جديد، نحمل مواقيت اليوم الجديد.
    if (_lastLoadedDate != null && now.day != _lastLoadedDate!.day) {
      _lastLoadedDate = DateTime(now.year, now.month, now.day);
      loadPrayerTimes(refreshLocation: false);
      return;
    }

    // حفظ الصلاة القادمة قبل التحديث.
    final previousNextPrayer = _countdownNotifier.value?.nextPrayer;

    // تحديث الـ Countdown كل ثانية.
    final newCountdown = PrayerTimeCalculator.calculateCountdown(
      _prayerTimes!,
      now,
    );

    _countdownNotifier.value = newCountdown;

    // لو الصلاة القادمة تغيرت، حدث قائمة الصلوات والـ UI.
    if (newCountdown.nextPrayer != previousNextPrayer) {
      _prayerItems = PrayerTimeCalculator.calculatePrayerItems(
        _prayerTimes!,
        now,
      );

      notifyListeners();
      return;
    }

    // تحديث قائمة الصلوات مرة كل دقيقة.
    if (now.second == 0) {
      _prayerItems = PrayerTimeCalculator.calculatePrayerItems(
        _prayerTimes!,
        now,
      );

      notifyListeners();
    }
  }

  // تنظيف الـ Timer والـ ValueNotifier عند إغلاق الـ Controller.
  @override
  void dispose() {
    _stopTicker();
    _countdownNotifier.dispose();
    super.dispose();
  }
}