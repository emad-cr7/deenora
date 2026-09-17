import 'package:deenora/features/mosque/verse_of_the_day/controllers/verse_of_the_day_controller.dart';
import 'package:deenora/features/mosque/verse_of_the_day/models/verse_of_the_day_model.dart';
import 'package:deenora/features/mosque/verse_of_the_day/services/verse_of_the_day_service.dart';
import 'package:deenora/features/mosque/verse_of_the_day/widgets/verse_of_the_day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeVerseOfTheDayService extends VerseOfTheDayService {
  final VerseOfTheDayModel? mockVerse;
  final bool shouldThrow;

  FakeVerseOfTheDayService({this.mockVerse, this.shouldThrow = false});

  @override
  Future<VerseOfTheDayModel> getVerseOfTheDay({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) {
      throw Exception('Mock network error');
    }
    return mockVerse ??
        VerseOfTheDayModel(
          number: 6095,
          text: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
          surahNumber: 94,
          surahName: 'سُورَةُ الشَّرۡحِ',
          surahEnglishName: 'Ash-Sharh',
          numberInSurah: 5,
        );
  }
}

void main() {
  group('VerseOfTheDay Deterministic Selection & Model Tests', () {
    test('Same date always produces identical ayah index', () {
      final service = VerseOfTheDayService();
      final date1 = DateTime(2026, 9, 16, 8, 30);
      final date2 = DateTime(2026, 9, 16, 23, 59);

      final index1 = service.getDailyAyahIndex(date1);
      final index2 = service.getDailyAyahIndex(date2);

      expect(index1, equals(index2));
      expect(index1, greaterThanOrEqualTo(1));
      expect(index1, lessThanOrEqualTo(6236));
    });

    test('Different dates produce different ayah indices across 6236 verses', () {
      final service = VerseOfTheDayService();
      final dateA = DateTime(2026, 9, 16);
      final dateB = DateTime(2026, 9, 17);
      final dateC = DateTime(2026, 9, 18);

      final indexA = service.getDailyAyahIndex(dateA);
      final indexB = service.getDailyAyahIndex(dateB);
      final indexC = service.getDailyAyahIndex(dateC);

      expect(indexA, isNot(equals(indexB)));
      expect(indexB, isNot(equals(indexC)));
      expect(indexA, greaterThanOrEqualTo(1));
      expect(indexA, lessThanOrEqualTo(6236));
      expect(indexB, greaterThanOrEqualTo(1));
      expect(indexB, lessThanOrEqualTo(6236));
      expect(indexC, greaterThanOrEqualTo(1));
      expect(indexC, lessThanOrEqualTo(6236));
    });

    test('All 365 days of a year yield valid indices in range 1..6236', () {
      final service = VerseOfTheDayService();
      for (int i = 1; i <= 365; i++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: i));
        final index = service.getDailyAyahIndex(date);
        expect(index >= 1 && index <= 6236, isTrue);
      }
    });

    test('VerseOfTheDayModel parses JSON and cleans displaySurahName', () {
      final json = {
        'code': 200,
        'status': 'OK',
        'data': {
          'number': 6095,
          'text': 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
          'surah': {
            'number': 94,
            'name': 'سُورَةُ الشَّرۡحِ',
            'englishName': 'Ash-Sharh',
          },
          'numberInSurah': 5,
        },
      };

      final model = VerseOfTheDayModel.fromJson(json);
      expect(model.number, equals(6095));
      expect(model.text, equals('فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا'));
      expect(model.surahNumber, equals(94));
      expect(model.numberInSurah, equals(5));
      expect(model.displaySurahName, contains('الشَّرۡحِ'));
    });
  });

  group('VerseOfTheDayController Tests', () {
    test('loadVerseOfTheDay updates state to success with fetched verse', () async {
      final fakeService = FakeVerseOfTheDayService();
      final controller = VerseOfTheDayController(service: fakeService);

      expect(controller.isLoading, isFalse);
      expect(controller.verse, isNull);

      await controller.loadVerseOfTheDay();

      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isFalse);
      expect(controller.verse, isNotNull);
      expect(controller.verse!.text, 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا');
    });

    test('loadVerseOfTheDay handles error properly when service throws', () async {
      final fakeService = FakeVerseOfTheDayService(shouldThrow: true);
      final controller = VerseOfTheDayController(service: fakeService);

      await controller.loadVerseOfTheDay();

      expect(controller.isLoading, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, contains('Mock network error'));
      expect(controller.verse, isNull);
    });
  });

  group('VerseOfTheDayCard UI & Navigation Tests', () {
    testWidgets('Renders simplified verse card layout with clean labels and brackets', (tester) async {
      final fakeService = FakeVerseOfTheDayService();
      final controller = VerseOfTheDayController(service: fakeService);
      await controller.loadVerseOfTheDay();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerseOfTheDayCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header title and Arabic verse text with brackets
      expect(find.text('Ayah of the Day'), findsOneWidget);
      expect(find.text('﴿ فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا ﴾'), findsOneWidget);
      expect(find.textContaining('Ayah 5'), findsOneWidget);
    });

    testWidgets('Tapping the card invokes onCardTap with correct verse details', (tester) async {
      final fakeService = FakeVerseOfTheDayService();
      final controller = VerseOfTheDayController(service: fakeService);
      await controller.loadVerseOfTheDay();

      VerseOfTheDayModel? tappedVerse;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerseOfTheDayCard(
              onCardTap: (verse) {
                tappedVerse = verse;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(VerseOfTheDayCard));
      await tester.pumpAndSettle();

      // Verify callback received the exact verse details
      expect(tappedVerse, isNotNull);
      expect(tappedVerse!.surahNumber, equals(94));
      expect(tappedVerse!.numberInSurah, equals(5));
      expect(tappedVerse!.text, equals('فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا'));
    });
  });
}
