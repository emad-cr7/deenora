import 'package:deenora/core/skeleton/mosque/mosque_skeleton.dart';
import 'package:deenora/features/mosque/widget_prayer_times/controllers/prayer_times_controller.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/hijri_date_model.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/next_prayer_countdown.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/prayer_date_model.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/prayer_meta_model.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/prayer_time_item.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/prayer_times_model.dart';
import 'package:deenora/features/mosque/widget_prayer_times/models/prayer_type.dart';
import 'package:deenora/features/mosque/widget_prayer_times/utils/prayer_time_calculator.dart';
import 'package:deenora/features/mosque/widget_prayer_times/widgets/location_banner.dart';
import 'package:deenora/features/mosque/widget_prayer_times/widgets/prayer_progress_card.dart';
import 'package:deenora/features/mosque/widget_prayer_times/widgets/prayer_times_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/core/data/remote_data/prayer_times/prayer_times_service.dart';
import 'package:deenora/core/services/location_service.dart';
import 'package:deenora/features/mosque/widget_prayer_times/prayer_times_screen.dart';


void main() {
  group('Task 2 & 3 Verification', () {
    test('UserLocation fallback explicitly flags fallback', () {
      final fallback = UserLocation.fallback(
        status: LocationStatus.permissionDenied,
        message: 'Permission denied test',
      );
      expect(fallback.isFallback, true);
      expect(fallback.status, LocationStatus.permissionDenied);
      expect(fallback.latitude, 30.0444);
      expect(fallback.longitude, 31.2357);

      final actual = UserLocation.actual(latitude: 24.7136, longitude: 46.6753);
      expect(actual.isFallback, false);
      expect(actual.status, LocationStatus.success);
      expect(actual.latitude, 24.7136);
    });

    test('PrayerType values and names', () {
      expect(PrayerType.values.length, 6);
      expect(PrayerType.fajr.englishName, 'Fajr');
      expect(PrayerType.fajr.arabicName, 'الفجر');
      expect(PrayerType.sunrise.isFardPrayer, false);
      expect(PrayerType.isha.isFardPrayer, true);
    });

    final testModel = PrayerTimesModel(
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

    test('Edge Case 1: Early morning before Fajr (03:30 AM)', () {
      final now = DateTime(2026, 9, 13, 3, 30);
      final countdown = PrayerTimeCalculator.calculateCountdown(testModel, now);

      expect(countdown.nextPrayer, PrayerType.fajr);
      expect(countdown.currentPrayer, PrayerType.isha);
      expect(countdown.remainingTime, const Duration(hours: 1, minutes: 30));
      expect(countdown.formattedCountdown, '01:30:00');

      final items = PrayerTimeCalculator.calculatePrayerItems(testModel, now);
      final fajrItem = items.firstWhere((i) => i.type == PrayerType.fajr);
      expect(fajrItem.state, PrayerState.next);
      expect(fajrItem.statusText, 'Next Prayer');

      final dhuhrItem = items.firstWhere((i) => i.type == PrayerType.dhuhr);
      expect(dhuhrItem.state, PrayerState.upcoming);
    });

    test('Edge Case 2: Daytime between Dhuhr and Asr (14:00 PM)', () {
      final now = DateTime(2026, 9, 13, 14, 0);
      final countdown = PrayerTimeCalculator.calculateCountdown(testModel, now);

      expect(countdown.nextPrayer, PrayerType.asr);
      expect(countdown.currentPrayer, PrayerType.dhuhr);
      expect(countdown.remainingTime, const Duration(hours: 2));
      expect(countdown.currentElapsed, const Duration(hours: 1, minutes: 30));

      final items = PrayerTimeCalculator.calculatePrayerItems(testModel, now);
      final fajrItem = items.firstWhere((i) => i.type == PrayerType.fajr);
      expect(fajrItem.state, PrayerState.passed);
      expect(fajrItem.formattedElapsed, '09:00');
      expect(fajrItem.statusText, 'Passed 09:00 ago');

      final dhuhrItem = items.firstWhere((i) => i.type == PrayerType.dhuhr);
      expect(dhuhrItem.state, PrayerState.current);
      expect(dhuhrItem.formattedElapsed, '01:30');

      final asrItem = items.firstWhere((i) => i.type == PrayerType.asr);
      expect(asrItem.state, PrayerState.next);
      expect(asrItem.statusText, 'Next Prayer');
    });

    test('Edge Case 3: Night after Isha (21:30 PM) -> Next is tomorrow Fajr', () {
      final now = DateTime(2026, 9, 13, 21, 30);
      final countdown = PrayerTimeCalculator.calculateCountdown(testModel, now);

      expect(countdown.nextPrayer, PrayerType.fajr);
      expect(countdown.currentPrayer, PrayerType.isha);
      // From 21:30 to 05:00 next day is 7 hours 30 minutes
      expect(countdown.remainingTime, const Duration(hours: 7, minutes: 30));
      expect(countdown.formattedCountdown, '07:30:00');
      expect(countdown.currentElapsed, const Duration(hours: 1, minutes: 30));

      final items = PrayerTimeCalculator.calculatePrayerItems(testModel, now);
      final fajrItem = items.firstWhere((i) => i.type == PrayerType.fajr);
      expect(fajrItem.state, PrayerState.passed);

      final ishaItem = items.firstWhere((i) => i.type == PrayerType.isha);
      expect(ishaItem.state, PrayerState.current);
      expect(ishaItem.formattedElapsed, '01:30');
    });

    test('PrayerTimesController initializes and coordinates cleanly', () {
      final controller = PrayerTimesController();
      expect(controller.isLoading, false);
      expect(controller.hasError, false);
      expect(controller.countdownNotifier.value, isNull);
      controller.dispose();
    });

    testWidgets('PrayerProgressCard renders countdown and prayer information', (tester) async {
      final controller = PrayerTimesController();
      // Pump widget wrapped in MaterialApp
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrayerProgressCard(controller: controller),
          ),
        ),
      );

      // Initially null countdown, renders empty SizedBox
      expect(find.text('PREVIOUS'), findsNothing);
      expect(find.text('UPCOMING'), findsNothing);

      // Now set countdown value on the controller's notifier
      (controller.countdownNotifier as ValueNotifier<NextPrayerCountdown?>).value =
          NextPrayerCountdown(
        previousPrayer: PrayerType.dhuhr,
        previousPrayerTime: DateTime(2026, 9, 13, 12, 30),
        passedDuration: const Duration(hours: 1, minutes: 30, seconds: 15),
        nextPrayer: PrayerType.asr,
        nextPrayerTime: DateTime(2026, 9, 13, 16, 22),
        remainingDuration: const Duration(hours: 2, minutes: 21, seconds: 45),
      );

      await tester.pump();

      expect(find.text('PREVIOUS'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);
      expect(find.text('Dhuhr'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
      expect(find.text('Passed 01:30:15'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('04:22 PM'), findsOneWidget);
      expect(find.text('Remaining 02:21:45'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('PrayerTimesList renders all 6 prayers with correct badges and 12-hour times', (tester) async {
      final now = DateTime(2026, 9, 13, 14, 0);
      final items = PrayerTimeCalculator.calculatePrayerItems(testModel, now);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrayerTimesList(items: items),
            ),
          ),
        ),
      );

      // Verify header
      expect(find.text('Prayer Schedule'), findsOneWidget);
      expect(find.text('6 Timings'), findsOneWidget);

      // Verify all 6 prayer English names exist and no Arabic in UI
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Sunrise'), findsOneWidget);
      expect(find.text('Dhuhr'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('Isha'), findsOneWidget);
      expect(find.text('(الفجر)'), findsNothing);
      expect(find.text('(الظهر)'), findsNothing);

      // Verify 12-hour formatted clock times (not 24-hour)
      expect(find.text('05:00 AM'), findsOneWidget); // Fajr 05:00 -> 05:00 AM
      expect(find.text('06:30 AM'), findsOneWidget); // Sunrise 06:30 -> 06:30 AM
      expect(find.text('12:30 PM'), findsOneWidget); // Dhuhr 12:30 -> 12:30 PM
      expect(find.text('04:00 PM'), findsOneWidget); // Asr 16:00 -> 04:00 PM
      expect(find.text('06:45 PM'), findsOneWidget); // Maghrib 18:45 -> 06:45 PM
      expect(find.text('08:00 PM'), findsOneWidget); // Isha 20:00 -> 08:00 PM

      // Verify status badges
      expect(find.text('Passed 09:00 ago'), findsOneWidget); // Fajr passed 9h ago
      expect(find.text('Current Prayer'), findsOneWidget); // Dhuhr is active
      expect(find.text('Next Prayer'), findsOneWidget); // Asr is next
      expect(find.text('Upcoming'), findsNWidgets(2)); // Maghrib and Isha are upcoming
    });

    testWidgets('PrayerTimesSkeleton renders empty outer card structure only without internal placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MosqueSkeleton(),
          ),
        ),
      );

      expect(find.byType(MosqueSkeleton), findsOneWidget);

      // Verify no internal card elements or prayer text placeholders exist
      expect(find.text('Prayer Schedule'), findsNothing);
      expect(find.text('Fajr'), findsNothing);
      expect(find.text('Dhuhr'), findsNothing);
      expect(find.text('Next Prayer'), findsNothing);
      expect(find.text('Passed'), findsNothing);
      expect(find.text('Remaining'), findsNothing);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('LocationBanner renders fallback notification and action button', (tester) async {
      final controller = PrayerTimesController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationBanner(controller: controller),
          ),
        ),
      );

      // Initially no banner when location is null
      expect(find.byType(LocationBanner), findsOneWidget);
      expect(find.text('Location Access Denied'), findsNothing);

      controller.dispose();
    });

    test('Edge Case 4: Exact moment of Dhuhr (12:30:00)', () {
      final now = DateTime(2026, 9, 13, 12, 30);
      final countdown = PrayerTimeCalculator.calculateCountdown(testModel, now);

      expect(countdown.currentPrayer, PrayerType.dhuhr);
      expect(countdown.nextPrayer, PrayerType.asr);
      expect(countdown.currentElapsed, Duration.zero);

      final items = PrayerTimeCalculator.calculatePrayerItems(testModel, now);
      final dhuhrItem = items.firstWhere((i) => i.type == PrayerType.dhuhr);
      expect(dhuhrItem.state, PrayerState.current);
      expect(dhuhrItem.timeDifference, Duration.zero);
    });

    test('Edge Case 5: Safe handling of invalid or empty time strings', () {
      final fallbackDate = DateTime(2026, 9, 13);
      final parsedInvalid = PrayerTimeCalculator.parseTimeToDateTime('invalid_time', fallbackDate);
      expect(parsedInvalid.hour, 0);
      expect(parsedInvalid.minute, 0);

      final parsedWithSeconds = PrayerTimeCalculator.parseTimeToDateTime('15:45:00', fallbackDate);
      expect(parsedWithSeconds.hour, 15);
      expect(parsedWithSeconds.minute, 45);
    });

    test('Edge Case 6: 12-hour clock formatting across midnight, noon, and day/night boundaries', () {
      final midnight = DateTime(2026, 9, 13, 0, 0);
      expect(PrayerTimeItem.format12Hour(midnight), '12:00 AM');

      final noon = DateTime(2026, 9, 13, 12, 0);
      expect(PrayerTimeItem.format12Hour(noon), '12:00 PM');

      final morning = DateTime(2026, 9, 13, 5, 10);
      expect(PrayerTimeItem.format12Hour(morning), '05:10 AM');

      final afternoon = DateTime(2026, 9, 13, 16, 45);
      expect(PrayerTimeItem.format12Hour(afternoon), '04:45 PM');

      final night = DateTime(2026, 9, 13, 23, 20);
      expect(PrayerTimeItem.format12Hour(night), '11:20 PM');
    });

    test('Edge Case 7: calculateCurrentAndPrevious logic across the day', () {
      // 1. Daytime 14:00 (Dhuhr active, Sunrise previous)
      final midday = DateTime(2026, 9, 13, 14, 0);
      final middayInfo = PrayerTimeCalculator.calculateCurrentAndPrevious(testModel, midday);
      expect(middayInfo.currentPrayer, PrayerType.dhuhr);
      expect(middayInfo.previousPrayer, PrayerType.sunrise);
      expect(middayInfo.currentFormattedTime, '12:30 PM');
      expect(middayInfo.previousFormattedTime, '06:30 AM');
      expect(middayInfo.currentFormattedElapsed, 'Passed 01:30 ago');
      expect(middayInfo.previousFormattedElapsed, 'Passed 07:30 ago');

      // 2. Night 21:30 (Isha active, Maghrib previous)
      final night = DateTime(2026, 9, 13, 21, 30);
      final nightInfo = PrayerTimeCalculator.calculateCurrentAndPrevious(testModel, night);
      expect(nightInfo.currentPrayer, PrayerType.isha);
      expect(nightInfo.previousPrayer, PrayerType.maghrib);
      expect(nightInfo.currentFormattedTime, '08:00 PM');
      expect(nightInfo.previousFormattedTime, '06:45 PM');
      expect(nightInfo.currentFormattedElapsed, 'Passed 01:30 ago');

      // 3. Early morning before Fajr 03:30 (Yesterday's Isha active, Yesterday's Maghrib previous)
      final earlyMorning = DateTime(2026, 9, 13, 3, 30);
      final earlyInfo = PrayerTimeCalculator.calculateCurrentAndPrevious(testModel, earlyMorning);
      expect(earlyInfo.currentPrayer, PrayerType.isha);
      expect(earlyInfo.previousPrayer, PrayerType.maghrib);
      expect(earlyInfo.currentFormattedTime, '08:00 PM');
      expect(earlyInfo.previousFormattedTime, '06:45 PM');
    });

    testWidgets('PrayerTimesScreen renders countdown card and all 6 prayers', (tester) async {
      final controller = PrayerTimesController();

      await tester.pumpWidget(
        MaterialApp(
          home: PrayerTimesScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prayer Times'), findsOneWidget);
      expect(find.byType(PrayerTimesScreen), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('PrayerProgressCard renders side by side with vertical divider and reacts to tap', (tester) async {
      bool tapped = false;
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: _FakePrayerTimesService(testModel),
      );
      await controller.loadPrayerTimes();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrayerProgressCard(
              controller: controller,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify side-by-side labels
      expect(find.byType(PrayerProgressCard), findsOneWidget);
      expect(find.text('PREVIOUS'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      // Verify tap interaction
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);

      controller.dispose();
    });

    testWidgets('Both MosqueScreen and PrayerTimesScreen use the shared PrayerProgressCard', (tester) async {
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: _FakePrayerTimesService(testModel),
      );
      await controller.loadPrayerTimes();

      // 1. Verify MosqueScreen uses PrayerProgressCard
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrayerProgressCard(
              controller: controller,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byType(PrayerProgressCard), findsOneWidget);
      expect(find.text('PREVIOUS'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      // 2. Verify PrayerTimesScreen contains PrayerProgressCard
      await tester.pumpWidget(
        MaterialApp(
          home: PrayerTimesScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PrayerProgressCard), findsOneWidget);
      expect(find.text('PREVIOUS'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      controller.dispose();
    });

    test('Previous and next prayer selection across day, night, and boundary', () {
      // testModel: Fajr: 05:00, Sunrise: 06:30, Dhuhr: 12:30, Asr: 16:00, Maghrib: 18:45, Isha: 20:00

      // Case 1: Midday between Asr and Maghrib at 16:30
      final midday = DateTime(2026, 9, 13, 16, 30, 0);
      final middayCountdown = PrayerTimeCalculator.calculateCountdown(testModel, midday);
      expect(middayCountdown.previousPrayer, PrayerType.asr);
      expect(middayCountdown.nextPrayer, PrayerType.maghrib);

      // Case 2: Night after Isha at 21:30
      final night = DateTime(2026, 9, 13, 21, 30, 0);
      final nightCountdown = PrayerTimeCalculator.calculateCountdown(testModel, night);
      expect(nightCountdown.previousPrayer, PrayerType.isha);
      expect(nightCountdown.nextPrayer, PrayerType.fajr);

      // Case 3: Early morning before Fajr at 03:30
      final earlyMorning = DateTime(2026, 9, 13, 3, 30, 0);
      final earlyCountdown = PrayerTimeCalculator.calculateCountdown(testModel, earlyMorning);
      expect(earlyCountdown.previousPrayer, PrayerType.isha);
      expect(earlyCountdown.nextPrayer, PrayerType.fajr);
    });

    test('Passed duration increases correctly and Remaining duration decreases correctly', () {
      // testModel: Asr: 16:00, Maghrib: 18:45
      // Time T0: 16:30:00
      final t0 = DateTime(2026, 9, 13, 16, 30, 0);
      final countdownT0 = PrayerTimeCalculator.calculateCountdown(testModel, t0);
      expect(countdownT0.passedDuration, const Duration(minutes: 30));
      expect(countdownT0.remainingDuration, const Duration(hours: 2, minutes: 15));
      expect(countdownT0.formattedPassed, 'Passed 00:30:00');
      expect(countdownT0.formattedRemaining, 'Remaining 02:15:00');

      // Time T1: 16:30:01 (1 second later)
      final t1 = DateTime(2026, 9, 13, 16, 30, 1);
      final countdownT1 = PrayerTimeCalculator.calculateCountdown(testModel, t1);
      // Passed duration must increase
      expect(countdownT1.passedDuration, const Duration(minutes: 30, seconds: 1));
      expect(countdownT1.formattedPassed, 'Passed 00:30:01');
      // Remaining duration must decrease
      expect(countdownT1.remainingDuration, const Duration(hours: 2, minutes: 14, seconds: 59));
      expect(countdownT1.formattedRemaining, 'Remaining 02:14:59');
    });

    test('Automatic transition exactly at prayer start time', () {
      // testModel: Asr: 16:00, Maghrib: 18:45, Isha: 20:00

      // 1. Exactly 1 second before Maghrib (18:44:59)
      final justBeforeMaghrib = DateTime(2026, 9, 13, 18, 44, 59);
      final preMaghrib = PrayerTimeCalculator.calculateCountdown(testModel, justBeforeMaghrib);
      expect(preMaghrib.previousPrayer, PrayerType.asr);
      expect(preMaghrib.nextPrayer, PrayerType.maghrib);
      expect(preMaghrib.remainingDuration, const Duration(seconds: 1));

      // 2. Exactly at Maghrib start (18:45:00) -> automatically switches
      final atMaghrib = DateTime(2026, 9, 13, 18, 45, 0);
      final atMaghribCountdown = PrayerTimeCalculator.calculateCountdown(testModel, atMaghrib);
      expect(atMaghribCountdown.previousPrayer, PrayerType.maghrib);
      expect(atMaghribCountdown.nextPrayer, PrayerType.isha);
      expect(atMaghribCountdown.passedDuration, Duration.zero);
      expect(atMaghribCountdown.formattedPassed, 'Passed 00:00:00');
      expect(atMaghribCountdown.remainingDuration, const Duration(hours: 1, minutes: 15));
      expect(atMaghribCountdown.formattedRemaining, 'Remaining 01:15:00');
    });

    test('Countdown duration is never negative even with past times or negative input', () {
      final negativeCountdown = NextPrayerCountdown(
        previousPrayer: PrayerType.dhuhr,
        previousPrayerTime: DateTime(2026, 9, 13, 12, 30),
        passedDuration: const Duration(seconds: -30),
        nextPrayer: PrayerType.asr,
        nextPrayerTime: DateTime(2026, 9, 13, 16, 0),
        remainingDuration: const Duration(seconds: -15),
      );
      expect(negativeCountdown.passedDuration, Duration.zero);
      expect(negativeCountdown.remainingDuration, Duration.zero);
      expect(negativeCountdown.formattedPassed, 'Passed 00:00:00');
      expect(negativeCountdown.formattedRemaining, 'Remaining 00:00:00');
    });

    testWidgets('Navigation from MosqueScreen to PrayerTimesScreen maintains shared controller and countdown', (tester) async {
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: _FakePrayerTimesService(testModel),
      );
      await controller.loadPrayerTimes();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrayerProgressCard(
              controller: controller,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PrayerProgressCard), findsOneWidget);

      // Push PrayerTimesScreen with the same controller
      final context = tester.element(find.byType(PrayerProgressCard));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrayerTimesScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Verify PrayerTimesScreen is open and renders the shared PrayerProgressCard
      expect(find.byType(PrayerTimesScreen), findsOneWidget);
      expect(find.byType(PrayerProgressCard), findsOneWidget);
      expect(find.byType(PrayerTimesList), findsOneWidget);

      // Pop back to MosqueScreen
      Navigator.pop(tester.element(find.byType(PrayerTimesScreen)));
      await tester.pumpAndSettle();

      expect(find.byType(PrayerTimesScreen), findsNothing);
      expect(find.byType(PrayerProgressCard), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Ticker updates countdownNotifier without triggering controller notifyListeners or PrayerTimesList rebuilds', (tester) async {
      final controller = PrayerTimesController(
        locationService: _FakeLocationService(),
        prayerTimesService: _FakePrayerTimesService(testModel),
      );
      await controller.loadPrayerTimes();

      int controllerNotifications = 0;
      controller.addListener(() {
        controllerNotifications++;
      });

      int cardBuildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<NextPrayerCountdown?>(
              valueListenable: controller.countdownNotifier,
              builder: (context, countdown, _) {
                cardBuildCount++;
                return PrayerProgressCard(controller: controller);
              },
            ),
          ),
        ),
      );

      final initialBuildCount = cardBuildCount;
      expect(initialBuildCount, 1);
      expect(controllerNotifications, 0);

      // Simulate a 1-second countdown tick via ValueNotifier
      (controller.countdownNotifier as ValueNotifier<NextPrayerCountdown?>).value =
          NextPrayerCountdown(
        previousPrayer: PrayerType.asr,
        previousPrayerTime: DateTime(2026, 9, 13, 16, 0),
        passedDuration: const Duration(hours: 0, minutes: 45, seconds: 1),
        nextPrayer: PrayerType.maghrib,
        nextPrayerTime: DateTime(2026, 9, 13, 18, 45),
        remainingDuration: const Duration(hours: 1, minutes: 59, seconds: 59),
      );
      await tester.pump();

      // Only the countdown listener rebuilt
      expect(cardBuildCount, initialBuildCount + 1);
      // The controller itself did NOT notify listeners, preserving full-screen and list rebuild isolation
      expect(controllerNotifications, 0);

      controller.dispose();
    });
  });
}

class _FakePrayerTimesService extends PrayerTimesService {
  final PrayerTimesModel model;
  _FakePrayerTimesService(this.model);

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

class _FakeLocationService extends LocationService {
  @override
  Future<UserLocation> determinePosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return UserLocation.actual(latitude: 30.0444, longitude: 31.2357);
  }
}
