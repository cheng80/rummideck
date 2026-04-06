import '../models/tile.dart';

class JesterData {
  const JesterData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.rarity,
    required this.baseCost,
    required this.effectText,
    required this.trigger,
    required this.effectType,
    required this.conditionType,
    this.conditionValue,
    this.value,
    this.xValue,
    this.mappedTileColors = const [],
    this.mappedTileNumbers = const [],
    this.displayNameKey,
    this.effectTextKey,
    this.notesKey,
  });

  factory JesterData.fromJson(Map<String, dynamic> json) {
    return JesterData(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: (json['displayName'] as String?) ?? json['name'] as String,
      rarity: json['rarity'] as String,
      baseCost: (json['baseCost'] as num).toInt(),
      effectText: (json['effectText'] as String?) ?? '',
      trigger: (json['trigger'] as String?) ?? 'passive',
      effectType: (json['effectType'] as String?) ?? 'other',
      conditionType: (json['conditionType'] as String?) ?? 'none',
      conditionValue: json['conditionValue'],
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      xValue:
          json['xValue'] != null ? (json['xValue'] as num).toDouble() : null,
      mappedTileColors: _parseTileColors(json['mappedTileColors']),
      mappedTileNumbers: _parseTileNumbers(json['mappedTileNumbers']),
      displayNameKey: json['displayNameKey'] as String?,
      effectTextKey: json['effectTextKey'] as String?,
      notesKey: json['notesKey'] as String?,
    );
  }

  final String id;
  final String name;
  final String displayName;
  final String rarity;
  final int baseCost;
  final String effectText;
  final String trigger;
  final String effectType;
  final String conditionType;
  final dynamic conditionValue;
  final double? value;
  final double? xValue;
  final List<TileColor> mappedTileColors;
  final List<int> mappedTileNumbers;
  final String? displayNameKey;
  final String? effectTextKey;
  final String? notesKey;

  static List<TileColor> _parseTileColors(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map(_colorFromString)
        .whereType<TileColor>()
        .toList();
  }

  static TileColor? _colorFromString(String s) {
    return switch (s) {
      'red' => TileColor.red,
      'blue' => TileColor.blue,
      'yellow' => TileColor.yellow,
      'black' => TileColor.black,
      _ => null,
    };
  }

  static List<int> _parseTileNumbers(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<num>().map((n) => n.toInt()).toList();
  }
}
