import 'dart:collection';

import '../logic/anomalies/anomaly.dart';
import '../logic/combination/combination_evaluator.dart';
import '../logic/deck/standard_deck.dart';
import '../logic/jester/jester_anomaly.dart';
import '../logic/random/seeded_rng.dart';
import '../logic/run/run_context.dart';

/// 플레이북 시뮬: 스테이지마다 **BFS로 최소 행동**(Play/Discard) 클리어 경로를 찾고,
/// 상점은 **점수형 제스터 우선 휴리스틱**으로 1장 구매한다. 통과 실패 시 **다른 가격대·슬롯·미구매** 등
/// [PlaybookShopPick] 체인을 순서대로 재시도한다. (리롤 없음)
///
/// 클리어가 **이론상 불가능**한 상태(덱·규칙상)면 [PlaybookSimulationException].

/// 상점 진입 시 구매할 오퍼 인덱스(0..2). `null` = 이번 상점에서 구매 안 함.
typedef PlaybookShopPick = int? Function(RunContext run);
class PlaybookClearableRunner {
  PlaybookClearableRunner._();

  static const int maxHandSelect = 5;

  static final _evaluator = const CombinationEvaluator(allowPair: true);

  static const int kDefaultEnterStageIndex = 2;

  /// BFS 노드 상한(한 전투·Discard 모드당). 초과 시 `null`로 클리어 불가 처리.
  static const int _maxBfsIterations = 80000;

  /// 기본 상점 구매 시도 순서: 점수 제스터 휴리스틱 → 최저가 → 고가 → 슬롯별 → 미구매.
  static final List<PlaybookShopPick> defaultShopPolicyChain = [
    pickShopHeuristicScoring,
    pickShopCheapest,
    pickShopMostExpensiveAffordable,
    (run) => pickShopSlotIfAffordable(run, 0),
    (run) => pickShopSlotIfAffordable(run, 1),
    (run) => pickShopSlotIfAffordable(run, 2),
    (run) => null,
  ];

  /// [enterStageIndex] 전투 시작 직후 [RunContext].
  static RunContext runToStageStart({
    required String seedText,
    required List<Anomaly> shopCatalog,
    int enterStageIndex = kDefaultEnterStageIndex,
    List<PlaybookShopPick>? shopPolicyChain,
  }) {
    final actions = buildActionsToEnterStage(
      seedText: seedText,
      shopCatalog: shopCatalog,
      enterStageIndex: enterStageIndex,
      shopPolicyChain: shopPolicyChain,
    );
    return replay(seedText: seedText, shopCatalog: shopCatalog, actions: actions);
  }

  /// 문서/테스트용: 재생에 쓰는 전체 액션 시퀀스.
  static List<PlaybookGameAction> buildActionsToEnterStage({
    required String seedText,
    required List<Anomaly> shopCatalog,
    required int enterStageIndex,
    List<PlaybookShopPick>? shopPolicyChain,
  }) {
    if (enterStageIndex < 1 || enterStageIndex > RunContext.maxStage) {
      throw ArgumentError.value(enterStageIndex, 'enterStageIndex');
    }
    if (enterStageIndex == 1) {
      return [];
    }

    final chain = shopPolicyChain ?? defaultShopPolicyChain;
    for (var pi = 0; pi < chain.length; pi++) {
      try {
        return _buildActionsToEnterStageWithPick(
          seedText: seedText,
          shopCatalog: shopCatalog,
          enterStageIndex: enterStageIndex,
          pick: chain[pi],
          policyLabel: pi,
        );
      } on PlaybookSimulationException {
        continue;
      }
    }
    throw PlaybookSimulationException(
      '스테이지 $enterStageIndex 진입: 상점 전략 ${chain.length}종 모두 BFS 실패',
    );
  }

  static List<PlaybookGameAction> _buildActionsToEnterStageWithPick({
    required String seedText,
    required List<Anomaly> shopCatalog,
    required int enterStageIndex,
    required PlaybookShopPick pick,
    required int policyLabel,
  }) {
    final actions = <PlaybookGameAction>[];
    for (var stage = 1; stage < enterStageIndex; stage++) {
      final battle = _bfsShortestBattleClear(
        seedText: seedText,
        shopCatalog: shopCatalog,
        prefix: List<PlaybookGameAction>.from(actions),
      );
      if (battle == null) {
        throw PlaybookSimulationException(
          'policy#$policyLabel 스테이지 $stage 전투 클리어 불가(BFS)',
        );
      }
      actions.addAll(battle);
      actions.add(PgaAfterStageBattle());
      final runAtShop = replay(
        seedText: seedText,
        shopCatalog: shopCatalog,
        actions: actions,
      );
      final offerIndex = pick(runAtShop);
      actions.add(PgaShopBuyOffer(offerIndex));
      actions.add(PgaAdvanceStage());
    }
    return actions;
  }

  /// 스테이지 1부터 BFS·상점을 반복해 런 완료 또는 게임 오버까지의 전체 액션 로그.
  static List<PlaybookGameAction> buildEntireRunActions({
    required String seedText,
    required List<Anomaly> shopCatalog,
    List<PlaybookShopPick>? shopPolicyChain,
  }) {
    final chain = shopPolicyChain ?? defaultShopPolicyChain;
    for (var pi = 0; pi < chain.length; pi++) {
      try {
        return _buildEntireRunWithPick(
          seedText: seedText,
          shopCatalog: shopCatalog,
          pick: chain[pi],
          policyLabel: pi,
        );
      } on PlaybookSimulationException {
        continue;
      }
    }
    throw PlaybookSimulationException(
      '풀 런: 상점 전략 ${chain.length}종 모두 BFS 실패',
    );
  }

  static List<PlaybookGameAction> _buildEntireRunWithPick({
    required String seedText,
    required List<Anomaly> shopCatalog,
    required PlaybookShopPick pick,
    required int policyLabel,
  }) {
    final actions = <PlaybookGameAction>[];
    for (var loop = 0; loop < 48; loop++) {
      final run = replay(
        seedText: seedText,
        shopCatalog: shopCatalog,
        actions: actions,
      );
      if (run.phase == RunPhase.completed) {
        return actions;
      }
      if (run.phase == RunPhase.gameOver) {
        return actions;
      }
      if (run.phase == RunPhase.shop) {
        final offerIndex = pick(run);
        actions.add(PgaShopBuyOffer(offerIndex));
        actions.add(PgaAdvanceStage());
        continue;
      }
      if (run.isStageActive &&
          run.stage != null &&
          !run.stage!.isCleared) {
        final battle = _bfsShortestBattleClear(
          seedText: seedText,
          shopCatalog: shopCatalog,
          prefix: List<PlaybookGameAction>.from(actions),
        );
        if (battle == null) {
          throw PlaybookSimulationException(
            'policy#$policyLabel 스테이지 ${run.stage!.stageIndex} 클리어 불가(BFS)',
          );
        }
        actions.addAll(battle);
        actions.add(PgaAfterStageBattle());
        continue;
      }
      throw StateError('playbook: unexpected phase ${run.phase}');
    }
    throw PlaybookSimulationException(
      'policy#$policyLabel 풀 런: 루프 상한 초과(상태 루프 의심)',
    );
  }

  // --- 상점 선택 (플레이북·디버그 테스트용 공개 API) ---

  /// chips / mult / xmult / scholar 우선, 동점 시 골드 여유(저가 선호).
  static int? pickShopHeuristicScoring(RunContext run) {
    return _pickByOfferScore(run);
  }

  static int? pickShopCheapest(RunContext run) {
    final shop = run.shop!;
    final gold = run.player.gold;
    if (run.player.anomalies.length >= RunContext.maxJesterSlots) {
      return null;
    }
    int? bestI;
    int? bestPrice;
    for (var i = 0; i < shop.offers.length; i++) {
      final p = shop.offers[i].price;
      if (p > gold) {
        continue;
      }
      if (bestPrice == null || p < bestPrice) {
        bestPrice = p;
        bestI = i;
      }
    }
    return bestI;
  }

  static int? pickShopMostExpensiveAffordable(RunContext run) {
    final shop = run.shop!;
    final gold = run.player.gold;
    if (run.player.anomalies.length >= RunContext.maxJesterSlots) {
      return null;
    }
    int? bestI;
    var bestPrice = -1;
    for (var i = 0; i < shop.offers.length; i++) {
      final p = shop.offers[i].price;
      if (p > gold) {
        continue;
      }
      if (p > bestPrice) {
        bestPrice = p;
        bestI = i;
      }
    }
    return bestI;
  }

  static int? pickShopSlotIfAffordable(RunContext run, int slot) {
    final shop = run.shop!;
    if (slot < 0 || slot >= shop.offers.length) {
      return null;
    }
    if (run.player.anomalies.length >= RunContext.maxJesterSlots) {
      return null;
    }
    final o = shop.offers[slot];
    if (run.player.gold < o.price) {
      return null;
    }
    return slot;
  }

  static double _offerPriorityForPlaybook(Anomaly a) {
    if (a is! JesterAnomaly) {
      return 100 + a.rarity.index * 5;
    }
    final v = (a.data.value ?? 0).toDouble();
    return switch (a.effectType) {
      'chips_bonus' => 1000 + v,
      'mult_bonus' => 980 + v * 8,
      'xmult_bonus' => 960 + v * 6,
      _ when a.id == 'scholar' => 970,
      _ => 400 + v,
    };
  }

  static int? _pickByOfferScore(RunContext run) {
    final shop = run.shop!;
    final gold = run.player.gold;
    if (run.player.anomalies.length >= RunContext.maxJesterSlots) {
      return null;
    }
    int? bestI;
    double bestScore = -1;
    var bestPrice = 1 << 30;
    for (var i = 0; i < shop.offers.length; i++) {
      final o = shop.offers[i];
      if (o.price > gold) {
        continue;
      }
      final p = _offerPriorityForPlaybook(o.anomaly);
      if (p > bestScore ||
          (p == bestScore && o.price < bestPrice)) {
        bestScore = p;
        bestPrice = o.price;
        bestI = i;
      }
    }
    return bestI;
  }

  static RunContext replay({
    required String seedText,
    required List<Anomaly> shopCatalog,
    required List<PlaybookGameAction> actions,
  }) {
    final run = _newRun(seedText: seedText, shopCatalog: shopCatalog);
    for (final a in actions) {
      _applyAction(run, a);
      if (run.phase == RunPhase.gameOver) {
        break;
      }
    }
    return run;
  }

  static List<PgaBattleAction>? _bfsShortestBattleClear({
    required String seedText,
    required List<Anomaly> shopCatalog,
    required List<PlaybookGameAction> prefix,
  }) {
    List<PgaBattleAction>? tryBfs(_DiscardExpand mode) {
      // removeAt(0)은 O(n)이라 깊은 탐색에서 사실상 멈춤 — Queue로 O(1) dequeue.
      final q = Queue<List<PgaBattleAction>>()..add([]);
      final visited = <String>{};
      var iter = 0;

      while (q.isNotEmpty && iter < _maxBfsIterations) {
        iter++;
        final path = q.removeFirst();
        final trial = replay(
          seedText: seedText,
          shopCatalog: shopCatalog,
          actions: [...prefix, ...path],
        );
        if (trial.phase == RunPhase.gameOver) {
          continue;
        }
        if (trial.stage?.isCleared ?? false) {
          return path;
        }
        if (!trial.isStageActive || trial.stage == null) {
          continue;
        }
        if (trial.player.playsLeft <= 0) {
          continue;
        }

        final key = _stateKey(trial);
        if (visited.contains(key)) {
          continue;
        }
        visited.add(key);

        for (final indices in _enumerateValidPlays(trial)) {
          q.add([...path, PgaPlay(indices)]);
        }
        if (trial.player.discardsLeft > 0) {
          for (final d in _enumerateDiscards(trial, mode)) {
            q.add([...path, PgaDiscard(d)]);
          }
        }
      }
      return null;
    }

    return tryBfs(_DiscardExpand.singletons) ??
        tryBfs(_DiscardExpand.singletonsAndPairs);
  }

  static Iterable<List<int>> _enumerateValidPlays(RunContext run) sync* {
    final hand = run.player.hand;
    final n = hand.length;
    for (var k = 1; k <= maxHandSelect && k <= n; k++) {
      for (final idx in _combinations(List.generate(n, (i) => i), k)) {
        final tiles = idx.map((i) => hand[i]).toList();
        if (_evaluator.evaluate(tiles) != null) {
          yield idx;
        }
      }
    }
  }

  static Iterable<List<int>> _enumerateDiscards(
    RunContext run,
    _DiscardExpand mode,
  ) sync* {
    final n = run.player.hand.length;
    for (var i = 0; i < n; i++) {
      yield [i];
    }
    if (mode == _DiscardExpand.singletonsAndPairs) {
      for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
          yield [i, j];
        }
      }
    }
  }

  static String _stateKey(RunContext run) {
    final h = run.player.hand.map((t) => t.code).join(',');
    final d = run.drawPile.map((t) => t.code).join(',');
    final disc = run.discardPile.map((t) => t.code).join(',');
    final st = run.stage!;
    return '$h|$d|$disc|${st.currentScore}|${st.targetScore}|'
        '${run.player.playsLeft}|${run.player.discardsLeft}|'
        '${run.player.setsPlayed}|${run.player.runsPlayed}';
  }

  static void _applyAction(RunContext run, PlaybookGameAction a) {
    switch (a) {
      case PgaPlay(:final indices):
        final result = run.submitSelection(indices);
        _sortHandRank(run);
        if (result.stageCleared) {
          return;
        }
        if (result.gameOver) {
          return;
        }
        run.finalizeSubmitContinuation(result: result);
        _sortHandRank(run);
      case PgaDiscard(:final indices):
        run.discardSelection(indices);
        _sortHandRank(run);
      case PgaAfterStageBattle():
        run.discardClearedStageHand();
        run.openShop();
      case PgaShopBuyOffer(:final offerIndex):
        _shopBuyOffer(run, offerIndex);
      case PgaAdvanceStage():
        run.advanceToNextStage();
        _sortHandRank(run);
    }
  }

  static RunContext _newRun({
    required String seedText,
    required List<Anomaly> shopCatalog,
  }) {
    final rng = SeededRng.fromString(seedText);
    final deck = StandardDeck.buildSingleSet();
    rng.shuffle(deck);
    return RunContext(
      seedText: seedText,
      rng: rng,
      drawPile: deck,
      evaluator: _evaluator,
      anomalyCatalog: shopCatalog,
    )..startStage(1);
  }

  static void _shopBuyOffer(RunContext run, int? offerIndex) {
    if (offerIndex == null) {
      return;
    }
    if (run.player.anomalies.length >= RunContext.maxJesterSlots) {
      return;
    }
    final shop = run.shop!;
    if (offerIndex < 0 || offerIndex >= shop.offers.length) {
      return;
    }
    final price = shop.offers[offerIndex].price;
    if (run.player.gold < price) {
      return;
    }
    run.buyAnomaly(offerIndex: offerIndex);
  }

  static void _sortHandRank(RunContext run) {
    run.player.hand.sort((a, b) {
      final c = a.number.compareTo(b.number);
      if (c != 0) {
        return c;
      }
      return a.color.sortOrder.compareTo(b.color.sortOrder);
    });
  }

  static Iterable<List<int>> _combinations(List<int> elems, int k) sync* {
    if (k == 0) {
      yield [];
      return;
    }
    if (elems.length < k) {
      return;
    }
    for (var i = 0; i <= elems.length - k; i++) {
      final first = elems[i];
      for (final rest in _combinations(elems.sublist(i + 1), k - 1)) {
        yield [first, ...rest];
      }
    }
  }
}

enum _DiscardExpand { singletons, singletonsAndPairs }

/// 리플레이/문서용 액션 (스테이지 전투 + 상점/진행).
sealed class PlaybookGameAction {}

/// 전투 중 플레이/버리기만 (BFS가 찾는 최소 경로).
sealed class PgaBattleAction extends PlaybookGameAction {}

final class PgaPlay extends PgaBattleAction {
  PgaPlay(this.indices);
  final List<int> indices;

  @override
  String toString() => 'Play(indices=$indices)';
}

final class PgaDiscard extends PgaBattleAction {
  PgaDiscard(this.indices);
  final List<int> indices;

  @override
  String toString() => 'Discard(indices=$indices)';
}

final class PgaAfterStageBattle extends PlaybookGameAction {
  @override
  String toString() => 'AfterStageBattle(손패 버림·상점)';
}

/// [offerIndex]가 null이면 구매 생략.
final class PgaShopBuyOffer extends PlaybookGameAction {
  PgaShopBuyOffer(this.offerIndex);

  final int? offerIndex;

  @override
  String toString() => 'ShopBuyOffer(offerIndex=$offerIndex)';
}

final class PgaAdvanceStage extends PlaybookGameAction {
  @override
  String toString() => 'AdvanceStage';
}

class PlaybookSimulationException implements Exception {
  PlaybookSimulationException(this.message);

  final String message;

  @override
  String toString() => 'PlaybookSimulationException: $message';
}

/// 하위 호환: 예전 이름.
typedef PlaybookGreedySimulationException = PlaybookSimulationException;
