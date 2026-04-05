import '../anomalies/anomaly.dart';
import '../models/combination.dart';
import 'score_context.dart';

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.baseChips,
    required this.numberBonus,
    required this.chipsAfterAnomalies,
    required this.mult,
    required this.xMult,
    required this.finalScore,
  });

  final int baseChips;
  final int numberBonus;
  final int chipsAfterAnomalies;
  final int mult;
  final double xMult;
  final int finalScore;
}

class ScoreCalculator {
  const ScoreCalculator();

  ScoreBreakdown calculate({
    required CombinationResult combo,
    List<Anomaly> anomalies = const [],
    ScoreContext context = const ScoreContext(),
  }) {
    final baseChips = _baseChipsFor(combo.type);
    final numberBonus = (combo.tileSum * 0.2).floor();

    var chips = baseChips + numberBonus;
    for (final anomaly in anomalies) {
      chips = anomaly.applyChips(chips: chips, combo: combo, context: context);
    }

    var mult = 1;
    for (final anomaly in anomalies) {
      mult += anomaly.applyMult(combo: combo, context: context);
    }

    var xMult = 1.0;
    for (final anomaly in anomalies) {
      xMult *= anomaly.applyXMult(combo: combo, context: context);
    }

    return ScoreBreakdown(
      baseChips: baseChips,
      numberBonus: numberBonus,
      chipsAfterAnomalies: chips,
      mult: mult,
      xMult: xMult,
      finalScore: (chips * mult * xMult).floor(),
    );
  }

  int _baseChipsFor(CombinationType type) {
    return switch (type) {
      CombinationType.highTile => 5,
      CombinationType.pair => 10,
      CombinationType.twoPair => 20,
      CombinationType.triple => 30,
      CombinationType.straight => 35,
      CombinationType.crownStraight => 45,
      CombinationType.flush => 40,
      CombinationType.fullHouse => 50,
      CombinationType.quad => 60,
      CombinationType.straightFlush => 75,
      CombinationType.crownStraightFlush => 95,
      CombinationType.colorStraight => 55,
      CombinationType.longStraight => 100,
    };
  }
}
