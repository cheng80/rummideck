import '../anomalies/anomaly.dart';
import '../random/seeded_rng.dart';
import '../state/stage_state.dart';
import 'shop_offer.dart';

class ShopState {
  static const int baseRerollCost = 5;

  ShopState({
    required this.catalog,
    required this.rng,
    required this.stage,
    List<ShopOffer>? offers,
  }) : offers = offers ?? <ShopOffer>[];

  static const int maxSlots = 3;

  final List<Anomaly> catalog;
  final SeededRng rng;
  final StageState stage;
  final List<ShopOffer> offers;
  int currentRerollCost = baseRerollCost;

  bool canAffordReroll(int gold) => gold >= currentRerollCost;

  void generateOffers({required List<Anomaly> ownedAnomalies}) {
    offers
      ..clear()
      ..addAll(_rollOffers(ownedAnomalies));
  }

  void reroll({required int gold, required List<Anomaly> ownedAnomalies}) {
    if (!canAffordReroll(gold)) {
      throw StateError('Not enough gold to reroll');
    }
    generateOffers(ownedAnomalies: ownedAnomalies);
    currentRerollCost += 1;
  }

  List<ShopOffer> _rollOffers(List<Anomaly> ownedAnomalies) {
    final ownedIds = ownedAnomalies.map((anomaly) => anomaly.id).toSet();
    final available = catalog
        .where((anomaly) => !ownedIds.contains(anomaly.id))
        .toList(growable: true);

    final rolled = <ShopOffer>[];
    for (
      var slotIndex = 0;
      slotIndex < maxSlots && available.isNotEmpty;
      slotIndex++
    ) {
      final selected = _pickWeighted(available);
      rolled.add(ShopOffer(slotIndex: slotIndex, anomaly: selected));
      available.removeWhere((item) => item.id == selected.id);
    }
    return rolled;
  }

  Anomaly _pickWeighted(List<Anomaly> candidates) {
    final powerRatio = stage.powerRatio <= 0 ? 0.1 : stage.powerRatio;
    final weighted = candidates
        .map(
          (anomaly) => _WeightedAnomaly(
            anomaly: anomaly,
            weight: _baseWeightFor(anomaly.rarity) * (1 / powerRatio),
          ),
        )
        .toList();

    final totalWeight = weighted.fold<double>(
      0,
      (sum, item) => sum + item.weight,
    );
    var roll = rng.nextDouble() * totalWeight;
    for (final item in weighted) {
      roll -= item.weight;
      if (roll <= 0) {
        return item.anomaly;
      }
    }
    return weighted.last.anomaly;
  }

  double _baseWeightFor(AnomalyRarity rarity) {
    return switch (rarity) {
      AnomalyRarity.common => 70,
      AnomalyRarity.uncommon => 25,
      AnomalyRarity.rare => 5,
      AnomalyRarity.legendary => 40,
    };
  }
}

class _WeightedAnomaly {
  const _WeightedAnomaly({required this.anomaly, required this.weight});

  final Anomaly anomaly;
  final double weight;
}
