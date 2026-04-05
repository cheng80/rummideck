import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/anomalies/anomaly.dart';
import 'package:rummideck/logic/models/combination.dart';
import 'package:rummideck/logic/models/tile.dart';
import 'package:rummideck/logic/score/score_calculator.dart';
import 'package:rummideck/logic/score/score_context.dart';

void main() {
  group('ScoreCalculator', () {
    const calculator = ScoreCalculator();

    test('문서 예시와 같은 straight 점수를 계산한다', () {
      const combo = CombinationResult(
        type: CombinationType.straight,
        tiles: [
          Tile(color: TileColor.blue, number: 4),
          Tile(color: TileColor.red, number: 5),
          Tile(color: TileColor.blue, number: 6),
          Tile(color: TileColor.black, number: 7),
          Tile(color: TileColor.yellow, number: 8),
        ],
      );

      final score = calculator.calculate(
        combo: combo,
        anomalies: const [_StraightMultPlusOne()],
      );

      expect(score.baseChips, 35);
      expect(score.numberBonus, 6);
      expect(score.mult, 2);
      expect(score.xMult, 1);
      expect(score.finalScore, 82);
    });

    test('crown straight는 별도 기본 chips로 계산한다', () {
      const combo = CombinationResult(
        type: CombinationType.crownStraight,
        tiles: [
          Tile(color: TileColor.blue, number: 10),
          Tile(color: TileColor.red, number: 11),
          Tile(color: TileColor.yellow, number: 12),
          Tile(color: TileColor.black, number: 13),
          Tile(color: TileColor.blue, number: 1),
        ],
      );

      final score = calculator.calculate(combo: combo);

      expect(score.baseChips, 45);
      expect(score.numberBonus, 9);
      expect(score.finalScore, 54);
    });

    test('anomaly가 chips, mult, xmult 순서로 반영된다', () {
      const combo = CombinationResult(
        type: CombinationType.triple,
        tiles: [
          Tile(color: TileColor.red, number: 7),
          Tile(color: TileColor.blue, number: 7),
          Tile(color: TileColor.yellow, number: 7),
        ],
      );

      final score = calculator.calculate(
        combo: combo,
        anomalies: const [_AddTenChips(), _TripleMultPlusTwo(), _TripleXTwo()],
      );

      expect(score.baseChips, 30);
      expect(score.numberBonus, 4);
      expect(score.chipsAfterAnomalies, 44);
      expect(score.mult, 3);
      expect(score.xMult, 2);
      expect(score.finalScore, 264);
    });
  });
}

class _StraightMultPlusOne extends Anomaly {
  const _StraightMultPlusOne();

  @override
  String get id => 'straight_mult_plus_one';

  @override
  String get name => 'Straight Mult Plus One';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.straight ? 1 : 0;
  }
}

class _AddTenChips extends Anomaly {
  const _AddTenChips();

  @override
  String get id => 'add_ten_chips';

  @override
  String get name => 'Add Ten Chips';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return chips + 10;
  }
}

class _TripleMultPlusTwo extends Anomaly {
  const _TripleMultPlusTwo();

  @override
  String get id => 'triple_mult_plus_two';

  @override
  String get name => 'Triple Mult Plus Two';

  @override
  AnomalyRarity get rarity => AnomalyRarity.uncommon;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.triple ? 2 : 0;
  }
}

class _TripleXTwo extends Anomaly {
  const _TripleXTwo();

  @override
  String get id => 'triple_x_two';

  @override
  String get name => 'Triple X Two';

  @override
  AnomalyRarity get rarity => AnomalyRarity.rare;

  @override
  double applyXMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.triple ? 2 : 1;
  }
}
