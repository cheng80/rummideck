import 'package:flutter/foundation.dart' show kDebugMode;

import '../anomalies/anomaly.dart';
import '../combination/combination_evaluator.dart';
import '../models/combination.dart';
import '../models/tile.dart';
import '../progression/stage_target_calculator.dart';
import '../random/seeded_rng.dart';
import '../score/score_calculator.dart';
import '../score/score_context.dart';
import '../shop/shop_offer.dart';
import '../shop/shop_state.dart';
import '../state/player_state.dart';
import '../state/stage_state.dart';

enum RunPhase { stage, shop, completed, gameOver }

class SubmitResult {
  const SubmitResult({
    required this.combination,
    required this.breakdown,
    required this.stageCleared,
    required this.shouldRefillHand,
    required this.gameOver,
  });

  final CombinationResult combination;
  final ScoreBreakdown breakdown;
  final bool stageCleared;
  final bool shouldRefillHand;
  final bool gameOver;
}

class RunContext {
  static const int stageClearGoldBase = 10;
  static const int remainingPlayGoldBonus = 5;
  static const int maxStage = 5;

  RunContext({
    required this.seedText,
    required List<Tile> drawPile,
    SeededRng? rng,
    PlayerState? player,
    StageTargetCalculator? stageTargetCalculator,
    CombinationEvaluator? evaluator,
    ScoreCalculator? scoreCalculator,
    List<Anomaly> anomalyCatalog = const [],
  }) : _drawPile = List<Tile>.from(drawPile),
       rng = rng ?? SeededRng.fromString(seedText),
       player = player ?? PlayerState(),
       _stageTargetCalculator =
           stageTargetCalculator ?? const StageTargetCalculator(),
       _evaluator = evaluator ?? const CombinationEvaluator(allowPair: true),
       _scoreCalculator = scoreCalculator ?? const ScoreCalculator(),
       _anomalyCatalog = List<Anomaly>.from(anomalyCatalog);

  final String seedText;
  final SeededRng rng;
  final PlayerState player;
  final StageTargetCalculator _stageTargetCalculator;
  final CombinationEvaluator _evaluator;
  final ScoreCalculator _scoreCalculator;
  final List<Anomaly> _anomalyCatalog;

  final List<Tile> _drawPile;
  final List<Tile> _discardPile = <Tile>[];
  StageState? stage;
  ShopState? shop;
  RunPhase phase = RunPhase.stage;

  List<Tile> get drawPile => List.unmodifiable(_drawPile);
  List<Tile> get discardPile => List.unmodifiable(_discardPile);
  List<ShopOffer> get currentShopOffers =>
      List.unmodifiable(shop?.offers ?? []);

  bool get isStageActive => phase == RunPhase.stage && stage != null;
  bool get isRunCompleted => phase == RunPhase.completed;

  bool get isStageCleared => stage?.isCleared ?? false;

  bool get isStageFailed {
    final currentStage = stage;
    if (currentStage == null || currentStage.isCleared) {
      return false;
    }
    return player.playsLeft <= 0;
  }

  void startStage(int stageIndex) {
    if (player.hand.isNotEmpty) {
      _discardPile.addAll(player.hand);
      player.hand.clear();
    }

    stage = StageState(
      stageIndex: stageIndex,
      targetScore: _stageTargetCalculator.forStage(stageIndex),
    );
    phase = RunPhase.stage;
    player.resetTurnResources();
    refillHand();
  }

  void refillHand([int targetHandSize = 8]) {
    while (player.hand.length < targetHandSize) {
      final drawn = _drawOne();
      if (drawn == null) {
        break;
      }
      player.hand.add(drawn);
    }
  }

  SubmitResult submitSelection(List<int> handIndices) {
    _ensureStageActive();
    if (player.playsLeft <= 0) {
      throw StateError('No plays left');
    }

    final selectedTiles = _pickTiles(handIndices);
    final combination = _evaluator.evaluate(selectedTiles);
    if (combination == null) {
      throw StateError('Selected tiles do not form a valid combination');
    }

    final removedTiles = _removeHandTiles(handIndices);
    final heldHand = player.hand
        .where((t) => !selectedTiles.contains(t))
        .toList();
    final breakdown = _scoreCalculator.calculate(
      combo: combination,
      anomalies: player.anomalies,
      context: ScoreContext(
        combinationsSubmittedThisAction: 1,
        setsPlayedBefore: player.setsPlayed,
        runsPlayedBefore: player.runsPlayed,
        discardsUsedThisStage: 3 - player.discardsLeft,
        discardsRemaining: player.discardsLeft,
        cardsRemainingInDeck: _drawPile.length,
        ownedJesterCount: player.anomalies.length,
        playedHandSize: selectedTiles.length,
        heldHand: heldHand,
        scoredTiles: selectedTiles,
      ),
    );

    stage!.currentScore += breakdown.finalScore;
    player.playsLeft -= 1;
    player.recordCombination(combination.type);
    _discardPile.addAll(removedTiles);
    final stageCleared = stage!.isCleared;

    final gameOver = !stageCleared && player.playsLeft <= 0;
    final shouldRefillHand = !stageCleared && !gameOver;

    if (stageCleared) {
      _awardStageClearGold();
    }

    return SubmitResult(
      combination: combination,
      breakdown: breakdown,
      stageCleared: stageCleared,
      shouldRefillHand: shouldRefillHand,
      gameOver: gameOver,
    );
  }

  List<Tile> discardSelection(List<int> handIndices) {
    _ensureStageActive();
    if (player.discardsLeft <= 0) {
      throw StateError('No discards left');
    }

    final removedTiles = _removeHandTiles(handIndices);
    player.discardsLeft -= 1;
    _discardPile.addAll(removedTiles);
    refillHand();
    return removedTiles;
  }

  void advanceToNextStage() {
    final currentStage = stage;
    if (currentStage == null || !currentStage.isCleared) {
      throw StateError('Stage is not cleared');
    }

    shop = null;
    if (currentStage.stageIndex >= maxStage) {
      phase = RunPhase.completed;
      return;
    }

    startStage(currentStage.stageIndex + 1);
  }

  void openShop() {
    final currentStage = stage;
    if (currentStage == null || !currentStage.isCleared) {
      throw StateError('Shop can only open after clearing a stage');
    }

    phase = RunPhase.shop;
    shop = ShopState(catalog: _anomalyCatalog, rng: rng, stage: currentStage)
      ..generateOffers(
        ownedAnomalies: player.anomalies,
        playerGold: player.gold,
      );
  }

  /// 디버그 전용. [kDebugMode]에서만 동작. 스테이지 클리어 없이 상점을 연다.
  /// [advanceToNextStage]가 동작하도록 현재 스테이지를 클리어 처리한다.
  void debugOpenShop() {
    if (!kDebugMode) {
      return;
    }
    final currentStage = stage;
    if (currentStage == null) {
      throw StateError('No active stage');
    }
    if (!currentStage.isCleared) {
      currentStage.currentScore = currentStage.targetScore;
    }
    phase = RunPhase.shop;
    shop = ShopState(catalog: _anomalyCatalog, rng: rng, stage: currentStage)
      ..generateOffers(
        ownedAnomalies: player.anomalies,
        playerGold: player.gold,
      );
  }

  /// 스테이지 클리어 직후 손패만 버림. 상점은 [openShop]으로 연다.
  void discardClearedStageHand() {
    final currentStage = stage;
    if (currentStage == null || !currentStage.isCleared) {
      throw StateError('Stage is not cleared');
    }
    if (player.hand.isNotEmpty) {
      _discardPile.addAll(player.hand);
      player.hand.clear();
    }
  }

  void finalizeClearedStageToShop() {
    discardClearedStageHand();
    openShop();
  }

  void finalizeSubmitContinuation({
    required SubmitResult result,
    int targetHandSize = 8,
  }) {
    if (result.stageCleared) {
      finalizeClearedStageToShop();
      return;
    }
    if (result.gameOver) {
      phase = RunPhase.gameOver;
      return;
    }
    if (result.shouldRefillHand) {
      refillHand(targetHandSize);
    }
  }

  void rerollShop() {
    final currentShop = shop;
    if (phase != RunPhase.shop || currentShop == null) {
      throw StateError('Shop is not active');
    }
    if (!currentShop.canAffordReroll(player.gold)) {
      throw StateError('Not enough gold to reroll');
    }

    final goldBeforeReroll = player.gold;
    final rerollCost = currentShop.currentRerollCost;
    player.gold -= rerollCost;
    currentShop.reroll(
      gold: goldBeforeReroll,
      playerGold: player.gold,
      ownedAnomalies: player.anomalies,
    );
  }

  static const int maxJesterSlots = 5;

  void buyAnomaly({required int offerIndex, int? replaceIndex}) {
    final currentShop = shop;
    if (phase != RunPhase.shop || currentShop == null) {
      throw StateError('Shop is not active');
    }
    if (offerIndex < 0 || offerIndex >= currentShop.offers.length) {
      throw RangeError.index(offerIndex, currentShop.offers, 'offerIndex');
    }

    final offer = currentShop.offers[offerIndex];
    if (player.gold < offer.price) {
      throw StateError('Not enough gold to buy anomaly');
    }

    if (player.anomalies.length >= maxJesterSlots) {
      if (replaceIndex == null) {
        throw StateError(
          'Replacement index required when anomaly slots are full',
        );
      }
      if (replaceIndex < 0 || replaceIndex >= player.anomalies.length) {
        throw RangeError.index(replaceIndex, player.anomalies, 'replaceIndex');
      }
      player.anomalies[replaceIndex] = offer.anomaly;
    } else {
      player.anomalies.add(offer.anomaly);
    }

    player.gold -= offer.price;
    currentShop.offers.removeAt(offerIndex);
  }

  /// 보유 Jester 슬롯을 판매하고 골드를 받는다. 스테이지 또는 상점에서만 가능하다.
  void sellOwnedAnomaly(int slotIndex) {
    if (!isStageActive && phase != RunPhase.shop) {
      throw StateError('Jester can only be sold during stage or shop');
    }
    if (slotIndex < 0 || slotIndex >= player.anomalies.length) {
      throw RangeError.index(slotIndex, player.anomalies, 'slotIndex');
    }
    final removed = player.anomalies.removeAt(slotIndex);
    player.gold += _sellGoldFor(removed);
  }

  static int _sellGoldFor(Anomaly a) {
    final p = a.rarity.price;
    final v = p ~/ 2;
    return v < 1 ? 1 : v;
  }

  Tile? _drawOne() {
    if (_drawPile.isEmpty) {
      if (_discardPile.isEmpty) {
        return null;
      }
      _drawPile.addAll(_discardPile);
      _discardPile.clear();
      rng.shuffle(_drawPile);
    }

    return _drawPile.removeAt(0);
  }

  List<Tile> _pickTiles(List<int> handIndices) {
    final normalized = _normalizedIndices(handIndices);
    return normalized.map((index) => player.hand[index]).toList();
  }

  List<Tile> _removeHandTiles(List<int> handIndices) {
    final normalized = _normalizedIndices(handIndices);
    final removed = <Tile>[];
    for (final index in normalized.reversed) {
      removed.add(player.hand.removeAt(index));
    }
    return removed.reversed.toList();
  }

  List<int> _normalizedIndices(List<int> handIndices) {
    if (handIndices.isEmpty) {
      throw StateError('At least one tile must be selected');
    }

    final unique = handIndices.toSet().toList()..sort();
    for (final index in unique) {
      if (index < 0 || index >= player.hand.length) {
        throw RangeError.index(index, player.hand, 'handIndices');
      }
    }
    return unique;
  }

  void _ensureStageActive() {
    if (!isStageActive) {
      throw StateError('Stage is not active');
    }
  }

  /// 스테이지 클리어 직후 지급: [stageClearGoldBase] + (클리어 직후 남은 Plays × [remainingPlayGoldBonus]).
  /// 한 스테이지당 이론상 최소는 클리어 직후 `playsLeft == 0`일 때 [stageClearGoldBase]만(플레이 보너스 0).
  void _awardStageClearGold() {
    player.gold +=
        stageClearGoldBase + (player.playsLeft * remainingPlayGoldBonus);
  }
}
