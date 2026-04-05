import '../models/combination.dart';
import '../score/score_context.dart';

enum AnomalyRarity {
  common,
  uncommon,
  rare,
  legendary;

  int get price => switch (this) {
        AnomalyRarity.common => 5,
        AnomalyRarity.uncommon => 10,
        AnomalyRarity.rare => 20,
        AnomalyRarity.legendary => 40,
      };
}

abstract class Anomaly {
  const Anomaly();

  String get id;
  String get name;
  AnomalyRarity get rarity;

  int applyChips({
    required int chips,
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return chips;
  }

  int applyMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return 0;
  }

  double applyXMult({
    required CombinationResult combo,
    required ScoreContext context,
  }) {
    return 1;
  }
}
