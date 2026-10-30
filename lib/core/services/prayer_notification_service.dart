import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/iqama/iqama_settings_controller.dart';
import '../../features/widget_prayer_times/models/prayer_times_model.dart';
import '../data/local_data/hive_manager.dart';
import '../data/remote_data/prayer_times/prayer_times_service.dart';
import 'location_service.dart';
import 'prayer_notification_plan.dart';

/// The only owner of prayer/Iqama schedules. OS delivery never needs Dart running.
class PrayerNotificationService extends ChangeNotifier
    with WidgetsBindingObserver {
  static final instance = PrayerNotificationService();

  final FlutterLocalNotificationsPlugin plugin;
  final HiveManager hiveManager;
  final PrayerTimesService prayerTimesService;
  final DateTime Function() now;
  String status = 'Tap to allow prayer notifications and exact reminders.';
  bool initialized = false;
  bool requestingPermission = false;
  bool disposed = false;
  bool previouslyAllowed = false;
  UserLocation? location;
  PrayerTimesModel? timetable;
  StreamSubscription<dynamic>? settingsSubscription;
  Future<void> work = Future.value();
  int revision = 0;
  final Set<String> failedDates = {};

  PrayerNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    HiveManager? hiveManager,
    PrayerTimesService? prayerTimesService,
    DateTime Function()? now,
  }) : plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       hiveManager = hiveManager ?? HiveManager(),
       prayerTimesService = prayerTimesService ?? PrayerTimesService(),
       now = now ?? DateTime.now;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (initialized || !supported) return;
    tz_data.initializeTimeZones();
    try {
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_prayer_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      initialized = true;
      WidgetsBinding.instance.addObserver(this);
      settingsSubscription = hiveManager.watchIqamaSettings().listen(
        (_) => unawaited(refresh()),
      );
    } catch (_) {
      setStatus(
        'Could not initialize prayer notifications. Reopen the app to retry.',
      );
    }
  }

  /// Called only by an explicit Settings tap; lifecycle updates never prompt.
  Future<void> requestPermissions() async {
    if (!initialized || requestingPermission) return;
    requestingPermission = true;
    failedDates.clear();
    notifyListeners();
    try {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final allowed = await android.requestNotificationsPermission();
        if (allowed == true &&
            await android.canScheduleExactNotifications() != true) {
          await android.requestExactAlarmsPermission();
        }
      } else {
        await plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true, badge: true);
      }
      await refresh();
    } catch (_) {
      setStatus(
        'Could not request notification access. Check system settings.',
      );
    } finally {
      requestingPermission = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<bool> hasPermission() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      if (await android.areNotificationsEnabled() != true) {
        setStatus(
          'Notifications are disabled. Tap to allow them or check system settings.',
        );
        return false;
      }
      if (await android.canScheduleExactNotifications() != true) {
        setStatus(
          'Exact reminder access is required. Tap to allow Alarms & reminders.',
        );
        return false;
      }
    } else {
      final permissions = await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      if (permissions?.isEnabled != true ||
          permissions?.isAlertEnabled != true) {
        setStatus(
          'Notifications are disabled. Tap to allow them or check system settings.',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> update(PrayerTimesModel? model, UserLocation? userLocation) {
    if (!initialized) return Future.value();
    timetable = model;
    location = userLocation;
    failedDates.clear();
    return refresh();
  }

  /// Serialize updates so a late API/plugin result cannot overwrite a newer choice.
  Future<void> refresh() {
    if (!initialized || disposed) return Future.value();
    final requestedRevision = ++revision;
    work = work
        .then((_) async {
          if (requestedRevision == revision && !disposed) {
            await synchronize(requestedRevision);
          }
        })
        .catchError((Object error) {
          setStatus('Could not update prayer reminders. Tap to retry.');
        });
    return work;
  }

  Future<void> synchronize(int requestedRevision) async {
    final pending = await plugin.pendingNotificationRequests();
    final owned = pending
        .where((event) => event.payload?.startsWith('deenora_prayer:') ?? false)
        .toList();
    final currentLocation = location;
    final allowed = await hasPermission();
    if (requestedRevision != revision || disposed) return;
    final restoreAlarms = allowed && !previouslyAllowed;
    previouslyAllowed = allowed;
    if (!allowed || currentLocation == null || currentLocation.isFallback) {
      for (final event in owned) {
        await plugin.cancel(id: event.id);
      }
      if (allowed) {
        setStatus(
          'Prayer reminders paused: detect your location first; Cairo fallback is not used.',
        );
      }
      return;
    }

    final models = <PrayerTimesModel>[
      ?timetable,
      ?hiveManager.loadPrayerTimes(),
      ?hiveManager.loadNotificationTimetable(),
    ];
    final dates = <String>{};
    final verified = <PrayerTimesModel>[];
    for (final model in models) {
      if (PrayerNotificationPlan.verifiedDate(model, currentLocation) == null) {
        continue;
      }
      if (verified.isNotEmpty &&
          model.meta.timezone != verified.first.meta.timezone) {
        continue;
      }
      if (dates.add(model.gregorian.date)) verified.add(model);
    }
    if (verified.isEmpty) {
      for (final event in owned) {
        await plugin.cancel(id: event.id);
      }
      setStatus(
        'No verified timetable matches this location. Refresh prayer times.',
      );
      return;
    }
    final zone = tz.getLocation(verified.first.meta.timezone);
    final localNow = tz.TZDateTime.from(now(), zone);
    for (var day = 0; day < 2; day++) {
      // Calendar arithmetic, not +24 hours (DST days need not have 24 hours).
      final target = tz.TZDateTime(
        zone,
        localNow.year,
        localNow.month,
        localNow.day + day,
      );
      final found = verified.any(
        (m) =>
            PrayerNotificationPlan.verifiedDate(m, currentLocation) == target,
      );
      final key =
          '${currentLocation.latitude},${currentLocation.longitude}:${target.year}-${target.month}-${target.day}';
      if (found) {
        // Yesterday's cached "tomorrow" becomes today's ordinary offline cache.
        final cached = hiveManager.loadPrayerTimes();
        if (day == 0 &&
            (cached == null ||
                PrayerNotificationPlan.verifiedDate(cached, currentLocation) !=
                    target)) {
          await hiveManager.savePrayerTimes(
            verified.firstWhere(
              (model) =>
                  PrayerNotificationPlan.verifiedDate(model, currentLocation) ==
                  target,
            ),
          );
        }
        continue;
      }
      if (failedDates.contains(key)) continue;
      try {
        final model = await prayerTimesService.getPrayerTimesByCoordinates(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          date: DateTime.utc(target.year, target.month, target.day),
        );
        if (requestedRevision != revision || disposed) return;
        if (PrayerNotificationPlan.verifiedDate(model, currentLocation) !=
                target ||
            model.meta.timezone != zone.name) {
          failedDates.add(key);
          continue;
        }
        verified.add(model);
        if (day == 0) {
          await hiveManager.savePrayerTimes(model);
        } else {
          await hiveManager.saveNotificationTimetable(model);
        }
      } catch (_) {
        failedDates.add(key);
      }
    }
    if (requestedRevision != revision || disposed) return;
    final events = PrayerNotificationPlan.build(
      timetables: verified,
      location: currentLocation,
      iqama: IqamaSettings.fromStorage(hiveManager.loadIqamaSettings()),
      now: now(),
    );
    final desiredIds = events.map((event) => event.id).toSet();
    for (final event in owned) {
      if (!desiredIds.contains(event.id)) await plugin.cancel(id: event.id);
    }
    for (final event in events) {
      if (requestedRevision != revision || disposed) return;
      if (!event.time.isAfter(now())) continue;
      if (!restoreAlarms &&
          owned.any(
            (p) =>
                p.id == event.id &&
                p.payload == event.payload &&
                p.title == event.title &&
                p.body == event.body,
          )) {
        continue;
      }
      await plugin.zonedSchedule(
        id: event.id,
        title: event.title,
        body: event.body,
        // Store an absolute instant so changing the device zone cannot shift it.
        scheduledDate: tz.TZDateTime.from(event.time, tz.UTC),
        payload: event.payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'deenora.prayer_reminders',
            'Prayer & Iqama reminders',
            channelDescription: 'Prayer start and custom Iqama reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
    setStatus(
      events.isEmpty
          ? 'No future verified prayers available. Refresh prayer times.'
          : 'Prayer reminders scheduled through ${events.last.time.day}/${events.last.time.month}. Tap to recheck access.',
    );
  }

  void setStatus(String value) {
    if (disposed || status == value) return;
    status = value;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      failedDates.clear();
      unawaited(refresh());
    }
  }

  @override
  void dispose() {
    disposed = true;
    revision++;
    WidgetsBinding.instance.removeObserver(this);
    settingsSubscription?.cancel();
    super.dispose();
  }
}
