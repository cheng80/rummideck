import '../anomalies/anomaly.dart';
import '../jester/jester_anomaly.dart';

class ShopOffer {
  const ShopOffer({
    required this.slotIndex,
    required this.anomaly,
  });

  final int slotIndex;
  final Anomaly anomaly;

  int get price {
    if (anomaly is JesterAnomaly) {
      return (anomaly as JesterAnomaly).baseCost;
    }
    return anomaly.rarity.price;
  }
}
