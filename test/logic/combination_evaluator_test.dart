import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/combination/combination_evaluator.dart';
import 'package:rummideck/logic/models/combination.dart';
import 'package:rummideck/logic/models/tile.dart';

void main() {
  group('CombinationEvaluator', () {
    const evaluator = CombinationEvaluator();

    test('triple을 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 7),
        Tile(color: TileColor.blue, number: 7),
        Tile(color: TileColor.yellow, number: 7),
      ]);

      expect(result?.type, CombinationType.triple);
    });

    test('pair를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 7),
        Tile(color: TileColor.blue, number: 7),
      ]);

      expect(result?.type, CombinationType.pair);
    });

    test('two pair를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 7),
        Tile(color: TileColor.blue, number: 7),
        Tile(color: TileColor.yellow, number: 3),
        Tile(color: TileColor.black, number: 3),
      ]);

      expect(result?.type, CombinationType.twoPair);
    });

    test('straight를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.blue, number: 4),
        Tile(color: TileColor.red, number: 5),
        Tile(color: TileColor.yellow, number: 6),
        Tile(color: TileColor.black, number: 7),
        Tile(color: TileColor.blue, number: 8),
      ]);

      expect(result?.type, CombinationType.straight);
    });

    test('10-11-12-13-1은 crown straight를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.blue, number: 10),
        Tile(color: TileColor.red, number: 11),
        Tile(color: TileColor.yellow, number: 12),
        Tile(color: TileColor.black, number: 13),
        Tile(color: TileColor.blue, number: 1),
      ]);

      expect(result?.type, CombinationType.crownStraight);
    });

    test('flush를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 2),
        Tile(color: TileColor.red, number: 5),
        Tile(color: TileColor.red, number: 7),
        Tile(color: TileColor.red, number: 9),
        Tile(color: TileColor.red, number: 12),
      ]);

      expect(result?.type, CombinationType.flush);
    });

    test('full house를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 7),
        Tile(color: TileColor.blue, number: 7),
        Tile(color: TileColor.yellow, number: 7),
        Tile(color: TileColor.red, number: 3),
        Tile(color: TileColor.black, number: 3),
      ]);

      expect(result?.type, CombinationType.fullHouse);
    });

    test('quad를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 9),
        Tile(color: TileColor.blue, number: 9),
        Tile(color: TileColor.yellow, number: 9),
        Tile(color: TileColor.black, number: 9),
      ]);

      expect(result?.type, CombinationType.quad);
    });

    test('straight flush를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 3),
        Tile(color: TileColor.red, number: 4),
        Tile(color: TileColor.red, number: 5),
        Tile(color: TileColor.red, number: 6),
        Tile(color: TileColor.red, number: 7),
      ]);

      expect(result?.type, CombinationType.straightFlush);
    });

    test('같은 색 10-11-12-13-1은 crown straight flush를 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 10),
        Tile(color: TileColor.red, number: 11),
        Tile(color: TileColor.red, number: 12),
        Tile(color: TileColor.red, number: 13),
        Tile(color: TileColor.red, number: 1),
      ]);

      expect(result?.type, CombinationType.crownStraightFlush);
    });

    test('4연속 단색은 color straight로 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 3),
        Tile(color: TileColor.red, number: 4),
        Tile(color: TileColor.red, number: 5),
        Tile(color: TileColor.red, number: 6),
      ]);

      expect(result?.type, CombinationType.colorStraight);
    });

    test('6개 이상 단색 연속은 long straight로 판정한다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.blue, number: 7),
        Tile(color: TileColor.blue, number: 8),
        Tile(color: TileColor.blue, number: 9),
        Tile(color: TileColor.blue, number: 10),
        Tile(color: TileColor.blue, number: 11),
        Tile(color: TileColor.blue, number: 12),
      ]);

      expect(result?.type, CombinationType.longStraight);
    });

    test('연속되지 않은 숫자는 straight가 아니다', () {
      final result = evaluator.evaluate(const [
        Tile(color: TileColor.red, number: 4),
        Tile(color: TileColor.blue, number: 5),
        Tile(color: TileColor.yellow, number: 7),
        Tile(color: TileColor.black, number: 8),
        Tile(color: TileColor.red, number: 9),
      ]);

      expect(result, isNull);
    });
  });
}
