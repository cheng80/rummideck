import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/random/seeded_rng.dart';

void main() {
  group('SeededRng', () {
    test('같은 정수 seed면 같은 수열을 만든다', () {
      final rngA = SeededRng(12345);
      final rngB = SeededRng(12345);

      final valuesA = List.generate(5, (_) => rngA.nextInt(1000));
      final valuesB = List.generate(5, (_) => rngB.nextInt(1000));

      expect(valuesA, valuesB);
    });

    test('같은 문자열 seed면 같은 셔플 결과를 만든다', () {
      final rngA = SeededRng.fromString('MVP-001');
      final rngB = SeededRng.fromString('MVP-001');
      final listA = [1, 2, 3, 4, 5, 6, 7, 8];
      final listB = [1, 2, 3, 4, 5, 6, 7, 8];

      rngA.shuffle(listA);
      rngB.shuffle(listB);

      expect(listA, listB);
    });
  });
}
