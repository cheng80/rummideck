class ScoreContext {
  const ScoreContext({
    this.combinationsSubmittedThisAction = 1,
    this.setsPlayedBefore = 0,
    this.runsPlayedBefore = 0,
    this.discardsUsedThisStage = 0,
  });

  final int combinationsSubmittedThisAction;
  final int setsPlayedBefore;
  final int runsPlayedBefore;
  final int discardsUsedThisStage;
}
