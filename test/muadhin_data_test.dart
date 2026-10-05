import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'package:deenora/features/settings/muadhin/repository/muadhin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MuadhinType Enum Tests', () {
    test('returns correct labels', () {
      expect(MuadhinType.adhan.label, 'Adhan');
      expect(MuadhinType.adhan.englishLabel, 'Adhan');
      expect(MuadhinType.adhan.arabicLabel, 'أذان');
      expect(MuadhinType.iqama.label, 'Iqama');
      expect(MuadhinType.iqama.englishLabel, 'Iqama');
      expect(MuadhinType.iqama.arabicLabel, 'إقامة');
    });
  });

  group('MuadhinAudioModel Tests', () {
    test('parses from JSON correctly', () {
      final json = {
        'available': true,
        'audioUrl': 'https://adhan-iqama-api.vercel.app/audio/adhan/test.mp3',
        'description': 'Test adhan',
        'apiUrl': 'https://adhan-iqama-api.vercel.app/api/adhan/test',
      };

      final model = MuadhinAudioModel.fromJson(json);

      expect(model.isAvailable, isTrue);
      expect(model.audioUrl, 'https://adhan-iqama-api.vercel.app/audio/adhan/test.mp3');
      expect(model.effectiveAudioUrl, 'https://adhan-iqama-api.vercel.app/audio/adhan/test.mp3');
      expect(model.description, 'Test adhan');
    });

    test('effectiveAudioUrl falls back to apiUrl when audioUrl is null or empty', () {
      const model = MuadhinAudioModel(
        isAvailable: true,
        audioUrl: '',
        apiUrl: 'https://adhan-iqama-api.vercel.app/api/iqama/test',
      );

      expect(model.effectiveAudioUrl, 'https://adhan-iqama-api.vercel.app/api/iqama/test');
    });
  });

  group('MuadhinModel Tests', () {
    test('parses sheikh JSON with nested name and location maps', () {
      final json = {
        'sheikhId': 'test-sheikh',
        'id': 'test-sheikh',
        'name': {'en': 'Sheikh Test', 'ar': 'الشيخ تجربة'},
        'category': 'Muezzin',
        'categoryAr': 'مؤذن الحرم المكي',
        'isMosque': false,
        'location': {'en': 'Makkah', 'ar': 'المسجد الحرام، مكة المكرمة'},
        'region': 'Makkah',
        'image': 'https://example.com/image.jpg',
        'adhan': {
          'available': true,
          'audioUrl': 'https://example.com/adhan.mp3',
          'apiUrl': 'https://example.com/api/adhan',
        },
        'iqama': {
          'available': false,
          'audioUrl': null,
          'apiUrl': 'https://example.com/api/iqama',
        },
      };

      final muadhin = MuadhinModel.fromJson(json);

      expect(muadhin.id, 'test-sheikh');
      expect(muadhin.nameAr, 'الشيخ تجربة');
      expect(muadhin.locationAr, 'المسجد الحرام، مكة المكرمة');
      expect(muadhin.categoryAr, 'مؤذن الحرم المكي');
      expect(muadhin.hasAdhanAudio, isTrue);
      expect(muadhin.hasIqamaAudio, isFalse);
      expect(muadhin.hasAudioFor(MuadhinType.adhan), isTrue);
      expect(muadhin.hasAudioFor(MuadhinType.iqama), isFalse);
    });
  });

  group('MuadhinRepository Live Data Test', () {
    test('fetches live muadhins, caches them, and filters by availability', () async {
      final repo = MuadhinRepository();
      final all = await repo.getMuadhins();

      expect(all.isNotEmpty, isTrue);
      expect(all.length, 24);

      final hassan = all.firstWhere((m) => m.id == 'hassan-zubaidi');
      expect(hassan.nameAr, contains('زبيدي'));
      expect(hassan.hasAdhanAudio, isTrue);
      expect(hassan.hasIqamaAudio, isTrue);

      final iqamaList = await repo.getAvailableMuadhins(MuadhinType.iqama);
      expect(iqamaList.length, 14);
      for (final m in iqamaList) {
        expect(m.hasIqamaAudio, isTrue);
      }

      final cachedAll = await repo.getMuadhins();
      expect(identical(all, cachedAll), isTrue);
    });
  });
}
