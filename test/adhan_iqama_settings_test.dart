import 'dart:async';
import 'dart:io';

import 'package:deenora/core/data/local_data/hive_config.dart';
import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/features/settings/iqama/iqama_settings_controller.dart';
import 'package:deenora/features/settings/iqama/iqama_settings_screen.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/widgets/option_muadhin/selected_muadhin.dart';
import 'package:deenora/features/widget_prayer_times/models/prayer_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'muadhin_controller_test.dart'
    show FakeMuadhinRepository, FakeMuadhinPlayerController;

const _audio = MuadhinAudioModel(
  isAvailable: true,
  apiUrl: 'https://example.com/audio',
);
const _muadhins = [
  MuadhinModel(
    id: 'first',
    nameAr: 'First',
    categoryAr: '',
    locationAr: '',
    isMosque: false,
    imageUrl: '',
    adhan: _audio,
    iqama: _audio,
  ),
  MuadhinModel(
    id: 'second',
    nameAr: 'Second',
    categoryAr: '',
    locationAr: '',
    isMosque: false,
    imageUrl: '',
    adhan: _audio,
    iqama: _audio,
  ),
];

class _ControlledIqamaHive implements HiveManager {
  Completer<void> write = Completer<void>();
  int writes = 0;

  @override
  Object? loadIqamaSettings() => null;

  @override
  Future<void> saveIqamaSettings(Map<String, dynamic> settings) {
    writes++;
    return write.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  final manager = HiveManager();

  MuadhinController muadhinController({List<MuadhinModel> items = _muadhins}) {
    final player = FakeMuadhinPlayerController();
    final controller = MuadhinController(
      repository: FakeMuadhinRepository(sampleMuadhins: items),
      playerController: player,
    );
    addTearDown(controller.dispose);
    addTearDown(player.dispose);
    return controller;
  }

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('deenora_settings_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => directory.path,
        );
    await manager.init();
  });

  setUp(() async => manager.clear());

  tearDownAll(() async {
    await Hive.close();
    Hive.resetAdapters();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await directory.delete(recursive: true);
  });

  test(
    'Muadhin selection survives closing Hive and can be changed; preview is separate',
    () async {
      final controller = muadhinController();
      await controller.loadMuadhins();
      await controller.selectMuadhin('first');
      await controller.toggleExpand(_muadhins.last);
      expect(controller.selectedMuadhinId, 'first');
      expect(controller.playerController.currentMuadhinId, isNull);
      expect(
        (controller.playerController as FakeMuadhinPlayerController).playedId,
        'second',
      );
      await Hive.close();
      Hive.resetAdapters();
      await manager.init();
      final restored = muadhinController();
      expect(restored.selectedMuadhinId, 'first'); // No API load needed.
      await restored.loadMuadhins();
      await restored.selectMuadhin('second');
      await Hive.close();
      Hive.resetAdapters();
      await manager.init();
      expect(muadhinController().selectedMuadhinId, 'second');
    },
  );

  test('missing Muadhin and failed catalog keep the saved ID safely', () async {
    await manager.saveSelectedMuadhinId('removed');
    final controller = muadhinController();
    await controller.loadMuadhins();
    expect(controller.isSelectedMuadhinUnavailable, isTrue);
    await controller.selectMuadhin('unknown');
    expect(controller.selectedMuadhinId, 'removed');
    final failed = MuadhinController(
      repository: FakeMuadhinRepository(sampleMuadhins: [], shouldFail: true),
      playerController: controller.playerController,
    );
    addTearDown(failed.dispose);
    await failed.loadMuadhins();
    expect(failed.hasError, isTrue);
    expect(failed.selectedMuadhinId, 'removed');
  });

  test(
    'all five independent delays and disabled preference survive Hive reopen',
    () async {
      final controller = IqamaSettingsController();
      addTearDown(controller.dispose);
      final delays = {
        for (final prayer in IqamaSettings.defaultDelays.keys)
          prayer: prayer.index + 1,
      };
      for (final entry in delays.entries) {
        controller.setDelay(entry.key, entry.value.toString());
      }
      controller.setEnabled(true);
      expect(await controller.save(), isTrue);
      controller.setEnabled(false);
      expect(await controller.save(), isTrue);
      await Hive.close();
      Hive.resetAdapters();
      await manager.init();
      final restored = IqamaSettingsController();
      addTearDown(restored.dispose);
      expect(restored.savedSettings.enabled, isFalse);
      expect(restored.savedSettings.delays, delays);
      final box = Hive.box<dynamic>(HiveConfig.settingsBox);
      final events = <BoxEvent>[];
      final subscription = box.watch().listen(events.add);
      expect(await restored.save(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      await subscription.cancel();
    },
  );

  test(
    'invalid stored values fall back per prayer and preserve unrelated keys',
    () async {
      final box = Hive.box<dynamic>(HiveConfig.settingsBox);
      await box.put('unrelated', 'keep');
      await box.put(HiveConfig.selectedMuadhinKey, 42);
      expect(manager.loadSelectedMuadhinId(), isNull);
      await box.put(HiveConfig.selectedMuadhinKey, '  ');
      expect(manager.loadSelectedMuadhinId(), isNull);
      for (final raw in [
        null,
        'invalid',
        <String, Object?>{'enabled': 'yes', 'delays': 42},
      ]) {
        expect(
          IqamaSettings.fromStorage(raw).delays,
          IqamaSettings.defaultDelays,
        );
        expect(IqamaSettings.fromStorage(raw).enabled, isFalse);
      }
      await box.put(HiveConfig.iqamaSettingsKey, {
        'enabled': true,
        'delays': {
          'fajr': -1,
          'dhuhr': '15',
          'asr': 1.5,
          'maghrib': 181,
          'isha': 0,
        },
      });
      final settings = IqamaSettings.fromStorage(manager.loadIqamaSettings());
      expect(settings.enabled, isTrue);
      expect(settings.delays, {
        ...IqamaSettings.defaultDelays,
        PrayerType.isha: 0,
      });
      expect(
        () => IqamaSettings(delays: {PrayerType.fajr: -1}),
        throwsArgumentError,
      );
      expect(
        () => IqamaSettings(delays: {PrayerType.sunrise: 10}),
        throwsArgumentError,
      );
      await manager.saveSelectedMuadhinId('first');
      await manager.saveIqamaSettings(settings.toStorage());
      expect(box.get('unrelated'), 'keep');
    },
  );

  test('controller rejects invalid edits and skips unchanged saves', () async {
    final hive = _ControlledIqamaHive();
    final controller = IqamaSettingsController(hiveManager: hive);
    addTearDown(controller.dispose);
    for (final value in ['', '-1', '181', '1.5', 'abc']) {
      controller.setDelay(PrayerType.fajr, value);
      expect(controller.validateDelay(value), isNotNull);
      expect(await controller.save(), isFalse);
    }
    controller.setDelay(PrayerType.fajr, '20');
    expect(await controller.save(), isTrue);
    expect(controller.errorMessage, isNull);
    expect(hive.writes, 0);
    expect(controller.validateDelay('0'), isNull);
    expect(controller.validateDelay('180'), isNull);
  });

  test(
    'controller blocks repeated saves and allows retry after failure',
    () async {
      final hive = _ControlledIqamaHive();
      final controller = IqamaSettingsController(hiveManager: hive);
      addTearDown(controller.dispose);
      controller.setEnabled(true);
      final firstSave = controller.save();
      expect(controller.isSaving, isTrue);
      expect(await controller.save(), isFalse);
      expect(hive.writes, 1);
      hive.write.completeError(StateError('Disk write failed'));
      expect(await firstSave, isFalse);
      expect(controller.isSaving, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.savedSettings.enabled, isFalse);
      hive.write = Completer<void>();
      final retry = controller.save();
      expect(controller.errorMessage, isNull);
      hive.write.complete();
      expect(await retry, isTrue);
      expect(controller.savedSettings.enabled, isTrue);
      expect(controller.isSaving, isFalse);
      expect(hive.writes, 2);
    },
  );

  testWidgets(
    'explicit select button updates checkmark without starting preview',
    (tester) async {
      final controller = muadhinController();
      await controller.loadMuadhins();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => SelectedMuadhin(controller: controller),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final saved = Completer<void>();
        controller.addListener(() => saved.complete());
        await tester.tap(find.byTooltip('Select Muadhin').first);
        await saved.future;
      });
      await tester.pumpAndSettle();
      expect(find.byTooltip('Selected Muadhin'), findsOneWidget);
      expect(controller.selectedMuadhinId, 'first');
      expect(
        (controller.playerController as FakeMuadhinPlayerController).playedId,
        isNull,
      );
    },
  );

  testWidgets('Iqama form validates each input and saves values on reopen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const IqamaSettingsScreen()),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final fajr = find.byKey(const ValueKey(PrayerType.fajr));
    await tester.enterText(fajr, '-1');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole number from 0 to 180'), findsOneWidget);
    for (final prayer in IqamaSettings.defaultDelays.keys) {
      final field = find.byKey(ValueKey(prayer));
      await tester.ensureVisible(field);
      await tester.enterText(field, '${prayer.index + 2}');
    }
    await tester.ensureVisible(find.text('Save'));
    await tester.runAsync(() async {
      final saved = Hive.box<dynamic>(
        HiveConfig.settingsBox,
      ).watch(key: HiveConfig.iqamaSettingsKey).first;
      await tester.tap(find.text('Save'));
      await saved;
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.byType(IqamaSettingsScreen), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final prayer in IqamaSettings.defaultDelays.keys) {
      final field = tester.widget<TextFormField>(find.byKey(ValueKey(prayer)));
      expect(field.initialValue, '${prayer.index + 2}');
    }
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });
}
