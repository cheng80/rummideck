import '../anomalies/anomaly.dart';
import '../models/combination.dart';
import '../models/tile.dart';
import '../score/score_context.dart';
import 'jester_data.dart';

class JesterAnomaly extends Anomaly {
  JesterAnomaly(this.data);

  final JesterData data;

  @override
  String get id => data.id;

  @override
  String get name => data.displayName;

  @override
  AnomalyRarity get rarity => _parseRarity(data.rarity);

  int get baseCost => data.baseCost;

  String get effectText => data.effectText;
  String get effectType => data.effectType;

  @override
  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    if (data.effectType == 'chips_bonus') {
      final bonus = _evaluateChipsBonus(combo, context);
      return chips + bonus;
    }
    if (data.id == 'scholar') {
      return chips + _scholarChips(combo);
    }
    return chips;
  }

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    if (data.effectType == 'mult_bonus') {
      return _evaluateMultBonus(combo, context);
    }
    if (data.id == 'scholar') {
      return _scholarMult(combo);
    }
    return 0;
  }

  @override
  double applyXMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    if (data.effectType == 'xmult_bonus') {
      return _evaluateXMultBonus(combo, context);
    }
    return 1;
  }

  int _evaluateChipsBonus(CombinationResult combo, ScoreContext context) {
    final v = (data.value ?? 0).toInt();

    return switch (data.conditionType) {
      'none' => v,
      'suit_scored' => _suitScoredChips(combo, v),
      'pair' ||
      'two_pair' ||
      'three_of_a_kind' ||
      'straight' ||
      'flush' =>
        _handTypeContainsChips(combo, v),
      'face_card' => _faceCardScoredChips(combo, v),
      'rank_scored' => _rankScoredChips(combo, v),
      'other' => _otherConditionChips(combo, context, v),
      _ => 0,
    };
  }

  int _evaluateMultBonus(CombinationResult combo, ScoreContext context) {
    final v = (data.value ?? 0).toInt();

    return switch (data.conditionType) {
      'none' => v,
      'suit_scored' => _suitScoredMult(combo, v),
      'pair' ||
      'two_pair' ||
      'three_of_a_kind' ||
      'straight' ||
      'flush' =>
        _handTypeContainsMult(combo, v),
      'face_card' => _faceCardScoredMult(combo, v),
      'rank_scored' => _rankScoredMult(combo, context, v),
      'held_card' => _heldCardMult(context, v),
      'other' => _otherConditionMult(combo, context, v),
      'stateful' => 0,
      _ => 0,
    };
  }

  double _evaluateXMultBonus(CombinationResult combo, ScoreContext context) {
    final xv = data.xValue ?? 1.0;

    return switch (data.conditionType) {
      'other' => _otherConditionXMult(context, xv),
      'face_card' => _faceCardXMult(combo, xv),
      _ => 1.0,
    };
  }

  // --- Suit-scored ---

  int _suitScoredChips(CombinationResult combo, int bonus) {
    if (data.mappedTileColors.isEmpty) return 0;
    var total = 0;
    for (final tile in combo.tiles) {
      if (data.mappedTileColors.contains(tile.color)) {
        total += bonus;
      }
    }
    return total;
  }

  int _suitScoredMult(CombinationResult combo, int bonus) {
    if (data.mappedTileColors.isEmpty) return 0;
    var total = 0;
    for (final tile in combo.tiles) {
      if (data.mappedTileColors.contains(tile.color)) {
        total += bonus;
      }
    }
    return total;
  }

  // --- Hand-type contains ---

  bool _comboContainsHandType(CombinationResult combo) {
    return switch (data.conditionType) {
      'pair' => _containsPair(combo),
      'two_pair' => _containsTwoPair(combo),
      'three_of_a_kind' => _containsThreeOfAKind(combo),
      'straight' => combo.isRun,
      'flush' => combo.isColorFocused,
      _ => false,
    };
  }

  int _handTypeContainsChips(CombinationResult combo, int bonus) {
    return _comboContainsHandType(combo) ? bonus : 0;
  }

  int _handTypeContainsMult(CombinationResult combo, int bonus) {
    return _comboContainsHandType(combo) ? bonus : 0;
  }

  bool _containsPair(CombinationResult combo) {
    return combo.type == CombinationType.pair ||
        combo.type == CombinationType.twoPair ||
        combo.type == CombinationType.triple ||
        combo.type == CombinationType.fullHouse ||
        combo.type == CombinationType.quad;
  }

  bool _containsTwoPair(CombinationResult combo) {
    return combo.type == CombinationType.twoPair ||
        combo.type == CombinationType.fullHouse;
  }

  bool _containsThreeOfAKind(CombinationResult combo) {
    return combo.type == CombinationType.triple ||
        combo.type == CombinationType.fullHouse ||
        combo.type == CombinationType.quad;
  }

  // --- Face card ---

  static bool _isFaceCard(Tile tile) => tile.number >= 11 && tile.number <= 13;

  int _faceCardScoredChips(CombinationResult combo, int bonus) {
    var total = 0;
    for (final tile in combo.tiles) {
      if (_isFaceCard(tile)) total += bonus;
    }
    return total;
  }

  int _faceCardScoredMult(CombinationResult combo, int bonus) {
    var total = 0;
    for (final tile in combo.tiles) {
      if (_isFaceCard(tile)) total += bonus;
    }
    return total;
  }

  double _faceCardXMult(CombinationResult combo, double xv) {
    if (data.conditionValue != 'first_scored') return 1.0;
    for (final tile in combo.tiles) {
      if (_isFaceCard(tile)) return xv;
    }
    return 1.0;
  }

  // --- Rank-scored ---

  bool _tileMatchesRank(Tile tile) {
    if (data.mappedTileNumbers.isNotEmpty) {
      return data.mappedTileNumbers.contains(tile.number);
    }
    final cv = data.conditionValue;
    if (cv == 'ace') return tile.number == 1;
    if (cv is List) {
      return cv.any((v) => v is num && v.toInt() == tile.number);
    }
    if (cv is num) return cv.toInt() == tile.number;
    return false;
  }

  int _rankScoredChips(CombinationResult combo, int bonus) {
    var total = 0;
    for (final tile in combo.tiles) {
      if (_tileMatchesRank(tile)) total += bonus;
    }
    return total;
  }

  int _rankScoredMult(
    CombinationResult combo,
    ScoreContext context,
    int bonus,
  ) {
    if (data.trigger == 'held') {
      return _heldRankMult(context, bonus);
    }
    var total = 0;
    for (final tile in combo.tiles) {
      if (_tileMatchesRank(tile)) total += bonus;
    }
    return total;
  }

  int _heldRankMult(ScoreContext context, int bonus) {
    var total = 0;
    for (final tile in context.heldHand) {
      if (_tileMatchesRank(tile)) total += bonus;
    }
    return total;
  }

  // --- Held-card ---

  int _heldCardMult(ScoreContext context, int bonus) {
    if (data.conditionValue == 'lowest_rank' && context.heldHand.isNotEmpty) {
      var lowest = context.heldHand.first.number;
      for (final tile in context.heldHand) {
        if (tile.number < lowest) lowest = tile.number;
      }
      return lowest;
    }
    return 0;
  }

  // --- Other condition ---

  int _otherConditionChips(
    CombinationResult combo,
    ScoreContext context,
    int bonus,
  ) {
    final cv = data.conditionValue;
    if (cv == 'cards_remaining_in_deck') {
      return context.cardsRemainingInDeck * bonus;
    }
    if (cv == 'remaining_discards') {
      return context.discardsRemaining * bonus;
    }
    return 0;
  }

  int _otherConditionMult(
    CombinationResult combo,
    ScoreContext context,
    int bonus,
  ) {
    final cv = data.conditionValue;
    if (cv == 'played_hand_size_lte_3') {
      return context.playedHandSize <= 3 ? bonus : 0;
    }
    if (cv == 'owned_jester_count') {
      return context.ownedJesterCount * bonus;
    }
    if (cv == 'zero_discards_remaining') {
      return context.discardsRemaining == 0 ? bonus : 0;
    }
    return 0;
  }

  double _otherConditionXMult(ScoreContext context, double xv) {
    final cv = data.conditionValue;
    if (cv == 'empty_jester_slots') {
      final empty = context.maxJesterSlots - context.ownedJesterCount;
      if (empty <= 0) return 1.0;
      var result = 1.0;
      for (var i = 0; i < empty; i++) {
        result *= xv;
      }
      return result;
    }
    return 1.0;
  }

  // --- Scholar (dual: chips + mult on Aces) ---

  int _scholarChips(CombinationResult combo) {
    final v = (data.value ?? 0).toInt();
    var total = 0;
    for (final tile in combo.tiles) {
      if (tile.number == 1) total += v;
    }
    return total;
  }

  int _scholarMult(CombinationResult combo) {
    var total = 0;
    for (final tile in combo.tiles) {
      if (tile.number == 1) total += 4;
    }
    return total;
  }

  static AnomalyRarity _parseRarity(String rarity) {
    return switch (rarity) {
      'common' => AnomalyRarity.common,
      'uncommon' => AnomalyRarity.uncommon,
      'rare' => AnomalyRarity.rare,
      'legendary' => AnomalyRarity.legendary,
      _ => AnomalyRarity.common,
    };
  }
}
