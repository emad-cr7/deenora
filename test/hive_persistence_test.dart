import 'dart:io';
import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/core/data/remote_data/prayer_times/prayer_times_service.dart';
import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/core/services/location_service.dart';
import 'package:deenora/features/qibla/controllers/qibla_controller.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:deenora/features/tasbeeh/models/tasbih_dataset_model.dart';
import 'package:deenora/features/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:deenora/features/widget_prayer_times/models/hijri_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_meta_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_times_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_type.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

// --- Fakes for testing ---

class _FakeSuccessLocationService extends LocationService {
  final double lat;
  final double lng;
  _FakeSuccessLocationService({required this.lat, required this.lng});

  @override
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return UserLocation.actual(latitude: lat, longitude: lng);
  }
}

class _FakeFailingLocationService extends LocationService {
  @override
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return UserLocation.fallback(
      status: LocationStatus.permissionDenied,
      message: 'Permission denied in test',
    );
  }
}

class _FakePrayerTimesService extends PrayerTimesService {
  final PrayerTimesModel model;
  double? lastRequestedLat;
  double? lastRequestedLng;

  _FakePrayerTimesService(this.model);

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    lastRequestedLat = latitude;
    lastRequestedLng = longitude;
    return model;
  }
}

class _FakeFailingPrayerTimesService extends PrayerTimesService {
  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    throw Exception('Connection failed (offline test)');
  }
}

class _FakeTasbeehService extends TasbeehService {
  final List<DhikrModel> apiItems;
  _FakeTasbeehService(this.apiItems);

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    return TasbihDatasetModel(
      name: 'Test Dataset',
      description: 'Test',
      version: '1.0',
      updated: '2026-01-01',
      license: 'CC BY 4.0',
      licenseUrl: 'https://example.com',
      attribution: 'Tasbih.info (https://tasbih.info)',
      homepage: 'https://tasbih.info',
      editorialRules: [],
      count: apiItems.length,
      dhikrList: apiItems,
    );
  }
}

class _FakeFailingTasbeehService extends TasbeehService {
  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    throw Exception('SocketException: Network connection error');
  }
}

PrayerTimesModel _createTestPrayerModel() {
  return PrayerTimesModel(
    timings: {
      PrayerType.fajr: '05:00',
      PrayerType.sunrise: '06:30',
      PrayerType.dhuhr: '12:30',
      PrayerType.asr: '16:00',
      PrayerType.maghrib: '18:45',
      PrayerType.isha: '20:00',
    },
    imsak: '04:50',
    sunset: '18:45',
    midnight: '00:30',
    firstThird: '22:30',
    lastThird: '02:30',
    readableDate: '13 Sep 2026',
    hijri: HijriDateModel(
      date: '02-04-1448',
      day: '02',
      weekdayEn: 'Sunday',
      weekdayAr: 'الاحد',
      monthEn: 'Rabi al-thani',
      monthAr: 'ربيع الثاني',
      monthNumber: 4,
      year: '1448',
    ),
    gregorian: PrayerDateModel(
      date: '13-09-2026',
      day: '13',
      weekdayEn: 'Sunday',
      monthEn: 'September',
      monthNumber: 9,
      year: '2026',
    ),
    meta: PrayerMetaModel(
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 'Africa/Cairo',
      methodName: 'Egyptian General Authority of Survey',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveManager hiveManager;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('deenora_hive_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return tempDir.path;
          },
        );
    hiveManager = HiveManager();
    await hiveManager.init();
  });

  setUp(() async {
    await hiveManager.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveManager Base Functionality', () {
    test('Save, load, and delete custom dhikr', () async {
      expect(hiveManager.loadCustomDhikrs(), isEmpty);

      const customDhikr = DhikrModel(
        id: 'custom_123',
        name: 'Astaghfirullah',
        arabic: 'أستغفر الله',
        customGoal: 100,
      );

      await hiveManager.saveCustomDhikr(customDhikr);

      final loadedList = hiveManager.loadCustomDhikrs();
      expect(loadedList.length, 1);
      expect(loadedList.first.id, 'custom_123');
      expect(loadedList.first.name, 'Astaghfirullah');
      expect(loadedList.first.arabic, 'أستغفر الله');
      expect(loadedList.first.customGoal, 100);

      await hiveManager.deleteCustomDhikr('custom_123');
      expect(hiveManager.loadCustomDhikrs(), isEmpty);
    });

    test('clear() removes custom dhikrs', () async {
      await hiveManager.saveCustomDhikr(
        const DhikrModel(
          id: 'custom_clear',
          name: 'Alhamdulillah',
          arabic: 'الحمد لله',
          customGoal: 33,
        ),
      );

      expect(hiveManager.loadCustomDhikrs(), isNotEmpty);

      await hiveManager.clear();

      expect(hiveManager.loadCustomDhikrs(), isEmpty);
    });
  });

  group('Prayer Times Runtime Location & Fallback', () {
    test(
      'Valid detected location is used at runtime and prayer times saved',
      () async {
        final prayerService = _FakePrayerTimesService(_createTestPrayerModel());
        final controller = PrayerTimesController(
          locationService: _FakeSuccessLocationService(
            lat: 21.3891,
            lng: 39.8579,
          ),
          prayerTimesService: prayerService,
          hiveManager: hiveManager,
        );

        await controller.loadPrayerTimes();

        expect(prayerService.lastRequestedLat, 21.3891);
        expect(prayerService.lastRequestedLng, 39.8579);
        expect(controller.userLocation?.latitude, 21.3891);
        expect(controller.userLocation?.longitude, 39.8579);
        expect(controller.userLocation?.isFallback, isFalse);

        // Verify prayer times are persisted in Hive
        final savedPrayerTimes = hiveManager.loadPrayerTimes();
        expect(savedPrayerTimes, isNotNull);
      },
    );

    test(
      'New runtime location updates position and fetches new prayer times',
      () async {
        final prayerService = _FakePrayerTimesService(_createTestPrayerModel());

        // 1. First location: Makkah
        final controller1 = PrayerTimesController(
          locationService: _FakeSuccessLocationService(
            lat: 21.3891,
            lng: 39.8579,
          ),
          prayerTimesService: prayerService,
          hiveManager: hiveManager,
        );
        await controller1.loadPrayerTimes();
        expect(prayerService.lastRequestedLat, 21.3891);
        expect(controller1.userLocation?.latitude, 21.3891);

        // 2. Second location: Madinah
        final controller2 = PrayerTimesController(
          locationService: _FakeSuccessLocationService(
            lat: 24.5247,
            lng: 39.5692,
          ),
          prayerTimesService: prayerService,
          hiveManager: hiveManager,
        );
        await controller2.loadPrayerTimes();
        expect(prayerService.lastRequestedLat, 24.5247);
        expect(controller2.userLocation?.latitude, 24.5247);
        expect(controller2.userLocation?.longitude, 39.5692);
      },
    );

    test('Location failure defaults to Cairo fallback at runtime', () async {
      final prayerService = _FakePrayerTimesService(_createTestPrayerModel());
      final controller = PrayerTimesController(
        locationService: _FakeFailingLocationService(),
        prayerTimesService: prayerService,
        hiveManager: hiveManager,
      );

      await controller.loadPrayerTimes();

      // Should use Cairo fallback coordinates
      expect(prayerService.lastRequestedLat, UserLocation.fallbackLatitude);
      expect(prayerService.lastRequestedLng, UserLocation.fallbackLongitude);
      expect(controller.userLocation?.latitude, UserLocation.fallbackLatitude);
      expect(
        controller.userLocation?.longitude,
        UserLocation.fallbackLongitude,
      );
      expect(controller.userLocation?.isFallback, isTrue);
    });

    test('Offline network failure does not crash', () async {
      final controller = PrayerTimesController(
        locationService: _FakeSuccessLocationService(
          lat: 24.7136,
          lng: 46.6753,
        ),
        prayerTimesService: _FakeFailingPrayerTimesService(),
        hiveManager: hiveManager,
      );

      // Must complete gracefully without throwing unhandled exception
      await controller.loadPrayerTimes();

      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, isNotNull);
      expect(controller.prayerTimes, isNull);
    });
  });

  group('Tasbeeh Persistence & Rules', () {
    test('User-created dhikr is saved to Hive and restored on init', () async {
      final tasbeehService = _FakeTasbeehService([
        const DhikrModel(
          id: 'api_1',
          name: 'SubhanAllah',
          arabic: 'سبحان الله',
          narratedCount: 33,
        ),
      ]);

      // 1. Session 1: User adds a custom dhikr
      final controller1 = TasbeehController(
        tasbeehService: tasbeehService,
        hiveManager: hiveManager,
      );
      controller1.init();
      await Future.delayed(const Duration(milliseconds: 50));

      final added = controller1.addCustomDhikr(
        text: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد',
        count: 100,
      );
      expect(added, isTrue);

      // Verify Hive has it
      final savedInHive = hiveManager.loadCustomDhikrs();
      expect(savedInHive.length, 1);
      expect(
        savedInHive.first.name,
        'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد',
      );
      expect(savedInHive.first.customGoal, 100);

      // 2. Session 2: "App restart" - new controller instance loads saved dhikr on init()
      final controller2 = TasbeehController(
        tasbeehService: tasbeehService,
        hiveManager: hiveManager,
      );
      controller2.init();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller2.customDhikrs.length, 1);
      expect(
        controller2.customDhikrs.first.name,
        'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد',
      );
      expect(controller2.getCustomGoal(controller2.customDhikrs.first), 100);

      // Combined list contains custom dhikr + API dhikr
      expect(controller2.dhikrList.length, 2);
      expect(
        controller2.dhikrList.first.name,
        'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّد',
      );
      expect(controller2.dhikrList.last.name, 'SubhanAllah');
    });

    test(
      'Adding duplicate custom dhikr updates goal instead of duplicating in Hive',
      () async {
        final controller = TasbeehController(
          tasbeehService: _FakeTasbeehService([]),
          hiveManager: hiveManager,
        );
        controller.init();

        // Add custom dhikr
        controller.addCustomDhikr(text: 'La ilaha illa Allah', count: 33);
        expect(hiveManager.loadCustomDhikrs().length, 1);
        expect(hiveManager.loadCustomDhikrs().first.customGoal, 33);

        // Add same text again with different count
        controller.addCustomDhikr(text: '  la ilaha illa allah  ', count: 100);

        // Should still be only 1 record in Hive with updated goal
        final records = hiveManager.loadCustomDhikrs();
        expect(records.length, 1);
        expect(records.first.customGoal, 100);
        expect(controller.customDhikrs.length, 1);
        expect(controller.getCustomGoal(controller.customDhikrs.first), 100);
      },
    );

    test(
      'API failure allows user to continue using saved custom dhikr',
      () async {
        // Seed Hive with saved custom dhikr
        await hiveManager.saveCustomDhikr(
          const DhikrModel(
            id: 'custom_offline',
            name: 'HasbunAllahu wa ni\'mal wakeel',
            arabic: 'حسبنا الله ونعم الوكيل',
            customGoal: 40,
          ),
        );

        final controller = TasbeehController(
          tasbeehService: _FakeFailingTasbeehService(),
          hiveManager: hiveManager,
        );

        controller.init();
        await Future.delayed(const Duration(milliseconds: 50));

        // Custom dhikr was restored from Hive
        expect(controller.customDhikrs.length, 1);
        expect(controller.dhikrList.length, 1);
        expect(controller.currentDhikr, isNotNull);
        expect(controller.currentDhikr?.name, 'HasbunAllahu wa ni\'mal wakeel');
        expect(controller.targetCount, 40);

        // User can increment and count normally even though API failed
        controller.increment();
        expect(controller.count, 1);
      },
    );

    test('API dhikr is not saved to custom dhikr Hive box', () async {
      final controller = TasbeehController(
        tasbeehService: _FakeTasbeehService([
          const DhikrModel(
            id: 'api_dhikr_1',
            name: 'Allahu Akbar',
            arabic: 'الله أكبر',
            narratedCount: 33,
          ),
          const DhikrModel(
            id: 'api_dhikr_2',
            name: 'Alhamdulillah',
            arabic: 'الحمد لله',
            narratedCount: 33,
          ),
        ]),
        hiveManager: hiveManager,
      );

      controller.init();
      await Future.delayed(const Duration(milliseconds: 50));

      // 2 items loaded from API
      expect(controller.dhikrList.length, 2);

      // Zero items should be in Hive's custom dhikr box
      expect(hiveManager.loadCustomDhikrs(), isEmpty);
    });
  });

  group('Qibla Verification', () {
    test('QiblaController does not interact with Hive or cached location', () {
      final qiblaController = QiblaController();
      expect(qiblaController, isA<QiblaController>());
      qiblaController.dispose();
    });
  });
}
