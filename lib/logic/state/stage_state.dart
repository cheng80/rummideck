class StageState {
  StageState({
    required this.stageIndex,
    required this.targetScore,
    this.currentScore = 0,
  });

  final int stageIndex;
  final int targetScore;
  int currentScore;

  bool get isCleared => currentScore >= targetScore;

  double get powerRatio {
    if (targetScore == 0) {
      return 0;
    }
    return currentScore / targetScore;
  }
}
