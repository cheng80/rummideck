import '../models/combination.dart';
import '../score/score_context.dart';
import 'anomaly.dart';

class TripleBoostAnomaly extends Anomaly {
  const TripleBoostAnomaly();

  @override
  String get id => 'triple_boost';

  @override
  String get name => 'Triple Boost';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.triple ? chips + 20 : chips;
  }
}

class StraightBoostAnomaly extends Anomaly {
  const StraightBoostAnomaly();

  @override
  String get id => 'straight_boost';

  @override
  String get name => 'Straight Boost';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.straight ||
            combo.type == CombinationType.crownStraight
        ? chips + 20
        : chips;
  }
}

class ColorFocusAnomaly extends Anomaly {
  const ColorFocusAnomaly();

  @override
  String get id => 'color_focus';

  @override
  String get name => 'Color Focus';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    final colors = combo.tiles.map((tile) => tile.color).toSet();
    return combo.isColorFocused || colors.length == 1 ? chips + 10 : chips;
  }
}

class SmallEngineAnomaly extends Anomaly {
  const SmallEngineAnomaly();

  @override
  String get id => 'small_engine';

  @override
  String get name => 'Small Engine';

  @override
  AnomalyRarity get rarity => AnomalyRarity.common;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return 1;
  }
}

class RunEngineAnomaly extends Anomaly {
  const RunEngineAnomaly();

  @override
  String get id => 'run_engine';

  @override
  String get name => 'Run Engine';

  @override
  AnomalyRarity get rarity => AnomalyRarity.uncommon;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.isRun && combo.tiles.length >= 4 ? 2 : 0;
  }
}

class SetEngineAnomaly extends Anomaly {
  const SetEngineAnomaly();

  @override
  String get id => 'set_engine';

  @override
  String get name => 'Set Engine';

  @override
  AnomalyRarity get rarity => AnomalyRarity.uncommon;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    if (!combo.isSet) {
      return 0;
    }

    final totalSetsIncludingCurrent = context.setsPlayedBefore + 1;
    return totalSetsIncludingCurrent.isEven ? 1 : 0;
  }
}

class SplitBoostAnomaly extends Anomaly {
  const SplitBoostAnomaly();

  @override
  String get id => 'split_boost';

  @override
  String get name => 'Split Boost';

  @override
  AnomalyRarity get rarity => AnomalyRarity.uncommon;

  @override
  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return context.combinationsSubmittedThisAction >= 2 ? 2 : 0;
  }
}

class LongRunAmplifierAnomaly extends Anomaly {
  const LongRunAmplifierAnomaly();

  @override
  String get id => 'long_run_amplifier';

  @override
  String get name => 'Long Run Amplifier';

  @override
  AnomalyRarity get rarity => AnomalyRarity.rare;

  @override
  double applyXMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return combo.type == CombinationType.longStraight ? 1.5 : 1;
  }
}

class MvpAnomalyCatalog {
  const MvpAnomalyCatalog._();

  static const List<Anomaly> all = [
    TripleBoostAnomaly(),
    StraightBoostAnomaly(),
    ColorFocusAnomaly(),
    SmallEngineAnomaly(),
    RunEngineAnomaly(),
    SetEngineAnomaly(),
    SplitBoostAnomaly(),
    LongRunAmplifierAnomaly(),
  ];
}
