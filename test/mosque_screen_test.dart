import 'dart:io';
import 'package:deenora/core/data/local_data/hive_config.dart';
import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/core/data/remote_data/prayer_times/prayer_times_service.dart';
import 'package:deenora/core/services/location_service.dart';
import 'package:deenora/features/mosque/mosque_screen.dart';
import 'package:deenora/features/mosque/verse_of_the_day/controllers/verse_day_controller.dart';
import 'package:deenora/features/mosque/verse_of_the_day/models/verse_day_model.dart';
import 'package:deenora/features/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:deenora/features/widget_prayer_times/models/hijri_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_meta_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_times_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class _FakePrayerTimesService extends PrayerTimesService {
  final PrayerTimesModel model;
  int callCount = 0;

  _FakePrayerTimesService(this.model);

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    callCount++;
    return model;
  }
}

class _FakeLocationService extends LocationService {
  @override
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return UserLocation.actual(latitude: 30.0444, longitude: 31.2357);
  }
}

class _FakeVerseDayController extends VerseDayController {
  final VerseDayModel sampleModel;

  _FakeVerseDayController(this.sampleModel);

  @override
  void init() {
    isLoading = false;
    error = null;
    verse = sampleModel;
    verseOfTheDayFuture = Future.value(sampleModel);
  }

  @override
  void retry() {
    init();
    notifyListeners();
  }
}

PrayerTimesModel _createSamplePrayerModel() {
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

VerseDayModel _createSampleVerseModel() {
  return const VerseDayModel(
    text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    surahNumber: 1,
    surahEnglishName: 'Al-Faatiha',
    numberInSurah: 1,
    savedDate: '2026-09-21',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveManager hiveManager;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('deenora_mosque_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    hiveManager = HiveManager();
    await hiveManager.init();
  });

  tearDownAll(() async {
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  setUp(() async {
    await hiveManager.clear();
    final verseBox = await Hive.openBox<dynamic>(HiveConfig.verseOfTheDayBox);
    await verseBox.clear();
  });

  testWidgets(
    'MosqueScreen refreshes prayer times without throwing ProviderNotFoundException when provided above',
    (tester) async {
      final fakePrayerService = _FakePrayerTimesService(
        _createSamplePrayerModel(),
      );
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: fakePrayerService,
        hiveManager: hiveManager,
      );

      await tester.runAsync(() async {
        await controller.loadPrayerTimes();
      });

      final verseController = _FakeVerseDayController(
        _createSampleVerseModel(),
      );
      verseController.init();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<PrayerTimesController>.value(
                value: controller,
              ),
              ChangeNotifierProvider<VerseDayController>.value(
                value: verseController,
              ),
            ],
            child: const MosqueScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
      final initialCount = fakePrayerService.callCount;

      // Trigger onRefresh
      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await tester.runAsync(() async {
        await refreshIndicator.onRefresh();
      });
      await tester.pump();

      expect(fakePrayerService.callCount, initialCount + 1);

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      verseController.dispose();
    },
  );

  testWidgets(
    'MosqueScreen refreshes prayer times without throwing ProviderNotFoundException when using constructor controller',
    (tester) async {
      final fakePrayerService = _FakePrayerTimesService(
        _createSamplePrayerModel(),
      );
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: fakePrayerService,
        hiveManager: hiveManager,
      );

      await tester.runAsync(() async {
        await controller.loadPrayerTimes();
      });

      final verseController = _FakeVerseDayController(
        _createSampleVerseModel(),
      );
      verseController.init();

      await tester.pumpWidget(MaterialApp(home: MosqueScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
      final initialCount = fakePrayerService.callCount;

      // Trigger onRefresh via RefreshIndicator widget callback directly
      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await tester.runAsync(() async {
        await refreshIndicator.onRefresh();
      });
      await tester.pump();

      expect(fakePrayerService.callCount, initialCount + 1);

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      verseController.dispose();
    },
  );
}
