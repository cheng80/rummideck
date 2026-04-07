// 시드별 플레이북: BFS 최소 행동(Play/Discard) + 상점은 점수 제스터 우선·실패 시 다른 가격대 등 재시도. 리롤 없음.
// 실행: `flutter test test/seed_playbook_test.dart --plain-name playbook`
// 전체 시드(느림): `PLAYBOOK_ALL_SEEDS=1 flutter test ...`

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rummideck/debug/playbook_clearable_runner.dart';
import 'package:rummideck/logic/anomalies/anomaly.dart';
import 'package:rummideck/logic/combination/combination_evaluator.dart';
import 'package:rummideck/logic/jester/jester_catalog.dart';
import 'package:rummideck/logic/jester/jester_translations.dart';
import 'package:rummideck/logic/models/combination.dart';
import 'package:rummideck/logic/run/run_context.dart';
import 'package:rummideck/logic/score/score_calculator.dart';
import 'package:rummideck/logic/score/score_context.dart';
import 'package:rummideck/views/game/jester_ui_strings.dart';

const _allSeeds = [
  'MVP-001',
  'MVP-002',
  'MVP-003',
  'MVP-004',
  'MVP-005',
  'BOSS-TEST',
  'DEBUG-42',
];

/// `PLAYBOOK_ALL_SEEDS=1`이면 전체 시드. 기본은 BFS 부하로 첫 시드만(시뮬이 끝나도록).
List<String> _seedsForTest() {
  if (Platform.environment['PLAYBOOK_ALL_SEEDS'] == '1') {
    return List<String>.from(_allSeeds);
  }
  return [_allSeeds.first];
}

final _evaluator = const CombinationEvaluator(allowPair: true);
final _scorer = const ScoreCalculator();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'playbook — 시드별 시뮬 출력',
    () async {
      final jsonString =
          await rootBundle.loadString('data/common/jesters_common.json');
      final catalog = JesterCatalog.fromJsonString(jsonString);
      final shopCatalog = catalog.shopCatalog;

      final koJesters =
          await rootBundle.loadString('assets/translations/data/ko/jesters.json');
      final jesterKo = JesterTranslations.fromJsonString(koJesters);

      final buf = StringBuffer();
      final seeds = _seedsForTest();
      buf.writeln('(시드 ${seeds.length}개 — 전체는 PLAYBOOK_ALL_SEEDS=1)');
      for (final seed in seeds) {
        buf.writeln('');
        buf.writeln('=' * 72);
        buf.writeln('시드: $seed');
        buf.writeln('=' * 72);
        _simulateSeed(seed, shopCatalog, jesterKo, buf);
      }
      // ignore: avoid_print
      print(buf.toString());
      if (Platform.environment['PLAYBOOK_WRITE'] == '1') {
        File('docs/seed_playbook_output.txt').writeAsStringSync(buf.toString());
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

void _simulateSeed(
  String seedText,
  List<Anomaly> shopCatalog,
  JesterTranslations jesterKo,
  StringBuffer out,
) {
  void w(String m) => out.writeln(m);

  try {
    final actions = PlaybookClearableRunner.buildEntireRunActions(
      seedText: seedText,
      shopCatalog: shopCatalog,
    );
    w('  (BFS 최소 전투 + Discard(1→필요 시 2) + 상점: 점수 제스터 휴리스틱 → 최저가 → 고가 → 슬롯별 → 미구매 순 재시도)');
    var partial = <PlaybookGameAction>[];
    var battleTurn = 0;
    for (final a in actions) {
      final before = PlaybookClearableRunner.replay(
        seedText: seedText,
        shopCatalog: shopCatalog,
        actions: partial,
      );
      partial.add(a);

      switch (a) {
        case PgaPlay(:final indices):
          battleTurn++;
          final s = before.stage!;
          final hand = before.player.hand;
          final tiles = indices.map((i) => hand[i]).toList();
          final codes = tiles.map((t) => t.code).join(', ');
          final combo = _evaluator.evaluate(tiles)!;
          final held = hand.where((t) => !tiles.contains(t)).toList();
          final bd = _scorer.calculate(
            combo: combo,
            anomalies: before.player.anomalies,
            context: ScoreContext(
              combinationsSubmittedThisAction: 1,
              setsPlayedBefore: before.player.setsPlayed,
              runsPlayedBefore: before.player.runsPlayed,
              discardsUsedThisStage: 3 - before.player.discardsLeft,
              discardsRemaining: before.player.discardsLeft,
              cardsRemainingInDeck: before.drawPile.length,
              ownedJesterCount: before.player.anomalies.length,
              maxJesterSlots: RunContext.maxJesterSlots,
              playedHandSize: tiles.length,
              heldHand: held,
              scoredTiles: tiles,
            ),
          );
          w(
            '  턴 $battleTurn · Stage ${s.stageIndex} (${_blindLabel(s.stageIndex)}) · '
            '점수 ${s.currentScore}/${s.targetScore} · Plays ${before.player.playsLeft}',
          );
          w(
            '    → Play 인덱스(랭크정렬 손패): $indices  |  타일: [$codes]',
          );
          w(
            '    → 족보: ${_comboEn(combo.type)}  |  이번 판 점수: ${bd.finalScore}',
          );
          final after = PlaybookClearableRunner.replay(
            seedText: seedText,
            shopCatalog: shopCatalog,
            actions: partial,
          );
          w(
            '    → 제출 후 누적: ${after.stage!.currentScore}/${after.stage!.targetScore}',
          );
          if (after.stage!.isCleared) {
            w('    → 스테이지 클리어 → 상점');
            battleTurn = 0;
          }
        case PgaDiscard(:final indices):
          final s = before.stage!;
          final hand = before.player.hand;
          final tiles = indices.map((i) => hand[i]).toList();
          final codes = tiles.map((t) => t.code).join(', ');
          w(
            '  Discard · Stage ${s.stageIndex} · Plays ${before.player.playsLeft} · '
            'Discards ${before.player.discardsLeft}',
          );
          w('    → 버릴 인덱스: $indices  |  타일: [$codes]');
        case PgaAfterStageBattle():
          final nextBuy = partial.length < actions.length
              ? actions[partial.length]
              : null;
          final chosenOffer = switch (nextBuy) {
            PgaShopBuyOffer(:final offerIndex) => offerIndex,
            _ => null,
          };
          _printShop(
            seedText,
            shopCatalog,
            partial,
            jesterKo,
            w,
            chosenOfferIndex: chosenOffer,
          );
        case PgaShopBuyOffer():
        case PgaAdvanceStage():
          break;
      }
    }

    final end = PlaybookClearableRunner.replay(
      seedText: seedText,
      shopCatalog: shopCatalog,
      actions: actions,
    );
    if (end.phase == RunPhase.gameOver) {
      w('  [게임 오버] (BFS 전투는 통과했으나 이후 런에서 게임 오버)');
    } else if (end.phase == RunPhase.completed) {
      w('  [런 완료]');
    }
  } on PlaybookSimulationException catch (e) {
    w('  [실패] $e');
  }
}

void _printShop(
  String seedText,
  List<Anomaly> shopCatalog,
  List<PlaybookGameAction> partialAfterOpen,
  JesterTranslations jesterKo,
  void Function(String) w, {
  int? chosenOfferIndex,
}) {
  final run = PlaybookClearableRunner.replay(
    seedText: seedText,
    shopCatalog: shopCatalog,
    actions: partialAfterOpen,
  );
  if (run.phase != RunPhase.shop) {
    return;
  }
  final shop = run.shop!;
  final st = run.stage!;
  final gold = run.player.gold;

  w('');
  w(
    '  --- 상점 (Stage ${st.stageIndex} 클리어 직후 · 보유 골드 ${gold}G) ---',
  );
  for (var i = 0; i < shop.offers.length; i++) {
    final o = shop.offers[i];
    final nameKo = localizedJesterName(jesterKo, o.anomaly);
    w('    오퍼[$i]  $nameKo  (id=${o.anomaly.id})  가격=${o.price}G');
  }
  w('    리롤 비용(참고): ${shop.currentRerollCost}G — 플레이북에서 리롤 안 함');

  if (chosenOfferIndex == null) {
    w('    ⇒ 구매: 없음(슬롯 만 또는 정책상 미구매)');
  } else if (chosenOfferIndex < 0 || chosenOfferIndex >= shop.offers.length) {
    w('    ⇒ 구매: 인덱스 오류');
  } else {
    final o = shop.offers[chosenOfferIndex];
    final nameKo = localizedJesterName(jesterKo, o.anomaly);
    w(
      '    ⇒ 구매: 오퍼[$chosenOfferIndex] $nameKo (id=${o.anomaly.id}) (${o.price}G)',
    );
  }
  w('    → 다음 스테이지 진행');
}

String _blindLabel(int stageIndex) {
  return switch (((stageIndex - 1) % 3) + 1) {
    1 => 'Small Blind',
    2 => 'Big Blind',
    _ => 'Boss Blind',
  };
}

String _comboEn(CombinationType t) {
  return switch (t) {
    CombinationType.highTile => 'High Tile',
    CombinationType.pair => 'Pair',
    CombinationType.twoPair => 'Two Pair',
    CombinationType.triple => 'Triple',
    CombinationType.straight => 'Straight',
    CombinationType.crownStraight => 'Crown Straight',
    CombinationType.flush => 'Flush',
    CombinationType.fullHouse => 'Full House',
    CombinationType.quad => 'Quad',
    CombinationType.straightFlush => 'Straight Flush',
    CombinationType.crownStraightFlush => 'Crown Straight Flush',
    CombinationType.colorStraight => 'Color Straight',
    CombinationType.longStraight => 'Long Straight',
  };
}
