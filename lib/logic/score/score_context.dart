import '../models/tile.dart';

class ScoreContext {
  const ScoreContext({
    this.combinationsSubmittedThisAction = 1,
    this.setsPlayedBefore = 0,
    this.runsPlayedBefore = 0,
    this.discardsUsedThisStage = 0,
    this.discardsRemaining = 3,
    this.cardsRemainingInDeck = 52,
    this.ownedJesterCount = 0,
    this.maxJesterSlots = 5,
    this.playedHandSize = 0,
    this.heldHand = const [],
    this.scoredTiles = const [],
  });

  final int combinationsSubmittedThisAction;
  final int setsPlayedBefore;
  final int runsPlayedBefore;
  final int discardsUsedThisStage;
  final int discardsRemaining;
  final int cardsRemainingInDeck;
  final int ownedJesterCount;
  final int maxJesterSlots;
  final int playedHandSize;
  final List<Tile> heldHand;
  final List<Tile> scoredTiles;
}
