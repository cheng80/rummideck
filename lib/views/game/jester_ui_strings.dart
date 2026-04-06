import '../../logic/anomalies/anomaly.dart';
import '../../logic/jester/jester_anomaly.dart';
import '../../logic/jester/jester_translations.dart';

String localizedJesterName(JesterTranslations t, Anomaly a) {
  if (a is JesterAnomaly) {
    return t.resolveDisplayName(a.id, a.name);
  }
  return a.name;
}

String localizedJesterEffect(JesterTranslations t, Anomaly a) {
  if (a is JesterAnomaly) {
    return t.resolveEffectText(a.id, a.effectText);
  }
  return '';
}

String? localizedJesterNotes(JesterTranslations t, Anomaly a) {
  if (a is JesterAnomaly) {
    return t.notes(a.id);
  }
  return null;
}

int jesterSellGold(Anomaly a) {
  final p = a.rarity.price;
  final v = p ~/ 2;
  return v < 1 ? 1 : v;
}
