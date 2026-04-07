import '../anomalies/anomaly.dart';
import '../jester/jester_anomaly.dart';
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

  void generateOffers({
    required List<Anomaly> ownedAnomalies,
    required int playerGold,
  }) {
    offers
      ..clear()
      ..addAll(_rollOffers(ownedAnomalies, playerGold));
  }

  void reroll({
    required int gold,
    required int playerGold,
    required List<Anomaly> ownedAnomalies,
  }) {
    if (!canAffordReroll(gold)) {
      throw StateError('Not enough gold to reroll');
    }
    generateOffers(ownedAnomalies: ownedAnomalies, playerGold: playerGold);
    currentRerollCost += 1;
  }

  /// 오퍼 가격 ([ShopOffer.price]와 동일 규칙).
  static int priceForCatalogItem(Anomaly anomaly) {
    if (anomaly is JesterAnomaly) {
      return anomaly.baseCost;
    }
    return anomaly.rarity.price;
  }

  List<ShopOffer> _rollOffers(List<Anomaly> ownedAnomalies, int playerGold) {
    final ownedIds = ownedAnomalies.map((anomaly) => anomaly.id).toSet();
    final available = catalog
        .where((anomaly) => !ownedIds.contains(anomaly.id))
        .toList(growable: true);

    if (available.isEmpty) {
      return [];
    }

    var pool = available
        .where((a) => priceForCatalogItem(a) <= playerGold)
        .toList(growable: true);

    // 구매 가능 풀이 비었을 때만, 가장 낮은 가격대만 후보로 두어(최대 3) 다음 상점까지 목표를 보여 준다.
    if (pool.isEmpty) {
      available.sort(
        (a, b) => priceForCatalogItem(a).compareTo(priceForCatalogItem(b)),
      );
      final floor = priceForCatalogItem(available.first);
      pool = available.where((a) => priceForCatalogItem(a) == floor).toList();
    }

    final slotCount = _offerSlotCount(pool.length);
    final rolled = <ShopOffer>[];
    for (var slotIndex = 0; slotIndex < slotCount && pool.isNotEmpty; slotIndex++) {
      final selected = _pickWeighted(pool);
      rolled.add(ShopOffer(slotIndex: slotIndex, anomaly: selected));
      pool.removeWhere((item) => item.id == selected.id);
    }
    return rolled;
  }

  /// 후보가 3종 이상이면 시드로 2 또는 3개만 노출한다.
  int _offerSlotCount(int poolSize) {
    if (poolSize <= 0) {
      return 0;
    }
    if (poolSize == 1) {
      return 1;
    }
    if (poolSize == 2) {
      return 2;
    }
    return 2 + rng.nextInt(2);
  }

  Anomaly _pickWeighted(List<Anomaly> candidates) {
    final powerRatio = stage.powerRatio <= 0 ? 0.1 : stage.powerRatio;
    final weighted = candidates
        .map(
          (anomaly) => _WeightedAnomaly(
            anomaly: anomaly,
            weight: _baseWeightFor(anomaly.rarity) *
                (1 / powerRatio) *
                _scoringJesterOfferBias(anomaly),
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

  /// 전투 점수에 직접 관여하는 제스터는 상점 오퍼에 조금 더 자주 노출되도록 가중.
  static double _scoringJesterOfferBias(Anomaly anomaly) {
    if (anomaly is! JesterAnomaly) {
      return 1;
    }
    final et = anomaly.effectType;
    if (et == 'chips_bonus' ||
        et == 'mult_bonus' ||
        et == 'xmult_bonus' ||
        anomaly.id == 'scholar') {
      return 1.22;
    }
    return 1;
  }
}

class _WeightedAnomaly {
  const _WeightedAnomaly({required this.anomaly, required this.weight});

  final Anomaly anomaly;
  final double weight;
}
