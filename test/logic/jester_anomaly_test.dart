import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/jester/jester_anomaly.dart';
import 'package:rummideck/logic/jester/jester_catalog.dart';
import 'package:rummideck/logic/jester/jester_data.dart';
import 'package:rummideck/logic/models/combination.dart';
import 'package:rummideck/logic/models/tile.dart';
import 'package:rummideck/logic/score/score_calculator.dart';
import 'package:rummideck/logic/score/score_context.dart';

void main() {
  const calculator = ScoreCalculator();

  group('JesterAnomaly — JSON 기반 Jester 점수 적용', () {
    test('passive mult_bonus (Jester +4 Mult) 적용', () {
      final jester = JesterAnomaly(JesterData.fromJson(const {
        'id': 'jester',
        'name': 'Jester',
        'rarity': 'common',
        'baseCost': 2,
        'effectType': 'mult_bonus',
        'conditionType': 'none',
        'value': 4,
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 5),
          Tile(color: TileColor.red, number: 5),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [jester],
      );

      expect(breakdown.mult, 1 + 4);
    });

    test('suit_scored mult_bonus (Greedy Jester — yellow +3) 적용', () {
      final greedy = JesterAnomaly(JesterData.fromJson(const {
        'id': 'greedy_jester',
        'name': 'Greedy Jester',
        'rarity': 'common',
        'baseCost': 5,
        'effectType': 'mult_bonus',
        'conditionType': 'suit_scored',
        'conditionValue': 'diamonds',
        'value': 3,
        'mappedTileColors': ['yellow'],
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.yellow, number: 7),
          Tile(color: TileColor.yellow, number: 7),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [greedy],
      );

      expect(breakdown.mult, 1 + 6);
    });

    test('hand-type contains pair chips_bonus (Sly Jester +50 Chips) 적용', () {
      final sly = JesterAnomaly(JesterData.fromJson(const {
        'id': 'sly_jester',
        'name': 'Sly Jester',
        'rarity': 'common',
        'baseCost': 3,
        'effectType': 'chips_bonus',
        'conditionType': 'pair',
        'conditionValue': 'contains_pair',
        'value': 50,
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 9),
          Tile(color: TileColor.red, number: 9),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [sly],
      );

      expect(breakdown.chipsAfterAnomalies,
          breakdown.baseChips + breakdown.numberBonus + 50);
    });

    test('face card chips_bonus (Scary Face +30 on face cards) 적용', () {
      final scary = JesterAnomaly(JesterData.fromJson(const {
        'id': 'scary_face',
        'name': 'Scary Face',
        'rarity': 'common',
        'baseCost': 4,
        'effectType': 'chips_bonus',
        'conditionType': 'face_card',
        'conditionValue': 'jack_queen_king',
        'value': 30,
        'mappedTileNumbers': [11, 12, 13],
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 12),
          Tile(color: TileColor.blue, number: 12),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [scary],
      );

      expect(breakdown.chipsAfterAnomalies,
          breakdown.baseChips + breakdown.numberBonus + 60);
    });

    test('other condition chips_bonus (Blue Jester — cards in deck × 2) 적용', () {
      final blue = JesterAnomaly(JesterData.fromJson(const {
        'id': 'blue_jester',
        'name': 'Blue Jester',
        'rarity': 'common',
        'baseCost': 5,
        'effectType': 'chips_bonus',
        'conditionType': 'other',
        'conditionValue': 'cards_remaining_in_deck',
        'value': 2,
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 3),
          Tile(color: TileColor.blue, number: 3),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [blue],
        context: const ScoreContext(cardsRemainingInDeck: 40),
      );

      expect(breakdown.chipsAfterAnomalies,
          breakdown.baseChips + breakdown.numberBonus + 80);
    });

    test('xmult_bonus (Photograph — first face card X2) 적용', () {
      final photo = JesterAnomaly(JesterData.fromJson(const {
        'id': 'photograph',
        'name': 'Photograph',
        'rarity': 'common',
        'baseCost': 5,
        'effectType': 'xmult_bonus',
        'conditionType': 'face_card',
        'conditionValue': 'first_scored',
        'xValue': 2,
        'mappedTileNumbers': [11, 12, 13],
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 11),
          Tile(color: TileColor.blue, number: 11),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [photo],
      );

      expect(breakdown.xMult, 2.0);
    });

    test('rank_scored (Fibonacci +8 Mult on A,2,3,5,8) 적용', () {
      final fib = JesterAnomaly(JesterData.fromJson(const {
        'id': 'fibonacci',
        'name': 'Fibonacci',
        'rarity': 'common',
        'baseCost': 8,
        'effectType': 'mult_bonus',
        'conditionType': 'rank_scored',
        'conditionValue': [1, 2, 3, 5, 8],
        'value': 8,
        'mappedTileNumbers': [1, 2, 3, 5, 8],
      }));

      final combo = CombinationResult(
        type: CombinationType.straight,
        tiles: const [
          Tile(color: TileColor.red, number: 1),
          Tile(color: TileColor.blue, number: 2),
          Tile(color: TileColor.yellow, number: 3),
          Tile(color: TileColor.black, number: 4),
          Tile(color: TileColor.red, number: 5),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [fib],
      );

      expect(breakdown.mult, 1 + 32);
    });

    test('Half Jester: +20 Mult if hand size ≤ 3', () {
      final half = JesterAnomaly(JesterData.fromJson(const {
        'id': 'half_jester',
        'name': 'Half Jester',
        'rarity': 'common',
        'baseCost': 5,
        'effectType': 'mult_bonus',
        'conditionType': 'other',
        'conditionValue': 'played_hand_size_lte_3',
        'value': 20,
      }));

      final combo = CombinationResult(
        type: CombinationType.pair,
        tiles: const [
          Tile(color: TileColor.red, number: 5),
          Tile(color: TileColor.blue, number: 5),
        ],
      );

      final breakdown = calculator.calculate(
        combo: combo,
        anomalies: [half],
        context: const ScoreContext(playedHandSize: 2),
      );

      expect(breakdown.mult, 1 + 20);
    });
  });

  group('JesterCatalog — JSON 로딩', () {
    test('fromJsonList로 카탈로그를 만들 수 있다', () {
      final catalog = JesterCatalog.fromJsonList(const [
        {
          'id': 'jester',
          'name': 'Jester',
          'rarity': 'common',
          'baseCost': 2,
          'effectType': 'mult_bonus',
          'conditionType': 'none',
          'value': 4,
        },
        {
          'id': 'greedy_jester',
          'name': 'Greedy Jester',
          'rarity': 'common',
          'baseCost': 5,
          'effectType': 'mult_bonus',
          'conditionType': 'suit_scored',
          'conditionValue': 'diamonds',
          'value': 3,
          'mappedTileColors': ['yellow'],
        },
      ]);

      expect(catalog.all, hasLength(2));
      expect(catalog.findById('jester')?.name, 'Jester');
      expect(catalog.findById('greedy_jester')?.baseCost, 5);
    });

    test('scoringJesters는 chips/mult/xmult 타입만 포함한다', () {
      final catalog = JesterCatalog.fromJsonList(const [
        {
          'id': 'jester',
          'name': 'Jester',
          'rarity': 'common',
          'baseCost': 2,
          'effectType': 'mult_bonus',
          'conditionType': 'none',
          'value': 4,
        },
        {
          'id': 'four_fingers',
          'name': 'Four Fingers',
          'rarity': 'common',
          'baseCost': 7,
          'effectType': 'rule_modifier',
          'conditionType': 'straight',
          'conditionValue': 'allow_4_cards',
        },
        {
          'id': 'egg',
          'name': 'Egg',
          'rarity': 'common',
          'baseCost': 4,
          'effectType': 'economy',
          'conditionType': 'none',
          'value': 3,
        },
      ]);

      expect(catalog.scoringJesters, hasLength(1));
      expect((catalog.scoringJesters.first as JesterAnomaly).id, 'jester');
    });
  });
}
