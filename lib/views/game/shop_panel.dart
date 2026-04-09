import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/game_session_controller.dart';
import '../../logic/anomalies/anomaly.dart';
import '../../resources/jester_translation_scope.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'widgets/jester_slot_card.dart';
import 'widgets/shop_offer_detail_card.dart';
import 'jester_detail_sheet.dart';
import 'jester_ui_strings.dart';

class ShopPanel extends ConsumerStatefulWidget {
  const ShopPanel({super.key, this.onOpenOptions});

  /// 상단 스트립이 가려질 때 일시정지(옵션) 메뉴와 동일 동작.
  final VoidCallback? onOpenOptions;

  @override
  ConsumerState<ShopPanel> createState() => _ShopPanelState();
}

class _ShopPanelState extends ConsumerState<ShopPanel> {
  OverlayEntry? _sellOverlay;

  @override
  void dispose() {
    _removeSellOverlay();
    super.dispose();
  }

  void _removeSellOverlay() {
    _sellOverlay?.remove();
    _sellOverlay = null;
  }

  void _insertSellOverlay() {
    if (_sellOverlay != null) {
      return;
    }
    final overlayState = Overlay.of(context);
    _sellOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(ctx).bottom + 20,
              child: Consumer(
                builder: (context, ref, _) {
                  final anomalies = ref.watch(gameSessionProvider).anomalies;
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (_) => true,
                    onAcceptWithDetails: (details) {
                      ref.read(gameSessionProvider).sellJester(details.data);
                      _removeSellOverlay();
                    },
                    builder: (context, candidate, _) {
                      final idx = candidate.isNotEmpty ? candidate.first : null;
                      final gold = (idx != null &&
                              idx >= 0 &&
                              idx < anomalies.length)
                          ? jesterSellGold(anomalies[idx])
                          : null;
                      final highlight = candidate.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1410),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: highlight
                                ? AppColors.goldCoin
                                : const Color(0xFFC9A227),
                            width: highlight ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sell_outlined,
                              color: AppColors.goldCoin.withValues(alpha: 0.9),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                gold != null
                                    ? context.tr(
                                        'jesterSellHint',
                                        namedArgs: {'gold': '$gold'},
                                      )
                                    : context.tr('jesterSellDropHere'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    overlayState.insert(_sellOverlay!);
  }

  String _rarityLabel(BuildContext context, AnomalyRarity rarity) {
    return switch (rarity) {
      AnomalyRarity.common => context.tr('rarityCommon'),
      AnomalyRarity.uncommon => context.tr('rarityUncommon'),
      AnomalyRarity.rare => context.tr('rarityRare'),
      AnomalyRarity.legendary => context.tr('rarityLegendary'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);
    final offers = controller.run.currentShopOffers;
    final t = JesterTranslationScope.of(context);
    final needReplace =
        controller.anomalies.length >= GameSessionController.maxJesterSlots;
    final anomalies = controller.anomalies;
    final gold = controller.run.player.gold;
    final onOptions = widget.onOpenOptions;

    Widget ownedStrip() {
      if (anomalies.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.tr('shopNoOwnedJesters'),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < 5; index++) ...[
            if (index > 0) const SizedBox(width: 4),
            Expanded(
              child: JesterSlotCard(
                anomaly:
                    index < anomalies.length ? anomalies[index] : null,
                slotIndex: index,
                compact: true,
                extendedSlot: index == 4,
                displayName: index < anomalies.length
                    ? localizedJesterName(t, anomalies[index])
                    : '',
                effectText: index < anomalies.length
                    ? localizedJesterEffect(t, anomalies[index])
                    : '',
                rarityLabel: (r) => _rarityLabel(context, r),
                canInteract: index < anomalies.length,
                onOpenDetail: index < anomalies.length
                    ? () => showJesterDetailSheet(
                          context,
                          name: localizedJesterName(t, anomalies[index]),
                          effect: localizedJesterEffect(t, anomalies[index]),
                          rarityText: _rarityLabel(
                            context,
                            anomalies[index].rarity,
                          ),
                          notes: localizedJesterNotes(t, anomalies[index]),
                        )
                    : null,
                onDragStarted:
                    index < anomalies.length ? _insertSellOverlay : null,
                onDragEnd:
                    index < anomalies.length ? _removeSellOverlay : null,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.tr('shop'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (onOptions != null)
              IconButton(
                onPressed: onOptions,
                tooltip: context.tr('options'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.goldCoin,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('shopGoldBalance'),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$gold G',
                          style: const TextStyle(
                            color: AppColors.goldCoin,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('shopOwnedJesters'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('shopInteractHint'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 80,
                    child: ownedStrip(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('shopOffers'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('shopRerollHelp'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: offers.isEmpty
                    ? Center(
                        child: Text(
                          context.tr('shopNoOffers'),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: offers.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final a = offer.anomaly;
                          final canBuy = gold >= offer.price;
                          return ShopOfferDetailCard(
                            name: localizedJesterName(t, a),
                            rarityLabel: _rarityLabel(context, a.rarity),
                            effect: localizedJesterEffect(t, a),
                            notes: localizedJesterNotes(t, a),
                            price: offer.price,
                            canBuy: canBuy,
                            buyLabel: needReplace
                                ? context.tr('shopReplaceBuy')
                                : context.tr('shopBuy'),
                            onBuy: canBuy
                                ? () => controller.buyOffer(
                                      index,
                                      replaceIndex:
                                          needReplace ? 0 : null,
                                    )
                                : null,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: gold >= controller.rerollCost
                          ? controller.rerollShop
                          : null,
                      child: Text(
                        context.tr(
                          'shopRerollCost',
                          namedArgs: {
                            'cost': '${controller.rerollCost}',
                          },
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.mintButton,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: controller.advanceToNextStage,
                      child: Text(
                        context.tr('shopNext'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
