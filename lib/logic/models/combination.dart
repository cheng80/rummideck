import 'tile.dart';

enum CombinationType {
  highTile,
  pair,
  twoPair,
  triple,
  straight,
  crownStraight,
  flush,
  fullHouse,
  quad,
  straightFlush,
  crownStraightFlush,
  colorStraight,
  longStraight,
}

class CombinationResult {
  const CombinationResult({required this.type, required this.tiles});

  final CombinationType type;
  final List<Tile> tiles;

  int get tileSum => tiles.fold(0, (sum, tile) => sum + tile.number);

  bool get isRun =>
      type == CombinationType.straight ||
      type == CombinationType.crownStraight ||
      type == CombinationType.straightFlush ||
      type == CombinationType.crownStraightFlush ||
      type == CombinationType.colorStraight ||
      type == CombinationType.longStraight;

  bool get isSet =>
      type == CombinationType.triple || type == CombinationType.quad;

  bool get isColorFocused =>
      type == CombinationType.flush ||
      type == CombinationType.straightFlush ||
      type == CombinationType.crownStraightFlush ||
      type == CombinationType.colorStraight ||
      type == CombinationType.longStraight;
}
