import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:deenora/core/data/remote_data/quran/quran_listening_service.dart';

void main() {
  HttpOverrides.global = null;

  group('MP3Quran Reciters and Audio Flow Verification', () {
    test('All 16 hardcoded reciters have verified MP3Quran IDs', () {
      expect(reciters.length, 16);

      final expectedIds = {
        'Abdul Basit Abdus Samad': 51,
        'Mahmoud Khalil Al Hussary': 118,
        'Muhammad Siddiq Al Minshawi': 112,
        'Abdullah Ali Jaber': 76,
        'Yasser Al Dosari': 92,
        'Faris Abbad': 81,
        'Mishary Rashid Al Afasy': 123,
        'Ahmed bin Ali Al Ajmi': 5,
        'Saud Al Shuraim': 31,
        'Saad Al Ghamdi': 30,
        'Abdul Rahman Al Sudais': 54,
        'Hani Al Rifai': 89,
        'Khalifa Al Tunaiji': 24,
        'Maher Al Muaiqly': 102,
        'Bandar Baleela': 217,
        'Abu Bakr Al Shatri': 4,
      };

      for (final reciter in reciters) {
        expect(expectedIds.containsKey(reciter.name), isTrue,
            reason: 'Reciter ${reciter.name} is missing from expected map');
        expect(reciter.id, expectedIds[reciter.name],
            reason: 'Reciter ID mismatch for ${reciter.name}');
      }
    });

    test('Live MP3Quran API returns correct audio URLs and distinct servers for reciters', () async {
      final service = QuranListeningService();

      // Reciter A: Abdul Basit (51)
      final audioMapA = await service.getReciterAudioFiles(51);
      expect(audioMapA.isNotEmpty, isTrue);
      expect(audioMapA.containsKey(1), isTrue);
      final urlA1 = audioMapA[1]!;
      expect(urlA1, 'https://server7.mp3quran.net/basit/001.mp3');

      // Reciter B: Mahmoud Khalil Al Hussary (118)
      final audioMapB = await service.getReciterAudioFiles(118);
      expect(audioMapB.isNotEmpty, isTrue);
      expect(audioMapB.containsKey(1), isTrue);
      final urlB1 = audioMapB[1]!;
      expect(urlB1, 'https://server13.mp3quran.net/husr/001.mp3');

      // Verify audio source actually changes between Reciter A and Reciter B
      expect(urlA1 != urlB1, isTrue);

      // Verify Next / Previous Surah URL generation
      // Surah 2 (Next Surah after Surah 1)
      expect(audioMapA.containsKey(2), isTrue);
      expect(audioMapA[2], 'https://server7.mp3quran.net/basit/002.mp3');

      // Surah 113 (Previous Surah before Surah 114)
      expect(audioMapA.containsKey(113), isTrue);
      expect(audioMapA[113], 'https://server7.mp3quran.net/basit/113.mp3');

      // Surah 114
      expect(audioMapA.containsKey(114), isTrue);
      expect(audioMapA[114], 'https://server7.mp3quran.net/basit/114.mp3');
    });

    test('All 15 reciters resolve valid audio maps from live MP3Quran API', () async {
      final service = QuranListeningService();

      for (final reciter in reciters) {
        final audioMap = await service.getReciterAudioFiles(reciter.id);
        expect(audioMap.isNotEmpty, isTrue,
            reason: 'Audio map empty for ${reciter.name} (ID: ${reciter.id})');
        expect(audioMap.containsKey(1), isTrue,
            reason: 'Surah 1 missing for ${reciter.name} (ID: ${reciter.id})');
        expect(audioMap[1]!.endsWith('001.mp3'), isTrue,
            reason: 'Malformed URL for ${reciter.name}: ${audioMap[1]}');
      }
    });
  });
}
