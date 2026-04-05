import '../anomalies/anomaly.dart';

class ShopOffer {
  const ShopOffer({
    required this.slotIndex,
    required this.anomaly,
  });

  final int slotIndex;
  final Anomaly anomaly;

  int get price => anomaly.rarity.price;
}
