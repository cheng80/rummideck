import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/progression/stage_target_calculator.dart';

void main() {
  group('StageTargetCalculator', () {
    const calculator = StageTargetCalculator();

    test('문서 예시 스테이지 목표값과 일치한다', () {
      expect(calculator.forStage(1), 100);
      expect(calculator.forStage(2), 160);
      expect(calculator.forStage(3), 256);
      expect(calculator.forStage(4), 409);
      expect(calculator.forStage(5), 655);
    });
  });
}
