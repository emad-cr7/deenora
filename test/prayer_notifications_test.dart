import 'dart:async';
import 'dart:io';

import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/core/data/remote_data/prayer_times/prayer_times_service.dart';
import 'package:deenora/core/services/location_service.dart';
import 'package:deenora/core/services/prayer_notification_plan.dart';
import 'package:deenora/core/services/prayer_notification_service.dart';
import 'package:deenora/features/settings/iqama/iqama_settings_controller.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_times_model.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_type.dart';
import 'package:deenora/features/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final cairo = UserLocation.actual(latitude: 30.0444, longitude: 31.2357);

PrayerTimesModel timetable(
  DateTime date, {
  Map<String, String> times = const {},
  String zone = 'Africa/Cairo',
  double latitude = 30.0444,
  double longitude = 31.2357,
  String? dateText,
}) => PrayerTimesModel.fromJson({
  'timings': {
    'Fajr': '05:00',
    'Sunrise': '06:30',
    'Dhuhr': '12:00',
    'Asr': '15:00',
    'Maghrib': '17:00',
    'Isha': '19:00',
    ...times,
  },
  'date': {
    'gregorian': {
      'date':
          dateText ??
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
      'day': date.day.toString(),
      'month': {'number': date.month},
      'year': date.year.toString(),
    },
  },
  'meta': {'latitude': latitude, 'longitude': longitude, 'timezone': zone},
});

class NotificationHive implements HiveManager {
  PrayerTimesModel? today;
  PrayerTimesModel? tomorrow;
  Object? iqama;
  final changes = StreamController<BoxEvent>.broadcast();
  @override
  PrayerTimesModel? loadPrayerTimes() => today;
  @override
  PrayerTimesModel? loadNotificationTimetable() => tomorrow;
  @override
  Object? loadIqamaSettings() => iqama;
  @override
  Stream<BoxEvent> watchIqamaSettings() => changes.stream;
  @override
  Future<void> savePrayerTimes(PrayerTimesModel model) async {
    today = model;
  }

  @override
  Future<void> saveNotificationTimetable(PrayerTimesModel model) async {
    tomorrow = model;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class NotificationApi extends PrayerTimesService {
  bool offline = false;
  int calls = 0;
  Completer<PrayerTimesModel>? pending;
  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    calls++;
    if (pending != null) return pending!.future;
    if (offline) throw StateError('Offline');
    return timetable(date!, latitude: latitude, longitude: longitude);
  }
}

class ChangingLocation extends LocationService {
  UserLocation location = cairo;
  @override
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async => location;
}

class RacingPrayerApi extends PrayerTimesService {
  final requests = <double, Completer<PrayerTimesModel>>{};
  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) {
    final result = Completer<PrayerTimesModel>();
    requests[longitude] = result;
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  final today = DateTime.utc(2026, 11, 1);

  test(
    'a late previous location response cannot replace the latest controller data',
    () async {
      final location = ChangingLocation();
      final api = RacingPrayerApi();
      final hive = NotificationHive();
      final controller = PrayerTimesController(
        locationService: location,
        prayerTimesService: api,
        hiveManager: hive,
      );
      addTearDown(controller.dispose);
      addTearDown(hive.changes.close);
      final oldLoad = controller.loadPrayerTimes();
      while (api.requests.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }
      location.location = UserLocation.actual(latitude: 21.4, longitude: 39.8);
      final newLoad = controller.loadPrayerTimes();
      while (!api.requests.containsKey(39.8)) {
        await Future<void>.delayed(Duration.zero);
      }
      api.requests[39.8]!.complete(
        timetable(today, latitude: 21.4, longitude: 39.8),
      );
      await newLoad;
      api.requests[cairo.longitude]!.complete(timetable(today));
      await oldLoad;
      expect(controller.prayerTimes?.meta.longitude, 39.8);
      expect(hive.today?.meta.longitude, 39.8);
    },
  );
  List<PrayerNotification> plan(
    List<PrayerTimesModel> models, {
    IqamaSettings? iqama,
    DateTime? now,
    UserLocation? location,
  }) => PrayerNotificationPlan.build(
    timetables: models,
    location: location ?? cairo,
    iqama: iqama ?? IqamaSettings(),
    now: now ?? today,
  );

  group('Verified notification planning', () {
    test('all five prayers use their actual start times, never Sunrise', () {
      final events = plan([timetable(today)]);
      expect(events.map((e) => e.prayer), IqamaSettings.defaultDelays.keys);
      expect(events.map((e) => e.time.hour), [5, 12, 15, 17, 19]);
      expect(events.every((e) => !e.isIqama), isTrue);
      expect(events.first.time.toUtc().hour, 3);
      expect(events.map((e) => e.id).toSet().length, 5);
    });

    test('saved individual delays create separate stable Iqama events', () {
      final settings = IqamaSettings.fromStorage({
        'enabled': true,
        'delays': {'fajr': 1, 'dhuhr': 2, 'asr': 3, 'maghrib': 4, 'isha': 0},
      });
      final events = plan([timetable(today)], iqama: settings);
      expect(events.length, 10);
      for (final prayer in IqamaSettings.defaultDelays.keys) {
        final start = events.firstWhere(
          (e) => e.prayer == prayer && !e.isIqama,
        );
        final iqama = events.firstWhere((e) => e.prayer == prayer && e.isIqama);
        expect(
          iqama.time.difference(start.time).inMinutes,
          settings.delays[prayer],
        );
        expect(iqama.id, start.id + 1);
      }
      expect(
        plan([timetable(today)], iqama: settings).map((e) => e.id),
        events.map((e) => e.id),
      );
    });

    test('past events and stale or distant dates are excluded', () {
      final events = plan([
        timetable(today),
      ], now: DateTime.utc(2026, 11, 1, 10));
      expect(events.map((e) => e.prayer), [
        PrayerType.asr,
        PrayerType.maghrib,
        PrayerType.isha,
      ]);
      expect(plan([timetable(DateTime.utc(2026, 10, 30))]), isEmpty);
      expect(plan([timetable(DateTime.utc(2026, 11, 3))]), isEmpty);
    });

    test('invalid hours and missing API fields do not become midnight', () {
      expect(
        plan([
          timetable(
            today,
            times: {'Fajr': '25:00', 'Dhuhr': '12:70', 'Asr': 'oops'},
          ),
        ]).length,
        2,
      );
      final missing = PrayerTimesModel.fromJson({
        'timings': <String, String>{},
      });
      expect(missing.timings[PrayerType.fajr], '');
      expect(PrayerTimesModel.cleanTime(null), '');
      expect(PrayerTimesModel.cleanTime('00:00'), '00:00');
    });

    test(
      'wrong coordinates, unknown zones, invalid dates and Cairo fallback are rejected',
      () {
        expect(plan([timetable(today, longitude: 39)]), isEmpty);
        expect(plan([timetable(today, zone: 'Not/AZone')]), isEmpty);
        expect(
          plan(
            [timetable(today)],
            location: UserLocation.fallback(
              status: LocationStatus.permissionDenied,
            ),
          ),
          isEmpty,
        );
        final invalid = timetable(today);
        final data = PrayerTimesModel(
          timings: invalid.timings,
          imsak: '',
          sunset: '',
          midnight: '',
          firstThird: '',
          lastThird: '',
          readableDate: '',
          hijri: invalid.hijri,
          gregorian: timetable(DateTime.utc(2026, 11, 2)).gregorian,
          meta: invalid.meta,
        );
        expect(plan([data]).every((e) => e.time.day == 2), isTrue);
        expect(
          PrayerNotificationPlan.verifiedDate(
            timetable(today, latitude: double.nan),
            cairo,
          ),
          isNull,
        );
        expect(
          PrayerNotificationPlan.verifiedDate(
            timetable(today, dateText: '31-02-2026'),
            cairo,
          ),
          isNull,
        );
      },
    );

    test(
      'tomorrow Fajr uses tomorrow data across month and year boundaries',
      () {
        final dec31 = DateTime.utc(2026, 12, 31);
        final jan1 = DateTime.utc(2027, 1, 1);
        final events = plan([
          timetable(dec31),
          timetable(jan1, times: {'Fajr': '05:17'}),
        ], now: DateTime.utc(2026, 12, 31, 20));
        expect(events.first.time.year, 2027);
        expect(events.first.time.month, 1);
        expect(events.first.time.minute, 17);
      },
    );

    test(
      'Isha Iqama crosses midnight without changing the prayer start date',
      () {
        final events = plan(
          [
            timetable(today, times: {'Isha': '23:30'}),
          ],
          iqama: IqamaSettings(enabled: true, delays: {PrayerType.isha: 180}),
          now: DateTime.utc(2026, 11, 2, 0),
        );
        expect(events.length, 1);
        expect(events.single.isIqama, isTrue);
        expect(events.single.time.day, 2);
        expect(events.single.time.hour, 2);
        expect(events.single.time.minute, 30);
      },
    );

    test(
      'DST gaps and folds are rejected; device offset does not determine prayer time',
      () {
        final ny = UserLocation.actual(latitude: 40.7128, longitude: -74.0060);
        final gap = plan(
          [
            timetable(
              DateTime.utc(2026, 3, 8),
              zone: 'America/New_York',
              latitude: ny.latitude,
              longitude: ny.longitude,
              times: {'Fajr': '02:30'},
            ),
          ],
          location: ny,
          now: DateTime.utc(2026, 3, 8),
        );
        expect(gap.any((e) => e.prayer == PrayerType.fajr), isFalse);
        final fold = plan([
          timetable(
            today,
            zone: 'America/New_York',
            latitude: ny.latitude,
            longitude: ny.longitude,
            times: {'Fajr': '01:30'},
          ),
        ], location: ny);
        expect(fold.any((e) => e.prayer == PrayerType.fajr), isFalse);
        final events = plan([
          timetable(today),
        ], now: tz.TZDateTime(tz.getLocation('Asia/Tokyo'), 2026, 11, 1, 9));
        expect(events.first.time.location.name, 'Africa/Cairo');
      },
    );
  });

  group('OS scheduling reconciliation (mock platform channel)', () {
    // The plugin itself checks the real clock before invoking its channel.
    final today = DateTime.utc(DateTime.now().year + 1, 11, 1);
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    late NotificationHive hive;
    late NotificationApi api;
    late PrayerNotificationService service;
    late Map<int, Map<String, dynamic>> pending;
    bool notificationsAllowed = true;
    bool exactAllowed = true;
    int schedules = 0;
    int permissionRequests = 0;
    late DateTime currentTime;

    setUp(() async {
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      hive = NotificationHive()..today = timetable(today);
      api = NotificationApi();
      pending = {
        7: {'id': 7, 'title': 'Quran', 'body': '', 'payload': 'other-feature'},
      };
      notificationsAllowed = true;
      exactAllowed = true;
      schedules = 0;
      permissionRequests = 0;
      currentTime = today;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'initialize':
                return true;
              case 'areNotificationsEnabled':
                return notificationsAllowed;
              case 'canScheduleExactNotifications':
                return exactAllowed;
              case 'requestNotificationsPermission':
                permissionRequests++;
                return notificationsAllowed;
              case 'requestExactAlarmsPermission':
                permissionRequests++;
                return exactAllowed;
              case 'checkPermissions':
                return {
                  'isEnabled': notificationsAllowed,
                  'isAlertEnabled': notificationsAllowed,
                };
              case 'requestPermissions':
                permissionRequests++;
                return notificationsAllowed;
              case 'pendingNotificationRequests':
                return pending.values.toList();
              case 'zonedSchedule':
                final args = Map<String, dynamic>.from(call.arguments as Map);
                pending[args['id'] as int] = args;
                schedules++;
                return null;
              case 'cancel':
                pending.remove((call.arguments as Map)['id']);
                return null;
              default:
                throw StateError('Unexpected platform method ${call.method}');
            }
          });
      service = PrayerNotificationService(
        hiveManager: hive,
        prayerTimesService: api,
        now: () => currentTime,
      );
      await service.initialize();
      expect(service.initialized, isTrue);
    });

    tearDown(() async {
      await service.work;
      service.dispose();
      debugDefaultTargetPlatformOverride = null;
      await hive.changes.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'schedules two verified days once, preserves unrelated notifications and caches tomorrow',
      () async {
        await service.update(hive.today, cairo);
        expect(schedules, 10);
        expect(pending.length, 11);
        expect(
          pending.values
              .where((p) => p['id'] != 7)
              .every((p) => p['timeZoneName'] == tz.UTC.name),
          isTrue,
        );
        expect(hive.tomorrow?.gregorian.date, '02-11-${today.year}');
        expect(api.calls, 1);
        await service.update(hive.today, cairo);
        expect(schedules, 10);
        expect(api.calls, 1);
        service.previouslyAllowed =
            false; // Fresh process/recovery must safely replace stable IDs.
        await service.refresh();
        expect(pending.length, 11);
        expect(pending[7]?['title'], 'Quran');
      },
    );

    test(
      'saved delay updates stable IDs and disabling cancels only Iqama',
      () async {
        hive.iqama = IqamaSettings(enabled: true).toStorage();
        await service.update(hive.today, cairo);
        expect(pending.length, 21);
        final firstIqama = pending.entries.firstWhere(
          (e) => e.key != 7 && e.key.isOdd,
        );
        final oldTime = firstIqama.value['scheduledDateTime'];
        hive.iqama = IqamaSettings(
          enabled: true,
          delays: {PrayerType.fajr: 30},
        ).toStorage();
        await service.refresh();
        expect(pending.length, 21);
        expect(pending[firstIqama.key]?['scheduledDateTime'], isNot(oldTime));
        hive.iqama = IqamaSettings(enabled: false).toStorage();
        hive.changes.add(BoxEvent('iqama_settings', hive.iqama, false));
        await Future<void>.delayed(Duration.zero);
        await service.work;
        expect(pending.length, 11);
        expect(
          pending.keys.where((id) => id != 7).every((id) => id.isEven),
          isTrue,
        );
      },
    );

    test(
      'denied notifications or exact access cancel owned schedules without automatic prompts',
      () async {
        await service.update(hive.today, cairo);
        notificationsAllowed = false;
        await service.refresh();
        expect(pending.keys, [7]);
        expect(permissionRequests, 0);
        notificationsAllowed = true;
        exactAllowed = false;
        await service.refresh();
        expect(pending.keys, [7]);
        expect(service.status, contains('Exact'));
        expect(permissionRequests, 0);
        await service.requestPermissions();
        expect(permissionRequests, 2);
      },
    );

    test(
      'new location and fallback never retain the previous location schedules',
      () async {
        await service.update(hive.today, cairo);
        await service.update(
          hive.today,
          UserLocation.actual(latitude: 21.4, longitude: 39.8),
        );
        expect(pending.keys, [7]);
        await service.update(
          timetable(today, latitude: 21.4, longitude: 39.8),
          UserLocation.actual(latitude: 21.4, longitude: 39.8),
        );
        expect(pending.length, 11);
        await service.update(
          hive.today,
          UserLocation.fallback(status: LocationStatus.error),
        );
        expect(pending.keys, [7]);
      },
    );

    test(
      'offline schedules only valid cached dates; invalid fetched dates are not invented',
      () async {
        api.offline = true;
        await service.update(hive.today, cairo);
        expect(pending.length, 6);
        final calls = api.calls;
        await service.refresh();
        expect(api.calls, calls);
        hive.today = timetable(DateTime.utc(2026, 10, 20));
        await service.update(hive.today, cairo);
        expect(pending.keys, [7]);
      },
    );

    test(
      'latest update wins when a previous API request completes late',
      () async {
        api.pending = Completer<PrayerTimesModel>();
        final oldUpdate = service.update(hive.today, cairo);
        while (api.calls == 0) {
          await Future<void>.delayed(Duration.zero);
        }
        final newUpdate = service.update(null, null);
        api.pending!.complete(timetable(DateTime.utc(2026, 11, 2)));
        await oldUpdate;
        await newUpdate;
        expect(pending.keys, [7]);
      },
    );

    test('tomorrow API response with today date is rejected', () async {
      api.pending = Completer<PrayerTimesModel>();
      final update = service.update(hive.today, cairo);
      while (api.calls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      api.pending!.complete(timetable(today));
      await update;
      expect(pending.length, 6);
      expect(hive.tomorrow, isNull);
    });

    test(
      'date rollover promotes verified cached tomorrow before fetching the next day',
      () async {
        await service.update(hive.today, cairo);
        currentTime = today.add(const Duration(days: 1));
        service.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await service.work;
        expect(hive.today?.gregorian.date, '02-11-${today.year}');
        expect(hive.tomorrow?.gregorian.date, '03-11-${today.year}');
        expect(pending.length, 11);
        final calls = api.calls;
        await service.refresh();
        expect(api.calls, calls);
        expect(permissionRequests, 0);
      },
    );

    test(
      'iOS checks authorization without prompting on resume and schedules after user action',
      () async {
        service.dispose();
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        IOSFlutterLocalNotificationsPlugin.registerWith();
        service = PrayerNotificationService(
          hiveManager: hive,
          prayerTimesService: api,
          now: () => today,
        );
        await service.initialize();
        notificationsAllowed = false;
        await service.update(hive.today, cairo);
        expect(pending.keys, [7]);
        expect(permissionRequests, 0);
        notificationsAllowed = true;
        await service.requestPermissions();
        expect(permissionRequests, 1);
        expect(pending.length, 11);
        expect(pending.length, lessThan(64));
      },
    );
  });

  test(
    'Hive persists tomorrow using existing adapters without replacing today or preferences',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'deenora_notification_hive_',
      );
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, (_) async => directory.path);
      final manager = HiveManager();
      try {
        await manager.init();
        await manager.savePrayerTimes(timetable(today));
        await manager.saveSelectedMuadhinId('saved-muadhin');
        await manager.saveIqamaSettings(
          IqamaSettings(enabled: true).toStorage(),
        );
        await manager.saveNotificationTimetable(
          timetable(DateTime.utc(2026, 11, 2)),
        );
        await Hive.close();
        Hive.resetAdapters();
        await manager.init();
        expect(manager.loadPrayerTimes()?.gregorian.date, '01-11-2026');
        expect(
          manager.loadNotificationTimetable()?.gregorian.date,
          '02-11-2026',
        );
        expect(manager.loadSelectedMuadhinId(), 'saved-muadhin');
        expect(
          IqamaSettings.fromStorage(manager.loadIqamaSettings()).enabled,
          isTrue,
        );
      } finally {
        await Hive.close();
        Hive.resetAdapters();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(pathChannel, null);
        await directory.delete(recursive: true);
      }
    },
  );
}
