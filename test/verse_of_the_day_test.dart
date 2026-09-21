import 'dart:io';

import 'package:deenora/core/data/local_data/hive_config.dart';
import 'package:deenora/core/data/local_data/hive_manager.dart';
import 'package:deenora/core/data/remote_data/verse_day/verse_day_service.dart';
import 'package:deenora/features/mosque/verse_of_the_day/controllers/verse_day_controller.dart';
import 'package:deenora/features/mosque/verse_of_the_day/models/verse_day_model.dart';
import 'package:deenora/features/mosque/verse_of_the_day/widgets/verse_day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FakeVerseDayService extends VerseDayService {
  final VerseDayModel? mockVerse;
  final bool shouldThrow;

  FakeVerseDayService({this.mockVerse, this.shouldThrow = false});

  @override
  Future<VerseDayModel> getVerseOfTheDay({
    required String savedDate,
  }) async {
    if (shouldThrow) {
      throw Exception('Mock network error');
    }
    return mockVerse ??
        VerseDayModel(
          text: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
          surahNumber: 94,
          surahEnglishName: 'Ash-Sharh',
          numberInSurah: 5,
          savedDate: savedDate,
        );
  }
}

class FakeVerseDayController extends VerseDayController {
  final VerseDayModel? mockVerse;
  final Object? mockError;

  FakeVerseDayController({this.mockVerse, this.mockError}) {
    init();
  }

  @override
  void init() {
    isLoading = false;
    if (mockError != null) {
      error = mockError;
      verse = null;
      verseOfTheDayFuture = Future.error(mockError!);
    } else {
      error = null;
      verse = mockVerse ??
          const VerseDayModel(
            text: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
            surahNumber: 94,
            surahEnglishName: 'Ash-Sharh',
            numberInSurah: 5,
            savedDate: '2026-09-21',
          );
      verseOfTheDayFuture = Future.value(verse);
    }
  }

  @override
  void retry() {
    init();
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveManager hiveManager;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('deenora_verse_test_');
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
    final box = await Hive.openBox<dynamic>(HiveConfig.verseOfTheDayBox);
    await box.clear();
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

  group('VerseOfTheDay Deterministic Selection & Model Tests', () {
    test('Same date always produces identical date key for caching', () {
      final date1 = DateTime(2026, 9, 16, 8, 30);
      final date2 = DateTime(2026, 9, 16, 23, 59);

      final key1 = date1.toString().split(' ').first;
      final key2 = date2.toString().split(' ').first;

      expect(key1, equals(key2));
      expect(key1, equals('2026-09-16'));
    });

    test(
      'Different dates produce different date keys across calendar days',
      () {
        final dateA = DateTime(2026, 9, 16);
        final dateB = DateTime(2026, 9, 17);
        final dateC = DateTime(2026, 9, 18);

        final keyA = dateA.toString().split(' ').first;
        final keyB = dateB.toString().split(' ').first;
        final keyC = dateC.toString().split(' ').first;

        expect(keyA, isNot(equals(keyB)));
        expect(keyB, isNot(equals(keyC)));
        expect(keyA, isNot(equals(keyC)));
      },
    );

    test('All 365 days of a year yield valid date key format YYYY-MM-DD', () {
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      for (int i = 1; i <= 365; i++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: i));
        final key = date.toString().split(' ').first;
        expect(regex.hasMatch(key), isTrue);
      }
    });

    test('VerseDayModel parses JSON and converts to/from stored map', () {
      final json = {
        'code': 200,
        'status': 'OK',
        'data': {
          'text': 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
          'surah': {
            'number': 94,
            'englishName': 'Ash-Sharh',
          },
          'numberInSurah': 5,
        },
      };

      final model = VerseDayModel.fromJson(json, savedDate: '2026-09-16');
      expect(model.text, equals('فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا'));
      expect(model.surahNumber, equals(94));
      expect(model.surahEnglishName, equals('Ash-Sharh'));
      expect(model.numberInSurah, equals(5));
      expect(model.savedDate, equals('2026-09-16'));

      final storedMap = model.toStoredMap();
      final restored = VerseDayModel.fromStoredMap(storedMap);
      expect(restored.text, equals(model.text));
      expect(restored.surahNumber, equals(model.surahNumber));
      expect(restored.surahEnglishName, equals(model.surahEnglishName));
      expect(restored.numberInSurah, equals(model.numberInSurah));
      expect(restored.savedDate, equals(model.savedDate));
    });
  });

  group('VerseOfTheDayController Tests', () {
    test(
      'loadVerseOfTheDay updates state to success with fetched verse',
      () async {
        final today = DateTime.now().toString().split(' ').first;
        final sampleVerse = VerseDayModel(
          text: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
          surahNumber: 94,
          surahEnglishName: 'Ash-Sharh',
          numberInSurah: 5,
          savedDate: today,
        );
        await hiveManager.saveVerseOfTheDay(sampleVerse.toStoredMap());

        final controller = VerseDayController();

        expect(controller.isLoading, isFalse);
        expect(controller.verse, isNull);

        controller.init();
        final verse = await controller.verseOfTheDayFuture;

        expect(controller.isLoading, isFalse);
        expect(controller.error, isNull);
        expect(controller.verse, isNotNull);
        expect(controller.verse!.text, 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا');
        expect(verse.text, 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا');
        controller.dispose();
      },
    );

    test(
      'loadVerseOfTheDay handles error properly when service throws',
      () async {
        await HttpOverrides.runZoned(
          () async {
            final controller = VerseDayController();
            controller.init();

            try {
              await controller.verseOfTheDayFuture;
            } catch (_) {}

            expect(controller.isLoading, isFalse);
            expect(controller.error, isNotNull);
            expect(controller.verse, isNull);
            controller.dispose();
          },
          createHttpClient: (context) =>
              throw const SocketException('Mock network error'),
        );
      },
    );
  });

  group('VerseOfTheDayCard UI & Navigation Tests', () {
    testWidgets(
      'Renders simplified verse card layout with clean labels and brackets',
      (tester) async {
        final controller = FakeVerseDayController();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<VerseDayController>.value(
              value: controller,
              child: const Scaffold(body: VerseDayCard()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Header title and Arabic verse text with brackets
        expect(find.text('Ayah of the Day'), findsOneWidget);
        expect(find.text('﴿ فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا ﴾'), findsOneWidget);
        expect(find.textContaining('Ayah 5'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping the card invokes onCardTap with correct verse details',
      (tester) async {
        final controller = FakeVerseDayController();

        VerseDayModel? tappedVerse;

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<VerseDayController>.value(
              value: controller,
              child: Scaffold(
                body: VerseDayCard(
                  onCardTap: (verse) {
                    tappedVerse = verse;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the card
        await tester.tap(find.byType(VerseDayCard));
        await tester.pumpAndSettle();

        // Verify callback received the exact verse details
        expect(tappedVerse, isNotNull);
        expect(tappedVerse!.surahNumber, equals(94));
        expect(tappedVerse!.numberInSurah, equals(5));
        expect(tappedVerse!.text, equals('فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا'));
      },
    );
  });
}
