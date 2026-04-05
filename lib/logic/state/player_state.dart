import '../anomalies/anomaly.dart';
import '../models/combination.dart';
import '../models/tile.dart';

class PlayerState {
  PlayerState({
    List<Tile>? hand,
    List<Anomaly>? anomalies,
    this.gold = 0,
    this.playsLeft = 5,
    this.discardsLeft = 3,
    this.setsPlayed = 0,
    this.runsPlayed = 0,
  }) : hand = hand ?? <Tile>[],
       anomalies = anomalies ?? <Anomaly>[];

  final List<Tile> hand;
  final List<Anomaly> anomalies;
  int gold;
  int playsLeft;
  int discardsLeft;
  int setsPlayed;
  int runsPlayed;

  void resetTurnResources({int plays = 5, int discards = 3}) {
    playsLeft = plays;
    discardsLeft = discards;
  }

  void recordCombination(CombinationType type) {
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
}
