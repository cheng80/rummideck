import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/logic/anomalies/mvp_anomalies.dart';
import 'package:rummideck/logic/random/seeded_rng.dart';
import 'package:rummideck/logic/shop/shop_state.dart';
import 'package:rummideck/logic/state/stage_state.dart';

void main() {
  group('ShopState', () {
    test('중복 없이 최대 3개의 오퍼를 생성한다', () {
      final shop = ShopState(
        catalog: MvpAnomalyCatalog.all,
        rng: SeededRng(1),
        stage: StageState(stageIndex: 1, targetScore: 100, currentScore: 40),
      );

      shop.generateOffers(ownedAnomalies: const [], playerGold: 100);

      expect(shop.offers.length, lessThanOrEqualTo(3));
      expect(
        shop.offers.map((offer) => offer.anomaly.id).toSet().length,
        shop.offers.length,
      );
    });

    test('보유 중인 anomaly는 오퍼에서 제외한다', () {
      final shop = ShopState(
        catalog: MvpAnomalyCatalog.all,
        rng: SeededRng(2),
        stage: StageState(stageIndex: 1, targetScore: 100, currentScore: 40),
      );

      shop.generateOffers(
        ownedAnomalies: const [TripleBoostAnomaly()],
        playerGold: 100,
      );

      expect(
        shop.offers.any((offer) => offer.anomaly.id == 'triple_boost'),
        isFalse,
      );
    });

    test('골드 이하 가격의 Jester만 오퍼 후보가 된다', () {
      final shop = ShopState(
        catalog: MvpAnomalyCatalog.all,
        rng: SeededRng(4),
        stage: StageState(stageIndex: 1, targetScore: 100, currentScore: 40),
      );

      shop.generateOffers(ownedAnomalies: const [], playerGold: 5);

      expect(shop.offers, isNotEmpty);
      for (final o in shop.offers) {
        expect(o.price, lessThanOrEqualTo(5));
      }
    });

    test('리롤 비용은 5에서 시작하고 리롤마다 1씩 증가한다', () {
      final shop = ShopState(
        catalog: MvpAnomalyCatalog.all,
        rng: SeededRng(3),
        stage: StageState(stageIndex: 1, targetScore: 100, currentScore: 40),
      );

      expect(shop.canAffordReroll(4), isFalse);
      expect(shop.canAffordReroll(5), isTrue);

      shop.generateOffers(ownedAnomalies: const [], playerGold: 100);
      shop.reroll(gold: 5, playerGold: 95, ownedAnomalies: const []);

      expect(shop.currentRerollCost, 6);
      expect(shop.canAffordReroll(5), isFalse);
      expect(shop.canAffordReroll(6), isTrue);
    });
  });
}
