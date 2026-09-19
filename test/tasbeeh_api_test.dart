import 'package:deenora/core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TasbeehService fetches live data and parses DhikrModel correctly',
    () async {
      final service = TasbeehService();
      final dataset = await service.getTasbihData();

      expect(dataset.attribution, contains('Tasbih.info'));
      expect(dataset.dhikrList.isNotEmpty, isTrue);
      expect(dataset.dhikrList.length, 21);

      // Verify item with narrated count (SubhanAllah -> 33)
      final subhanAllah = dataset.dhikrList.firstWhere(
        (d) => d.id == 'subhanallah',
      );
      expect(subhanAllah.name, 'SubhanAllah');
      expect(subhanAllah.arabic, isNotEmpty);
      expect(subhanAllah.narratedCount, 33);

      // Verify item without narrated count (subhanallahil-azim -> null)
      final twoHeavyWords = dataset.dhikrList.firstWhere(
        (d) => d.id == 'subhanallahil-azim',
      );
      expect(twoHeavyWords.narratedCount, isNull);

      // Verify caching works: second call returns same instance without refetching
      final dataset2 = await service.getTasbihData();
      expect(identical(dataset, dataset2), isTrue);
    },
  );
}
