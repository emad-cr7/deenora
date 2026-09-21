import 'dart:io';
import 'package:deenora/core/data/local_data/hive_config.dart';
import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/core/data/remote_data/prayer_times/prayer_times_service.dart';
import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:deenora/core/data/remote_data/verse_day/verse_day_service.dart';
import 'package:deenora/core/services/location_service.dart';
import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'package:deenora/features/main/main_screen.dart';
import 'package:deenora/features/mosque/feature_cards/feature_cards_section.dart';
import 'package:deenora/features/mosque/verse_of_the_day/controllers/verse_day_controller.dart';
import 'package:deenora/features/mosque/verse_of_the_day/models/verse_day_model.dart';
import 'package:deenora/features/mosque/verse_of_the_day/widgets/verse_day_card.dart';
import 'package:deenora/features/mosque/widgets/mosque_prayer_section.dart';
import 'package:deenora/features/tasbeeh/controllers/tasbeeh_controller.dart';
import 'package:deenora/features/tasbeeh/models/dhikr_model.dart';
import 'package:deenora/features/tasbeeh/models/tasbih_dataset_model.dart';
import 'package:deenora/features/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:deenora/features/widget_prayer_times/models/hijri_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_date_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_meta_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_times_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_type.dart';
import 'package:deenora/features/widget_prayer_times/widgets/prayer_progress_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// --- Test doubles ---

class _FakeFailingPrayerService extends PrayerTimesService {
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

class _FakeSuccessPrayerService extends PrayerTimesService {
  final PrayerTimesModel model;
  _FakeSuccessPrayerService(this.model);

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    return model;
  }
}

class _FakeFixedLocationService extends LocationService {
  final double lat = 30.0444;
  final double lng = 31.2357;
  _FakeFixedLocationService();

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
      message: 'No location available',
    );
  }
}

class _FakeFailingDio extends Fake implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
      message: 'No internet connection',
    );
  }
}

class _FakeFailingTasbeehService extends TasbeehService {
  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    throw Exception('SocketException: Connection refused (offline)');
  }
}

class _FakeSuccessTasbeehService extends TasbeehService {
  final List<DhikrModel> items;
  _FakeSuccessTasbeehService(this.items);

  @override
  Future<TasbihDatasetModel> getTasbihData({bool forceRefresh = false}) async {
    return TasbihDatasetModel(attribution: 'Tasbih.info', dhikrList: items);
  }
}

class _FakeAudioPlayerCoordinator extends ChangeNotifier
    implements AudioPlayerCoordinator {
  @override
  bool get hasActiveSession => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStaticVerseService extends VerseDayService {
  final VerseDayModel model;
  _FakeStaticVerseService(this.model);

  @override
  Future<VerseDayModel> getVerseOfTheDay({
    required String savedDate,
  }) async {
    return model;
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

VerseDayModel _createSampleVerseModel({String? savedDate}) {
  return VerseDayModel(
    text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    surahNumber: 1,
    surahEnglishName: 'Al-Faatiha',
    numberInSurah: 1,
    savedDate: savedDate ?? DateTime.now().toString().split(' ').first,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveManager hiveManager;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('deenora_mosque_offline_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    hiveManager = HiveManager();
    await hiveManager.init();
  });

  setUp(() async {
    await hiveManager.clear();
    final verseBox = await Hive.openBox<dynamic>(HiveConfig.verseOfTheDayBox);
    await verseBox.clear();
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

  group('HiveManager - Prayer Times & Default Dhikr Persistence', () {
    test('Can save and load PrayerTimesModel with all nested fields', () async {
      final model = _createSamplePrayerModel();
      await hiveManager.savePrayerTimes(model);

      final loaded = hiveManager.loadPrayerTimes();
      expect(loaded, isNotNull);
      expect(loaded!.readableDate, '13 Sep 2026');
      expect(loaded.getTimeFor(PrayerType.fajr), '05:00');
      expect(loaded.getTimeFor(PrayerType.maghrib), '18:45');
      expect(loaded.hijri.monthAr, 'ربيع الثاني');
      expect(loaded.gregorian.monthEn, 'September');
      expect(loaded.meta.timezone, 'Africa/Cairo');
    });

    test(
      'Can save and load default Dhikrs separately from custom Dhikrs',
      () async {
        final defaultList = [
          const DhikrModel(
            id: 'subhanallah',
            name: 'SubhanAllah',
            arabic: 'سبحان الله',
            narratedCount: 33,
          ),
          const DhikrModel(
            id: 'alhamdulillah',
            name: 'Alhamdulillah',
            arabic: 'الحمد لله',
            narratedCount: 33,
          ),
        ];

        await hiveManager.saveDefaultDhikrs(defaultList);

        final loadedDefaults = hiveManager.loadDefaultDhikrs();
        expect(loadedDefaults.length, 2);
        expect(loadedDefaults[0].id, 'subhanallah');
        expect(loadedDefaults[1].id, 'alhamdulillah');

        // Custom dhikrs box remains separate and empty
        expect(hiveManager.loadCustomDhikrs(), isEmpty);

        // Save a custom dhikr
        await hiveManager.saveCustomDhikr(
          const DhikrModel(
            id: 'custom_1',
            name: 'My Custom',
            arabic: 'دعاء خاص',
            customGoal: 100,
          ),
        );

        // Verify separation
        expect(hiveManager.loadCustomDhikrs().length, 1);
        expect(hiveManager.loadDefaultDhikrs().length, 2);
      },
    );

    test('clear() clears prayer times and default dhikrs boxes', () async {
      await hiveManager.savePrayerTimes(_createSamplePrayerModel());
      await hiveManager.saveDefaultDhikrs([
        const DhikrModel(id: 'test', name: 'Test', arabic: 'تست'),
      ]);

      expect(hiveManager.loadPrayerTimes(), isNotNull);
      expect(hiveManager.loadDefaultDhikrs(), isNotEmpty);

      await hiveManager.clear();

      expect(hiveManager.loadPrayerTimes(), isNull);
      expect(hiveManager.loadDefaultDhikrs(), isEmpty);
    });
  });

  group('PrayerTimesController - Offline Fallback via Hive', () {
    test('Caches prayer times upon successful API fetch', () async {
      final sample = _createSamplePrayerModel();
      final controller = PrayerTimesController(
        locationService: _FakeFixedLocationService(),
        prayerTimesService: _FakeSuccessPrayerService(sample),
        hiveManager: hiveManager,
      );

      await controller.loadPrayerTimes();
      expect(controller.hasError, isFalse);
      expect(controller.prayerTimes, isNotNull);

      // Verify persisted in Hive
      final cached = hiveManager.loadPrayerTimes();
      expect(cached, isNotNull);
      expect(cached!.readableDate, sample.readableDate);
      controller.dispose();
    });

    test(
      'Loads cached prayer times and runs countdown when API is offline',
      () async {
        // Pre-seed Hive with cached prayer times
        final sample = _createSamplePrayerModel();
        await hiveManager.savePrayerTimes(sample);

        // Controller with failing API service (simulating offline)
        final controller = PrayerTimesController(
          locationService: _FakeFailingLocationService(),
          prayerTimesService: _FakeFailingPrayerService(),
          hiveManager: hiveManager,
        );

        await controller.loadPrayerTimes();

        // Controller should successfully fallback to cached prayer times
        expect(controller.hasError, isFalse);
        expect(controller.prayerTimes, isNotNull);
        expect(controller.prayerTimes!.readableDate, sample.readableDate);
        expect(controller.countdown, isNotNull);
        expect(controller.prayerItems, isNotEmpty);
        controller.dispose();
      },
    );

    test(
      'Sets hasError when API is offline and NO cached prayer times exist',
      () async {
        // Hive is empty
        final controller = PrayerTimesController(
          locationService: _FakeFailingLocationService(),
          prayerTimesService: _FakeFailingPrayerService(),
          hiveManager: hiveManager,
        );

        await controller.loadPrayerTimes();

        expect(controller.hasError, isTrue);
        expect(controller.prayerTimes, isNull);
        expect(controller.countdown, isNull);
        controller.dispose();
      },
    );
  });

  group('MosqueScreen - Decoupled Offline UI', () {
    testWidgets(
      'Offline with no cache: does NOT show full AppErrorScreen, renders inline error and feature cards',
      (tester) async {
        final controller = PrayerTimesController(
          locationService: _FakeFailingLocationService(),
          prayerTimesService: _FakeFailingPrayerService(),
          hiveManager: hiveManager,
        );

        await controller.loadPrayerTimes();
        expect(controller.hasError, isTrue);
        expect(controller.prayerTimes, isNull);

        final sampleVerse = _createSampleVerseModel();
        await hiveManager.saveVerseOfTheDay(sampleVerse.toStoredMap());
        final verseController = VerseDayController()..init();

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
              child: Scaffold(
                body: ListView(
                  children: const [
                    MosquePrayerSection(),
                    FeatureCardsSection(),
                    VerseDayCard(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Full screen AppErrorScreen is NOT shown
        expect(find.byType(AppErrorScreen), findsNothing);

        // Inline error is shown in the prayer slot
        expect(find.text('Prayer Times Offline'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // FeatureCardsSection (Qibla & Tasbeeh) is fully rendered and accessible!
        expect(find.byType(FeatureCardsSection), findsOneWidget);
        expect(find.text('Qibla'), findsOneWidget);
        expect(find.text('Tasbeeh'), findsOneWidget);

        // Verse of the Day is rendered
        expect(find.byType(VerseDayCard), findsOneWidget);

        controller.dispose();
        verseController.dispose();
      },
    );

    testWidgets(
      'Offline with cache: renders PrayerProgressCard with countdown, Qibla and Tasbeeh',
      (tester) async {
        final sample = _createSamplePrayerModel();
        await tester.runAsync(() async {
          await hiveManager.savePrayerTimes(sample);
        });

        final controller = PrayerTimesController(
          locationService: _FakeFailingLocationService(),
          prayerTimesService: _FakeFailingPrayerService(),
          hiveManager: hiveManager,
        );

        await tester.runAsync(() async {
          await controller.loadPrayerTimes();
        });
        expect(controller.prayerTimes, isNotNull);

        final sampleVerse = _createSampleVerseModel();
        await tester.runAsync(() async {
          await hiveManager.saveVerseOfTheDay(sampleVerse.toStoredMap());
        });

        final verseController = VerseDayController();
        await tester.runAsync(() async {
          verseController.init();
          await verseController.verseOfTheDayFuture;
        });

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
              child: Scaffold(
                body: ListView(
                  children: const [
                    MosquePrayerSection(),
                    FeatureCardsSection(),
                    VerseDayCard(),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // PrayerProgressCard is rendered
        expect(find.byType(PrayerProgressCard), findsOneWidget);
        expect(find.byType(FeatureCardsSection), findsOneWidget);
        expect(find.text('Qibla'), findsOneWidget);
        expect(find.text('Tasbeeh'), findsOneWidget);

        controller.dispose();
        verseController.dispose();
      },
    );
  });

  group('VerseOfTheDayService - Offline Local Quran Fallback', () {
    test('Falls back to local Quran in Hive when network fails', () async {
      final today = DateTime.now().toString().split(' ').first;
      final sample = _createSampleVerseModel(savedDate: today);
      await hiveManager.saveVerseOfTheDay(sample.toStoredMap());

      final controller = VerseDayController();
      controller.init();
      final verse = await controller.verseOfTheDayFuture;

      expect(verse, isNotNull);
      expect(verse.text, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
      expect(verse.surahNumber, 1);
      expect(verse.surahEnglishName, 'Al-Faatiha');
      expect(verse.numberInSurah, 1);
      expect(verse.savedDate, today);
      controller.dispose();
    });

    test(
      'Throws exception when offline and local Quran is empty in Hive',
      () async {
        await HttpOverrides.runZoned(
          () async {
            final controller = VerseDayController();
            controller.init();

            expect(
              () async => await controller.verseOfTheDayFuture,
              throwsA(isA<Exception>()),
            );
            controller.dispose();
          },
          createHttpClient: (context) =>
              throw const SocketException('Connection refused (offline)'),
        );
      },
    );
  });

  group('TasbeehController - Offline Default Dhikr Fallback', () {
    test(
      'Saves default Dhikrs on API success and restores them on API failure',
      () async {
        final defaultItems = [
          const DhikrModel(
            id: 'subhanallah',
            name: 'SubhanAllah',
            arabic: 'سبحان الله',
            narratedCount: 33,
          ),
          const DhikrModel(
            id: 'allahuakbar',
            name: 'Allahu Akbar',
            arabic: 'الله أكبر',
            narratedCount: 34,
          ),
        ];

        // 1. Online session saves to Hive
        final onlineController = TasbeehController(
          tasbeehService: _FakeSuccessTasbeehService(defaultItems),
          hiveManager: hiveManager,
        );
        await onlineController.loadDhikr();
        expect(onlineController.dhikrList.length, 2);

        // Verify saved to Hive
        final cached = hiveManager.loadDefaultDhikrs();
        expect(cached.length, 2);

        // 2. Offline session restores from Hive
        final offlineController = TasbeehController(
          tasbeehService: _FakeFailingTasbeehService(),
          hiveManager: hiveManager,
        );
        offlineController.init();
        await offlineController.loadDhikr();

        expect(offlineController.hasError, isFalse);
        expect(offlineController.dhikrList.length, 2);
        expect(offlineController.currentDhikr?.id, 'subhanallah');
        expect(offlineController.targetCount, 33);

        // Counter works offline
        offlineController.increment();
        expect(offlineController.count, 1);
      },
    );

    test(
      'Fresh install offline with no cached data shows error screen',
      () async {
        // Empty Hive, failing service
        final freshController = TasbeehController(
          tasbeehService: _FakeFailingTasbeehService(),
          hiveManager: hiveManager,
        );

        await freshController.loadDhikr();

        expect(freshController.hasError, isTrue);
        expect(freshController.dhikrList, isEmpty);
        expect(freshController.errorType, AppErrorType.noInternet);
      },
    );
  });

  group('MainScreen - IndexedStack Tab State Preservation', () {
    testWidgets('IndexedStack keeps all tab views alive in widget tree', (
      tester,
    ) async {
      final testPages = [
        const Text('Page 0: Mosque'),
        const Text('Page 1: Quran'),
        const Text('Page 2: Azkar'),
        const Text('Page 3: Profile'),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioPlayerCoordinator>.value(
          value: _FakeAudioPlayerCoordinator(),
          child: MaterialApp(home: MainScreen(pages: testPages)),
        ),
      );

      await tester.pump();

      // MainScreen contains an IndexedStack
      expect(find.byType(IndexedStack), findsOneWidget);

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.children.length, 4);
      expect(indexedStack.index, 0);
      expect(find.text('Page 0: Mosque'), findsOneWidget);

      // Switch to Quran tab (index 1)
      await tester.tap(find.text('Quran'));
      await tester.pump();

      final updatedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(updatedStack.index, 1);
      expect(find.text('Page 1: Quran'), findsOneWidget);

      // Switch back to Mosque tab (index 0)
      await tester.tap(find.text('mosque'));
      await tester.pump();

      final backStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(backStack.index, 0);
      expect(find.text('Page 0: Mosque'), findsOneWidget);
    });
  });
}
