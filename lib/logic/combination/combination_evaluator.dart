import '../models/combination.dart';
import '../models/tile.dart';

class CombinationEvaluator {
  const CombinationEvaluator({this.allowPair = true});

  final bool allowPair;

  CombinationResult? evaluate(List<Tile> selected) {
    if (selected.isEmpty) {
      return null;
    }

    final tiles = List<Tile>.from(selected)
      ..sort((a, b) => a.number.compareTo(b.number));

    if (tiles.length == 1) {
      return CombinationResult(type: CombinationType.highTile, tiles: tiles);
    }

    if (_isLongStraight(tiles)) {
      return CombinationResult(
        type: CombinationType.longStraight,
        tiles: tiles,
      );
    }

    if (_isCrownStraightFlush(tiles)) {
      return CombinationResult(
        type: CombinationType.crownStraightFlush,
        tiles: tiles,
      );
    }

    if (_isStraightFlush(tiles)) {
      return CombinationResult(
        type: CombinationType.straightFlush,
        tiles: tiles,
      );
    }

    if (_isFullHouse(tiles)) {
      return CombinationResult(type: CombinationType.fullHouse, tiles: tiles);
    }

    if (_isQuad(tiles)) {
      return CombinationResult(type: CombinationType.quad, tiles: tiles);
    }

    if (_isFlush(tiles)) {
      return CombinationResult(type: CombinationType.flush, tiles: tiles);
    }

    if (_isCrownStraight(tiles)) {
      return CombinationResult(
        type: CombinationType.crownStraight,
        tiles: tiles,
      );
    }

    if (_isStraight(tiles)) {
      return CombinationResult(type: CombinationType.straight, tiles: tiles);
    }

    if (_isColorStraight(tiles)) {
      return CombinationResult(
        type: CombinationType.colorStraight,
        tiles: tiles,
      );
    }

    if (_isTriple(tiles)) {
      return CombinationResult(type: CombinationType.triple, tiles: tiles);
    }

    if (_isTwoPair(tiles)) {
      return CombinationResult(type: CombinationType.twoPair, tiles: tiles);
    }

    if (allowPair && _isPair(tiles)) {
      return CombinationResult(type: CombinationType.pair, tiles: tiles);
    }

    return null;
  }

  bool _isPair(List<Tile> tiles) {
    if (tiles.length != 2) {
      return false;
    }
    return tiles[0].number == tiles[1].number;
  }

  bool _isTwoPair(List<Tile> tiles) {
    if (tiles.length != 4) {
      return false;
    }
    final counts = _numberCounts(tiles).values.toList()..sort();
    return counts.length == 2 && counts[0] == 2 && counts[1] == 2;
  }

  bool _isTriple(List<Tile> tiles) {
    if (tiles.length != 3) {
      return false;
    }
    return tiles.map((tile) => tile.number).toSet().length == 1;
  }

  bool _isQuad(List<Tile> tiles) {
    if (tiles.length != 4) {
      return false;
    }
    return tiles.map((tile) => tile.number).toSet().length == 1;
  }

  bool _isStraight(List<Tile> tiles) =>
      tiles.length == 5 && _isStandardStraight(tiles);

  bool _isCrownStraight(List<Tile> tiles) =>
      tiles.length == 5 && _isCrownRun(tiles);

  bool _isFlush(List<Tile> tiles) =>
      tiles.length == 5 &&
      _hasSingleColor(tiles) &&
      !_isStandardStraight(tiles) &&
      !_isCrownRun(tiles);

  bool _isFullHouse(List<Tile> tiles) {
    if (tiles.length != 5) {
      return false;
    }
    final counts = _numberCounts(tiles).values.toList()..sort();
    return counts.length == 2 && counts[0] == 2 && counts[1] == 3;
  }

  bool _isStraightFlush(List<Tile> tiles) =>
      tiles.length == 5 && _hasSingleColor(tiles) && _isStandardStraight(tiles);

  bool _isCrownStraightFlush(List<Tile> tiles) =>
      tiles.length == 5 && _hasSingleColor(tiles) && _isCrownRun(tiles);

  bool _isColorStraight(List<Tile> tiles) =>
      tiles.length == 4 && _hasSingleColor(tiles) && _isConsecutive(tiles);

  bool _isLongStraight(List<Tile> tiles) =>
      tiles.length >= 6 && _hasSingleColor(tiles) && _isConsecutive(tiles);

  bool _hasSingleColor(List<Tile> tiles) =>
      tiles.map((tile) => tile.color).toSet().length == 1;

  bool _isStandardStraight(List<Tile> tiles) =>
      _isConsecutive(tiles) && !_isCrownRun(tiles);

  bool _isCrownRun(List<Tile> tiles) {
    final numbers = tiles.map((tile) => tile.number).toList()..sort();
    if (numbers.toSet().length != numbers.length) {
      return false;
    }
    const crownNumbers = [1, 10, 11, 12, 13];
    for (var index = 0; index < crownNumbers.length; index++) {
      if (numbers[index] != crownNumbers[index]) {
        return false;
      }
    }
    return true;
  }

  bool _isConsecutive(List<Tile> tiles) {
    final numbers = tiles.map((tile) => tile.number).toList()..sort();
    if (numbers.toSet().length != numbers.length) {
      return false;
    }
    for (var index = 1; index < numbers.length; index++) {
      if (numbers[index] != numbers[index - 1] + 1) {
        return false;
      }
    }
    return true;
  }

  Map<int, int> _numberCounts(List<Tile> tiles) {
    final counts = <int, int>{};
    for (final tile in tiles) {
      counts.update(tile.number, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }
}
