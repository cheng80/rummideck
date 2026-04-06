import 'dart:convert';

import '../anomalies/anomaly.dart';
import 'jester_anomaly.dart';
import 'jester_data.dart';

class JesterCatalog {
  const JesterCatalog._(this._jesters);

  factory JesterCatalog.fromJsonString(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    final jesters = list
        .cast<Map<String, dynamic>>()
        .map(JesterData.fromJson)
        .map(JesterAnomaly.new)
        .toList();
    return JesterCatalog._(jesters);
  }

  factory JesterCatalog.fromJsonList(List<Map<String, dynamic>> jsonList) {
    final jesters =
        jsonList.map(JesterData.fromJson).map(JesterAnomaly.new).toList();
    return JesterCatalog._(jesters);
  }

  final List<JesterAnomaly> _jesters;

  List<Anomaly> get all => List<Anomaly>.unmodifiable(_jesters);

  List<JesterAnomaly> get allJesters =>
      List<JesterAnomaly>.unmodifiable(_jesters);

  JesterAnomaly? findById(String id) {
    for (final j in _jesters) {
      if (j.id == id) return j;
    }
    return null;
  }

  /// MVP 호환: 현재 구현 가능한 effectType만 필터.
  /// rule_modifier, retrigger, economy, stateful_growth, other(tarot 등)은 제외.
  List<Anomaly> get scoringJesters {
    return _jesters.where((j) => _isScoringType(j.effectType)).toList();
  }

  static bool _isScoringType(String effectType) {
    return effectType == 'chips_bonus' ||
        effectType == 'mult_bonus' ||
        effectType == 'xmult_bonus';
  }

  /// 상점에서 쓸 수 있는 Jester만 (점수 기여 + scholar 같은 dual).
  /// 후에 economy, rule_modifier 등도 구현되면 풀 카탈로그로 올린다.
  List<Anomaly> get shopCatalog {
    return _jesters.where((j) {
      final et = j.effectType;
      return et == 'chips_bonus' ||
          et == 'mult_bonus' ||
          et == 'xmult_bonus' ||
          j.id == 'scholar';
    }).toList();
  }
}
