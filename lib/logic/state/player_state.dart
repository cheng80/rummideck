import '../anomalies/anomaly.dart';
import '../models/combination.dart';
import '../models/tile.dart';

class PlayerState {
  PlayerState({
    List<Tile>? hand,
    List<Anomaly>? anomalies,
    Map<CombinationType, int>? combinationCounts,
    this.gold = 0,
    this.playsLeft = 5,
    this.discardsLeft = 3,
    this.setsPlayed = 0,
    this.runsPlayed = 0,
  }) : hand = hand ?? <Tile>[],
       anomalies = anomalies ?? <Anomaly>[],
       combinationCounts = Map<CombinationType, int>.from(
         combinationCounts ?? const <CombinationType, int>{},
       );

  final List<Tile> hand;
  final List<Anomaly> anomalies;
  int gold;
  int playsLeft;
  int discardsLeft;
  int setsPlayed;
  int runsPlayed;
  final Map<CombinationType, int> combinationCounts;

  void resetTurnResources({int plays = 5, int discards = 3}) {
    playsLeft = plays;
    discardsLeft = discards;
  }

  void recordCombination(CombinationType type) {
    combinationCounts.update(type, (count) => count + 1, ifAbsent: () => 1);

    if (type == CombinationType.triple || type == CombinationType.quad) {
      setsPlayed += 1;
    }
    if (type == CombinationType.straight ||
        type == CombinationType.crownStraight ||
        type == CombinationType.straightFlush ||
        type == CombinationType.crownStraightFlush ||
        type == CombinationType.colorStraight ||
        type == CombinationType.longStraight) {
      runsPlayed += 1;
    }
  }

  int combinationCountFor(CombinationType type) => combinationCounts[type] ?? 0;

  int combinationLevelFor(CombinationType type) {
    return 1 + (combinationCountFor(type) ~/ 10);
  }
}
