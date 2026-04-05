import 'dart:math';

class StageTargetCalculator {
  const StageTargetCalculator({
    this.base = 100,
    this.growth = 1.6,
  });

  final int base;
  final double growth;

  int forStage(int stageNumber) {
    if (stageNumber < 1) {
      throw ArgumentError.value(stageNumber, 'stageNumber', 'must be >= 1');
    }

    final power = stageNumber - 1;
    return (base * pow(growth, power)).floor();
  }
}
