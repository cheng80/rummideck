import '../models/tile.dart';

class StandardDeck {
  const StandardDeck._();

  static const int totalTileCount = 52;

  static List<Tile> buildSingleSet() {
    const colors = [
      TileColor.red,
      TileColor.blue,
      TileColor.yellow,
      TileColor.black,
    ];

    final deck = <Tile>[];
    for (final color in colors) {
      for (var number = 1; number <= 13; number++) {
        deck.add(Tile(color: color, number: number));
      }
    }
    return deck;
  }
}
