import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/anomalies/mvp_anomalies.dart';
import 'package:rummideck/logic/models/combination.dart';
import 'package:rummideck/logic/models/tile.dart';
import 'package:rummideck/logic/run/run_context.dart';

void main() {
  group('RunContext', () {
    test('스테이지 시작 시 손패 8장과 기본 자원을 준비한다', () {
      final context = RunContext(
        seedText: 'MVP-001',
        drawPile: _sampleDeck(20),
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);

      expect(context.stage?.stageIndex, 1);
      expect(context.stage?.targetScore, 100);
      expect(context.player.hand, hasLength(8));
      expect(context.player.playsLeft, 5);
      expect(context.player.discardsLeft, 3);
      expect(context.phase, RunPhase.stage);
    });

    test('triple 제출 시 점수 반영, 플레이 차감, 손패 보충이 일어난다', () {
      final context = RunContext(
        seedText: 'TRIPLE-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.blue, number: 7),
          const Tile(color: TileColor.yellow, number: 7),
          const Tile(color: TileColor.black, number: 1),
          const Tile(color: TileColor.black, number: 2),
          const Tile(color: TileColor.black, number: 3),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.blue, number: 1),
          const Tile(color: TileColor.yellow, number: 1),
          const Tile(color: TileColor.black, number: 4),
          const Tile(color: TileColor.red, number: 2),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      final result = context.submitSelection([0, 1, 2]);

      expect(result.combination.tileSum, 21);
      expect(result.breakdown.finalScore, 34);
      expect(context.stage?.currentScore, 34);
      expect(context.player.playsLeft, 4);
      expect(context.player.hand, hasLength(8));
      expect(context.discardPile, hasLength(3));
    });

    test('타일 버리기 시 버리기 자원 차감과 손패 보충이 일어난다', () {
      final context = RunContext(
        seedText: 'DISCARD-TEST',
        drawPile: _sampleDeck(20),
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      final discarded = context.discardSelection([0, 1]);

      expect(discarded, hasLength(2));
      expect(context.player.discardsLeft, 2);
      expect(context.player.hand, hasLength(8));
      expect(context.discardPile, hasLength(2));
    });

    test('pair도 제출 가능한 유효 조합으로 처리된다', () {
      final context = RunContext(
        seedText: 'PAIR-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.blue, number: 7),
          const Tile(color: TileColor.black, number: 1),
          const Tile(color: TileColor.black, number: 2),
          const Tile(color: TileColor.black, number: 3),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.blue, number: 1),
          const Tile(color: TileColor.yellow, number: 1),
          const Tile(color: TileColor.black, number: 4),
          const Tile(color: TileColor.red, number: 2),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      final result = context.submitSelection([0, 1]);

      expect(result.combination.type, CombinationType.pair);
      expect(result.breakdown.finalScore, 12);
      expect(context.stage?.currentScore, 12);
      expect(context.player.playsLeft, 4);
      expect(context.player.combinationCountFor(CombinationType.pair), 1);
      expect(context.player.combinationLevelFor(CombinationType.pair), 1);
    });

    test('기본 straight는 점수 누적에 사용된다', () {
      final context = RunContext(
        seedText: 'CLEAR-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.blue, number: 5),
          const Tile(color: TileColor.yellow, number: 6),
          const Tile(color: TileColor.black, number: 7),
          const Tile(color: TileColor.red, number: 8),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.yellow, number: 1),
          const Tile(color: TileColor.yellow, number: 2),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      context.stage!.currentScore = 20;
      final result = context.submitSelection([0, 1, 2, 3, 4]);

      expect(result.combination.type, CombinationType.straight);
      expect(result.breakdown.finalScore, 41);
      expect(context.stage?.currentScore, 61);
      expect(context.phase, RunPhase.stage);
    });

    test('충분한 고점 조합으로 클리어 시 shop 단계로 전환된다', () {
      final context = RunContext(
        seedText: 'CLEAR-HIGH-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.red, number: 8),
          const Tile(color: TileColor.yellow, number: 1),
          const Tile(color: TileColor.yellow, number: 2),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      context.stage!.currentScore = 20;
      final result = context.submitSelection([0, 1, 2, 3, 4]);

      expect(result.combination.type, CombinationType.straightFlush);
      expect(result.breakdown.finalScore, 80);
      expect(context.isStageCleared, isTrue);
      expect(context.phase, RunPhase.shop);
      expect(context.player.gold, 30);
      expect(context.currentShopOffers, isNotEmpty);
    });

    test('플레이를 모두 소모하고 목표 미달이면 game over 상태가 된다', () {
      final context = RunContext(
        seedText: 'FAIL-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.blue, number: 1),
          const Tile(color: TileColor.yellow, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.blue, number: 2),
          const Tile(color: TileColor.yellow, number: 2),
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.blue, number: 3),
          const Tile(color: TileColor.yellow, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.blue, number: 4),
          const Tile(color: TileColor.yellow, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.blue, number: 5),
          const Tile(color: TileColor.yellow, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.blue, number: 6),
          const Tile(color: TileColor.yellow, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.blue, number: 7),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(4);
      context.submitSelection([0, 1, 2]);
      context.submitSelection([0, 1, 2]);
      context.submitSelection([0, 1, 2]);
      context.submitSelection([0, 1, 2]);
      context.submitSelection([0, 1, 2]);

      expect(context.stage?.currentScore, lessThan(context.stage!.targetScore));
      expect(context.phase, RunPhase.gameOver);
      expect(context.isStageFailed, isTrue);
    });

    test('상점에서 anomaly를 구매할 수 있다', () {
      final context = RunContext(
        seedText: 'BUY-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.red, number: 8),
        ],
        anomalyCatalog: const [
          TripleBoostAnomaly(),
          StraightBoostAnomaly(),
          SmallEngineAnomaly(),
        ],
      );

      context.startStage(1);
      context.stage!.currentScore = 20;
      context.player.gold = 20;
      context.submitSelection([0, 1, 2, 3, 4]);

      final firstOffer = context.currentShopOffers.first;
      final goldAfterClear = context.player.gold;
      context.buyAnomaly(offerIndex: 0);

      expect(context.player.anomalies, hasLength(1));
      expect(context.player.anomalies.first.id, firstOffer.anomaly.id);
      expect(context.player.gold, goldAfterClear - firstOffer.price);
    });

    test('상점 슬롯이 가득 차면 교체 구매가 가능하다', () {
      final context = RunContext(
        seedText: 'REPLACE-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.red, number: 8),
        ],
        anomalyCatalog: const [
          TripleBoostAnomaly(),
          StraightBoostAnomaly(),
          SmallEngineAnomaly(),
          RunEngineAnomaly(),
        ],
      );

      context.player.anomalies.addAll(const [
        TripleBoostAnomaly(),
        StraightBoostAnomaly(),
        SmallEngineAnomaly(),
      ]);
      context.startStage(1);
      context.stage!.currentScore = 20;
      context.player.gold = 20;
      context.submitSelection([0, 1, 2, 3, 4]);

      final targetOffer = context.currentShopOffers.firstWhere(
        (offer) => offer.anomaly.id == 'run_engine',
      );
      context.buyAnomaly(
        offerIndex: context.currentShopOffers.indexOf(targetOffer),
        replaceIndex: 1,
      );

      expect(context.player.anomalies.map((anomaly) => anomaly.id), [
        'triple_boost',
        'run_engine',
        'small_engine',
      ]);
    });

    test('상점에서 리롤 시 비용을 소모하고 다음 리롤 비용이 증가한다', () {
      final context = RunContext(
        seedText: 'REROLL-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.red, number: 1),
          const Tile(color: TileColor.red, number: 2),
          const Tile(color: TileColor.red, number: 8),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(1);
      context.stage!.currentScore = 20;
      context.player.gold = 20;
      context.submitSelection([0, 1, 2, 3, 4]);

      final before = context.currentShopOffers
          .map((offer) => offer.anomaly.id)
          .toList();
      final goldAfterClear = context.player.gold;
      context.rerollShop();
      final after = context.currentShopOffers
          .map((offer) => offer.anomaly.id)
          .toList();

      expect(context.player.gold, goldAfterClear - 5);
      expect(context.shop?.currentRerollCost, 6);
      expect(after, isNotEmpty);
      expect(after, isNot(equals(before)));
    });

    test('Stage 5를 클리어한 뒤 다음 진행 시 런 완료 상태로 전환된다', () {
      final context = RunContext(
        seedText: 'RUN-COMPLETE-TEST',
        drawPile: [
          const Tile(color: TileColor.red, number: 3),
          const Tile(color: TileColor.red, number: 4),
          const Tile(color: TileColor.red, number: 5),
          const Tile(color: TileColor.red, number: 6),
          const Tile(color: TileColor.red, number: 7),
          const Tile(color: TileColor.red, number: 8),
          const Tile(color: TileColor.red, number: 9),
          const Tile(color: TileColor.red, number: 10),
        ],
        anomalyCatalog: MvpAnomalyCatalog.all,
      );

      context.startStage(5);
      context.stage!.currentScore = 600;
      context.submitSelection([0, 1, 2, 3, 4]);

      expect(context.phase, RunPhase.shop);

      context.advanceToNextStage();

      expect(context.phase, RunPhase.completed);
      expect(context.isRunCompleted, isTrue);
      expect(context.stage?.stageIndex, 5);
    });
  });
}

List<Tile> _sampleDeck(int count) {
  const colors = [
    TileColor.red,
    TileColor.blue,
    TileColor.yellow,
    TileColor.black,
  ];

  return List.generate(count, (index) {
    return Tile(color: colors[index % colors.length], number: (index % 13) + 1);
  });
}
