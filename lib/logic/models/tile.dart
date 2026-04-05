enum TileColor {
  red('R'),
  blue('B'),
  yellow('Y'),
  black('K');

  const TileColor(this.code);

  final String code;

  int get sortOrder {
    return switch (this) {
      TileColor.red => 0,
      TileColor.blue => 1,
      TileColor.yellow => 2,
      TileColor.black => 3,
    };
  }
}

class Tile {
  const Tile({required this.color, required this.number})
    : assert(number >= 1 && number <= 13, 'Tile number must be 1..13');

  final TileColor color;
  final int number;

  String get code => '${color.code}$number';

  @override
  bool operator ==(Object other) {
    return other is Tile && other.color == color && other.number == number;
  }

  @override
  int get hashCode => Object.hash(color, number);

  @override
  String toString() => code;
}
