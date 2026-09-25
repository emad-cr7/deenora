import 'package:deenora/features/mosque/hadith_of_the_day/models/hadith_day_model.dart';
import 'package:deenora/features/mosque/hadith_of_the_day/widgets/hadith_card_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HadithDayModel Tests (Clean & Simple Model)', () {
    final sampleJson = {
      'code': 200,
      'status': 'OK',
      'data': {
        'collection': 'nasai',
        'bookNumber': '21',
        'hadithNumber': '1836',
        'chapterId': '10.00',
        'chapterNumber': '10',
        'chapterTitle': {
          'en': 'One who loves to meet Allah',
          'ar': 'باب فِيمَنْ أَحَبَّ لِقَاءَ اللَّهِ',
        },
        'en': {
          'text':
              'It was narrated from \'Ubadah that the Prophet (pbuh) said...',
          'grades': [
            {'graded_by': 'Darussalam', 'grade': 'Sahih'},
          ],
        },
        'ar': {
          'text':
              'أَخْبَرَنَا مُحَمَّدُ بْنُ الْمُثَنَّى ... مَنْ أَحَبَّ لِقَاءَ اللَّهِ أَحَبَّ اللَّهُ لِقَاءَهُ',
        },
      },
    };

    test('Parses API JSON and preserves both Arabic and English text', () {
      final model = HadithDayModel.fromJson(
        sampleJson,
        savedDate: '2026-09-25',
      );

      expect(model.savedDate, '2026-09-25');
      expect(
        model.textArabic,
        'أَخْبَرَنَا مُحَمَّدُ بْنُ الْمُثَنَّى ... مَنْ أَحَبَّ لِقَاءَ اللَّهِ أَحَبَّ اللَّهُ لِقَاءَهُ',
      );
      expect(
        model.textEnglish,
        'It was narrated from \'Ubadah that the Prophet (pbuh) said...',
      );
      expect(model.collection, 'nasai');
      expect(model.bookNumber, '21');
      expect(model.hadithNumber, '1836');
      expect(model.chapterTitleAr, 'باب فِيمَنْ أَحَبَّ لِقَاءَ اللَّهِ');
      expect(model.chapterTitleEn, 'One who loves to meet Allah');
    });

    test('Converts to/from JSON correctly (toJson / fromJson)', () {
      final original = HadithDayModel.fromJson(
        sampleJson,
        savedDate: '2026-09-25',
      );
      final map = original.toJson();

      expect(map['savedDate'], '2026-09-25');
      expect(map['textArabic'], original.textArabic);
      expect(map['textEnglish'], original.textEnglish);
      expect(map['collection'], 'nasai');
      expect(map['hadithNumber'], '1836');

      final restored = HadithDayModel.fromJson(map);
      expect(restored.textArabic, original.textArabic);
      expect(restored.textEnglish, original.textEnglish);
      expect(restored.collection, original.collection);
      expect(restored.hadithNumber, original.hadithNumber);
      expect(restored.savedDate, original.savedDate);
    });
  });

  group('Hadith UI Component Tests', () {
    testWidgets(
      'HadithCardContent renders Arabic text and collection attribution',
      (tester) async {
        final model = HadithDayModel(
          textArabic: 'مَنْ أَحَبَّ لِقَاءَ اللَّهِ أَحَبَّ اللَّهُ لِقَاءَهُ',
          textEnglish: 'Whoever loves to meet Allah, Allah loves to meet him',
          collection: 'nasai',
          bookNumber: '21',
          hadithNumber: '1836',
          chapterTitleAr: 'باب فِيمَنْ أَحَبَّ لِقَاءَ اللَّهِ',
          chapterTitleEn: 'One who loves to meet Allah',
          savedDate: '2026-09-25',
        );

        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HadithCardContent(
                hadith: model,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Hadith of the Day'), findsOneWidget);
        expect(
          find.text(
            '« مَنْ أَحَبَّ لِقَاءَ اللَّهِ أَحَبَّ اللَّهُ لِقَاءَهُ »',
          ),
          findsOneWidget,
        );
        expect(find.text("— Sunan an-Nasa'i • Hadith 1836 —"), findsOneWidget);

        await tester.tap(find.text('Hadith of the Day'));
        expect(tapped, isTrue);
      },
    );
  });
}
