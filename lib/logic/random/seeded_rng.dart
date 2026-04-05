import 'dart:math';

class SeededRng {
  SeededRng(int seed)
      : seed = seed,
        _random = Random(seed);

  factory SeededRng.fromString(String seedText) {
    return SeededRng(_hashSeed(seedText));
  }

  final int seed;
  final Random _random;

  int nextInt(int max) => _random.nextInt(max);

  double nextDouble() => _random.nextDouble();

  bool nextBool() => _random.nextBool();

  void shuffle<T>(List<T> values) {
    for (var index = values.length - 1; index > 0; index--) {
      final swapIndex = _random.nextInt(index + 1);
      final current = values[index];
      values[index] = values[swapIndex];
      values[swapIndex] = current;
    }
  }

  static int _hashSeed(String input) {
    var hash = 0x811C9DC5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
