import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import '../logic/anomalies/anomaly.dart';
import '../logic/combination/combination_evaluator.dart';
import '../logic/deck/standard_deck.dart';
import '../logic/jester/jester_catalog.dart';
import '../logic/models/combination.dart';
import '../logic/models/tile.dart';
import '../logic/random/seeded_rng.dart';
import '../logic/run/run_log_entry.dart';
import '../logic/run/run_context.dart';
import '../logic/score/score_calculator.dart';
import '../logic/score/score_context.dart';

enum HandSortMode { rank, suit }

enum ScoreResolutionPhase { chips, mult, finalScore }

class ScoreResolutionState {
  const ScoreResolutionState({
    required this.comboLabel,
    required this.breakdown,
    required this.tiles,
    required this.phase,
  });

  final String comboLabel;
  final ScoreBreakdown breakdown;
  final List<Tile> tiles;
  final ScoreResolutionPhase phase;
}

class GameSessionController extends ChangeNotifier {
  static const int maxSelectableTiles = 5;
  static const int maxJesterSlots = 5;
  static const String _jesterAssetPath = 'data/common/jesters_common.json';

  GameSessionController({
    required this.seedText,
    JesterCatalog? catalog,
    bool loadFromAsset = true,
  }) {
    _jesterCatalog = catalog;
    if (catalog != null || !loadFromAsset) {
      _catalogLoaded = true;
      _startNewRun(seedText);
    } else {
      _initAsync();
    }
  }

  final String seedText;
  final CombinationEvaluator _evaluator = const CombinationEvaluator(
    allowPair: true,
  );
  final ScoreCalculator _scoreCalculator = const ScoreCalculator();
  JesterCatalog? _jesterCatalog;
  bool _catalogLoaded = false;

  bool get isCatalogLoaded => _catalogLoaded;
  JesterCatalog? get jesterCatalog => _jesterCatalog;

  Future<void> _initAsync() async {
    try {
      final jsonString = await rootBundle.loadString(_jesterAssetPath);
      _jesterCatalog = JesterCatalog.fromJsonString(jsonString);
    } catch (_) {
      _jesterCatalog = null;
    }
    _catalogLoaded = true;
    _startNewRun(seedText);
    notifyListeners();
  }

  late RunContext _run;
  final Set<int> _selectedIndices = <int>{};
  final List<RunLogEntry> _logs = <RunLogEntry>[];
  HandSortMode _handSortMode = HandSortMode.rank;
  String? _statusMessage;
  bool _isInteractionLocked = false;
  bool _isHandExitAnimating = false;
  ScoreResolutionState? _scoreResolution;
  int _displayedRoundScore = 0;
  List<Tile> _submittedTiles = <Tile>[];

  RunContext get run => _run;
  List<int> get selectedIndices => _selectedIndices.toList()..sort();
  String? get statusMessage => _statusMessage;
  bool get isInteractionLocked => _isInteractionLocked;
  bool get isHandExitAnimating => _isHandExitAnimating;
  ScoreResolutionState? get scoreResolution => _scoreResolution;
  int get displayedRoundScore => _displayedRoundScore;
  List<Tile> get submittedTiles => List.unmodifiable(_submittedTiles);

  List<Anomaly> get anomalies => _run.player.anomalies;
  bool get isShopOpen => _run.phase == RunPhase.shop;
  bool get isRunCompleted => _run.phase == RunPhase.completed;
  bool get isGameOver => _run.phase == RunPhase.gameOver;
  List<RunLogEntry> get logs => List.unmodifiable(_logs.reversed);
  int get totalDeckSize => StandardDeck.totalTileCount;
  int get drawPileCount => _run.drawPile.length;
  int get discardPileCount => _run.discardPile.length;
  int get rerollCost => _run.shop?.currentRerollCost ?? 0;
  HandSortMode get handSortMode => _handSortMode;
  int get selectedCount => _selectedIndices.length;
  bool get isSelectionFull => _selectedIndices.length >= maxSelectableTiles;

  CombinationResult? get previewCombination {
    if (_selectedIndices.isEmpty || !_run.isStageActive) {
      return null;
    }
    final indices = selectedIndices;
    final selectedTiles = indices
        .map((index) => _run.player.hand[index])
        .toList();
    return _evaluator.evaluate(selectedTiles);
  }

  ScoreBreakdown? get previewScore {
    final combo = previewCombination;
    if (combo == null) {
      return null;
    }
    return _scoreCalculator.calculate(
      combo: combo,
      anomalies: _run.player.anomalies,
      context: _buildScoreContext(playedTiles: combo.tiles),
    );
  }

  ScoreContext _buildScoreContext({List<Tile> playedTiles = const []}) {
    final hand = _run.player.hand;
    final heldHand = hand
        .where((t) => !playedTiles.contains(t))
        .toList();
    return ScoreContext(
      combinationsSubmittedThisAction: 1,
      setsPlayedBefore: _run.player.setsPlayed,
      runsPlayedBefore: _run.player.runsPlayed,
      discardsUsedThisStage: 3 - _run.player.discardsLeft,
      discardsRemaining: _run.player.discardsLeft,
      cardsRemainingInDeck: _run.drawPile.length,
      ownedJesterCount: _run.player.anomalies.length,
      maxJesterSlots: maxJesterSlots,
      playedHandSize: playedTiles.length,
      heldHand: heldHand,
      scoredTiles: playedTiles,
    );
  }

  void toggleTileSelection(int index) {
    if (!_run.isStageActive || _isInteractionLocked) {
      return;
    }

    if (_selectedIndices.contains(index)) {
      _selectedIndices.remove(index);
    } else {
      if (_selectedIndices.length >= maxSelectableTiles) {
        _statusMessage = '타일은 최대 $maxSelectableTiles장까지 선택할 수 있습니다.';
        notifyListeners();
        return;
      }
      _selectedIndices.add(index);
    }
    _statusMessage = null;
    notifyListeners();
  }

  void submitSelection() {
    if (_isInteractionLocked) {
      return;
    }
    if (_selectedIndices.isEmpty) {
      _statusMessage = '먼저 타일을 선택하세요.';
      notifyListeners();
      return;
    }

    _isInteractionLocked = true;
    notifyListeners();

    try {
      final submittedTiles = selectedIndices
          .map((index) => _run.player.hand[index])
          .toList();
      _submittedTiles = submittedTiles;
      final result = _run.submitSelection(selectedIndices);
      _selectedIndices.clear();
      _applyCurrentHandSort();
      final comboLabel = _comboLabel(result.combination.type);
      _statusMessage = '$comboLabel 제출: +${result.breakdown.finalScore}';
      _appendLog(_statusMessage!);
      notifyListeners();
      unawaited(_runSubmitResolutionSequence(result, comboLabel));
    } on StateError catch (error) {
      _isInteractionLocked = false;
      _statusMessage = error.message;
      notifyListeners();
    }
  }

  void discardSelection() {
    if (_isInteractionLocked) {
      return;
    }
    if (_selectedIndices.isEmpty) {
      _statusMessage = '버릴 타일을 선택하세요.';
      notifyListeners();
      return;
    }

    try {
      _run.discardSelection(selectedIndices);
      _selectedIndices.clear();
      _applyCurrentHandSort();
      _statusMessage = '타일을 버리고 손패를 보충했습니다.';
      _appendLog(_statusMessage!);
      notifyListeners();
    } on StateError catch (error) {
      _statusMessage = error.message;
      notifyListeners();
    }
  }

  void rerollShop() {
    try {
      _run.rerollShop();
      _statusMessage = '상점을 리롤했습니다.';
      _appendLog(_statusMessage!);
      notifyListeners();
    } on StateError catch (error) {
      _statusMessage = error.message;
      notifyListeners();
    }
  }

  void buyOffer(int index, {int? replaceIndex}) {
    try {
      _run.buyAnomaly(offerIndex: index, replaceIndex: replaceIndex);
      _statusMessage = '변칙 타일을 획득했습니다.';
      _appendLog(_statusMessage!);
      notifyListeners();
    } on StateError catch (error) {
      _statusMessage = error.message;
      notifyListeners();
    }
  }

  void advanceToNextStage() {
    try {
      _selectedIndices.clear();
      _run.advanceToNextStage();
      _applyCurrentHandSort();
      _displayedRoundScore = _run.stage?.currentScore ?? 0;
      _statusMessage = _run.isRunCompleted
          ? 'Stage ${RunContext.maxStage} 클리어. 런이 종료되었습니다.'
          : 'Stage ${_run.stage?.stageIndex} 시작';
      _appendLog(_statusMessage!);
      notifyListeners();
    } on StateError catch (error) {
      _statusMessage = error.message;
      notifyListeners();
    }
  }

  void sortHandByRank() {
    if (_isInteractionLocked) {
      return;
    }
    _handSortMode = HandSortMode.rank;
    _selectedIndices.clear();
    _applyCurrentHandSort();
    _statusMessage = '손패를 랭크 기준으로 정렬했습니다.';
    notifyListeners();
  }

  void sortHandBySuit() {
    if (_isInteractionLocked) {
      return;
    }
    _handSortMode = HandSortMode.suit;
    _selectedIndices.clear();
    _applyCurrentHandSort();
    _statusMessage = '손패를 수트 기준으로 정렬했습니다.';
    notifyListeners();
  }

  void restartRun() {
    _startNewRun(seedText);
    _statusMessage = '새 런을 시작했습니다.';
    _appendLog(_statusMessage!);
    notifyListeners();
  }

  void setInteractionLocked(bool locked) {
    if (_isInteractionLocked == locked) {
      return;
    }
    _isInteractionLocked = locked;
    notifyListeners();
  }

  Future<void> _runSubmitResolutionSequence(
    SubmitResult result,
    String comboLabel,
  ) async {
    var shouldUnlockInFinally = true;
    try {
      await _runScoreResolutionSequence(result, comboLabel);
      if (result.stageCleared) {
        await _runStageClearSequence();
      } else if (result.gameOver) {
        _run.finalizeSubmitContinuation(result: result);
        _statusMessage = '플레이를 모두 소모했습니다. 런 종료.';
        _appendLog(_statusMessage!);
      } else {
        _run.finalizeSubmitContinuation(result: result);
        _applyCurrentHandSort();
        _statusMessage = '점수 계산 완료. 새 타일을 보충합니다.';
        notifyListeners();
      }
    } finally {
      _scoreResolution = null;
      _submittedTiles = <Tile>[];
      if (shouldUnlockInFinally) {
        _isInteractionLocked = false;
      }
      notifyListeners();
    }
  }

  Future<void> _runScoreResolutionSequence(
    SubmitResult result,
    String comboLabel,
  ) async {
    final tileCount = result.combination.tiles.length;
    final perTileDuration = Duration(
      milliseconds: tileCount <= 1 ? 900 : (tileCount * 700),
    );

    _scoreResolution = ScoreResolutionState(
      comboLabel: comboLabel,
      breakdown: result.breakdown,
      tiles: result.combination.tiles,
      phase: ScoreResolutionPhase.chips,
    );
    notifyListeners();

    await Future<void>.delayed(perTileDuration);

    _scoreResolution = ScoreResolutionState(
      comboLabel: comboLabel,
      breakdown: result.breakdown,
      tiles: result.combination.tiles,
      phase: ScoreResolutionPhase.mult,
    );
    notifyListeners();

    await Future<void>.delayed(perTileDuration);

    _scoreResolution = ScoreResolutionState(
      comboLabel: comboLabel,
      breakdown: result.breakdown,
      tiles: result.combination.tiles,
      phase: ScoreResolutionPhase.finalScore,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    _displayedRoundScore = _run.stage?.currentScore ?? _displayedRoundScore;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _runStageClearSequence() async {
    _isInteractionLocked = true;
    notifyListeners();

    _isHandExitAnimating = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 420));

    try {
      _run.finalizeClearedStageToShop();
      _statusMessage = '스테이지 클리어. 상점으로 이동합니다.';
      _appendLog(_statusMessage!);
    } finally {
      _isHandExitAnimating = false;
      notifyListeners();
    }
  }

  String comboLabel(CombinationType? type) => _comboLabel(type);

  void _startNewRun(String seed) {
    _handSortMode = HandSortMode.rank;
    final rng = SeededRng.fromString(seed);
    final deck = StandardDeck.buildSingleSet();
    rng.shuffle(deck);
    final catalog = _jesterCatalog?.shopCatalog ?? const <Anomaly>[];
    _run = RunContext(
      seedText: seed,
      rng: rng,
      drawPile: deck,
      evaluator: _evaluator,
      anomalyCatalog: catalog,
    )..startStage(1);
    _applyCurrentHandSort();
    _selectedIndices.clear();
    _logs
      ..clear()
      ..add(const RunLogEntry(message: '새 런 시작', stageIndex: 1));
    _displayedRoundScore = _run.stage?.currentScore ?? 0;
  }

  void _applyCurrentHandSort() {
    _run.player.hand.sort((left, right) {
      return switch (_handSortMode) {
        HandSortMode.rank => _compareByRank(left, right),
        HandSortMode.suit => _compareBySuit(left, right),
      };
    });
  }

  int _compareByRank(Tile left, Tile right) {
    final numberCompare = left.number.compareTo(right.number);
    if (numberCompare != 0) {
      return numberCompare;
    }
    return left.color.sortOrder.compareTo(right.color.sortOrder);
  }

  int _compareBySuit(Tile left, Tile right) {
    final colorCompare = left.color.sortOrder.compareTo(right.color.sortOrder);
    if (colorCompare != 0) {
      return colorCompare;
    }
    return left.number.compareTo(right.number);
  }

  String _comboLabel(CombinationType? type) {
    return switch (type) {
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
      null => '없음',
    };
  }

  void _appendLog(String message) {
    final stageIndex = _run.stage?.stageIndex ?? 0;
    _logs.add(RunLogEntry(message: message, stageIndex: stageIndex));
    if (_logs.length > 40) {
      _logs.removeAt(0);
    }
  }
}
