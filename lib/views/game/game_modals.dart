import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_config.dart';
import '../../game/game_session_controller.dart';
import '../../logic/anomalies/anomaly.dart';
import '../../resources/jester_translation_scope.dart';
import '../../game/sample_game.dart';
import '../../logic/models/combination.dart';
import '../../resources/asset_paths.dart';
import '../../resources/sound_manager.dart';
import '../../services/game_settings.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'jester_bar.dart';
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
                          return _ShopOfferDetailCard(
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

class _ShopOfferDetailCard extends StatelessWidget {
  const _ShopOfferDetailCard({
    required this.name,
    required this.rarityLabel,
    required this.effect,
    required this.notes,
    required this.price,
    required this.canBuy,
    required this.buyLabel,
    required this.onBuy,
  });

  final String name;
  final String rarityLabel;
  final String effect;
  final String? notes;
  final int price;
  final bool canBuy;
  final String buyLabel;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldCoin.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldCoin.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  rarityLabel,
                  style: const TextStyle(
                    color: AppColors.goldCoin,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (effect.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              effect,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('jesterNotesLabel'),
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              notes!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: AppColors.goldCoin.withValues(alpha: canBuy ? 1 : 0.45),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '$price G',
                style: TextStyle(
                  color: AppColors.goldCoin.withValues(alpha: canBuy ? 1 : 0.5),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onBuy,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  backgroundColor: AppColors.goldCta,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                ),
                child: Text(
                  buyLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 상단 HUD 아래, 거의 전체 화면을 쓰는 상점 딤 + 패널.
class ShopModalOverlay extends StatelessWidget {
  const ShopModalOverlay({
    super.key,
    required this.topInset,
    required this.child,
  });

  final double topInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.52)),
        Positioned(
          left: 6,
          right: 6,
          top: topInset,
          bottom: 6,
          child: SafeArea(
            top: topInset == 0,
            bottom: false,
            left: false,
            right: false,
            minimum: const EdgeInsets.only(top: 4),
            child: GlassPanel(
              color: AppColors.modalBg,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 스테이지 클리어 후 골드 정산 — 한 줄씩 표시 후 버튼으로 상점 진입.
class CashOutPanel extends ConsumerStatefulWidget {
  const CashOutPanel({super.key});

  @override
  ConsumerState<CashOutPanel> createState() => _CashOutPanelState();
}

class _CashOutPanelState extends ConsumerState<CashOutPanel>
    with SingleTickerProviderStateMixin {
  static const double _lineSlotHeight = 76;
  static const double _dividerSlotHeight = 28;
  static const double _buttonSlotHeight = 54;

  int _step = 0;

  late final AnimationController _entrance;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _entranceFade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _entranceFade = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOut,
    );
    _entrance.forward();
    _runSteps();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _runSteps() async {
    final session = ref.read(gameSessionProvider);
    await session.delayPresentationTimeline(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _step = 1);
    await session.delayPresentationTimeline(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _step = 2);
    await session.delayPresentationTimeline(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _step = 3);
  }

  String _blindLabel(BuildContext context, int stageIndex) {
    final t = ((stageIndex - 1) % 3) + 1;
    return switch (t) {
      1 => context.tr('smallBlind'),
      2 => context.tr('bigBlind'),
      _ => context.tr('bossBlind'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);
    final b = controller.cashOutBreakdown;
    if (b == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SlideTransition(
              position: _entranceSlide,
              child: FadeTransition(
                opacity: _entranceFade,
                child: GlassPanel(
                  color: AppColors.modalBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('cashOutTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: _lineSlotHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedOpacity(
                              opacity: _step >= 1 ? 1 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                              child: _CashOutLine(
                                leading: _blindLabel(context, b.stageIndex),
                                text: context.tr(
                                  'cashOutTargetLine',
                                  namedArgs: {'target': '${b.targetScore}'},
                                ),
                                trailingGold: b.blindReward,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _dividerSlotHeight,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _step >= 2 ? 1 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  height: 1,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: _lineSlotHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedOpacity(
                              opacity: _step >= 2 ? 1 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                              child: _CashOutLine(
                                leading: '${b.remainingHands}',
                                text: context.tr(
                                  'cashOutHandsLine',
                                  namedArgs: {
                                    'count': '${b.remainingHands}',
                                    'per': '${b.perHandBonus}',
                                  },
                                ),
                                trailingGold: b.handsGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: _buttonSlotHeight,
                          child: IgnorePointer(
                            ignoring: _step < 3,
                            child: AnimatedOpacity(
                              opacity: _step >= 3 ? 1 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.goldCta,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.confirmCashOutEnterShop(),
                                child: Text(
                                  context.tr(
                                    'cashOutEnterShop',
                                    namedArgs: {'gold': '${b.totalGold}'},
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashOutLine extends StatelessWidget {
  const _CashOutLine({
    required this.leading,
    required this.text,
    required this.trailingGold,
  });

  final String leading;
  final String text;
  final int trailingGold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blindSmall.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            leading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          '+${trailingGold}G',
          style: const TextStyle(
            color: AppColors.goldCoin,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class RunInfoPanel extends ConsumerWidget {
  const RunInfoPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
      child: GlassPanel(
        color: AppColors.modalBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Run Info',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: GuideTab(label: '포커 핸드', selected: true)),
                const SizedBox(width: 8),
                Expanded(child: GuideTab(label: '블라인드', selected: false)),
                const SizedBox(width: 8),
                Expanded(child: GuideTab(label: '바우처', selected: false)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 2),
                child: Column(
                  children: _handGuideRows(controller)
                      .map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: HandGuideRow(
                            level: row.level,
                            name: row.name,
                            chips: row.chips,
                            mult: row.mult,
                            count: row.count,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldCta,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '뒤로',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HandGuideEntry> _handGuideRows(GameSessionController controller) {
    final player = controller.run.player;

    HandGuideEntry buildRow(
      CombinationType type,
      String name,
      int chips,
      int mult,
    ) {
      return HandGuideEntry(
        level: player.combinationLevelFor(type),
        name: name,
        chips: chips,
        mult: mult,
        count: player.combinationCountFor(type),
      );
    }

    return [
      buildRow(CombinationType.longStraight, 'Long Straight', 100, 1),
      buildRow(
        CombinationType.crownStraightFlush,
        'Crown Straight Flush',
        95,
        1,
      ),
      buildRow(CombinationType.straightFlush, 'Straight Flush', 75, 1),
      buildRow(CombinationType.quad, 'Quad', 60, 1),
      buildRow(CombinationType.colorStraight, 'Color Straight', 55, 1),
      buildRow(CombinationType.fullHouse, 'Full House', 50, 1),
      buildRow(CombinationType.crownStraight, 'Crown Straight', 45, 1),
      buildRow(CombinationType.flush, 'Flush', 40, 1),
      buildRow(CombinationType.straight, 'Straight', 35, 1),
      buildRow(CombinationType.triple, 'Triple', 30, 1),
      buildRow(CombinationType.twoPair, 'Two Pair', 20, 1),
      buildRow(CombinationType.pair, 'Pair', 10, 1),
      buildRow(CombinationType.highTile, 'High Tile', 5, 1),
    ];
  }
}

class HandGuideEntry {
  const HandGuideEntry({
    required this.level,
    required this.name,
    required this.chips,
    required this.mult,
    required this.count,
  });

  final int level;
  final String name;
  final int chips;
  final int mult;
  final int count;
}

class GuideTab extends StatelessWidget {
  const GuideTab({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.redAction : AppColors.tabInactive,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class HandGuideRow extends StatelessWidget {
  const HandGuideRow({
    super.key,
    required this.level,
    required this.name,
    required this.chips,
    required this.mult,
    required this.count,
  });

  final int level;
  final String name;
  final int chips;
  final int mult;
  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.guideRowBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lv.$level',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.guideRowText,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppColors.gradientBlue, AppColors.coralGradientEnd],
                ),
              ),
              child: Text(
                '$chips x $mult',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 36,
              child: Text(
                '#$count',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.goldAction,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverPanel extends ConsumerWidget {
  const GameOverPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final stage = controller.run.stage!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: GlassPanel(
        color: AppColors.gameOverBg,
        child: Column(
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stage ${stage.stageIndex}에서 목표 점수 ${stage.targetScore}에 도달하지 못했습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.restartRun,
              child: const Text('같은 Seed로 다시 시작'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RoutePaths.title),
              child: const Text('타이틀로 나가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class RunCompletePanel extends ConsumerWidget {
  const RunCompletePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final stage = controller.run.stage!;
    final player = controller.run.player;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: GlassPanel(
        color: AppColors.runCompleteBg,
        child: Column(
          children: [
            const Text(
              'Run Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stage ${stage.stageIndex}까지 클리어했습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryChip(
                    label: 'Final Score',
                    value: '${stage.currentScore}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SummaryChip(label: 'Gold', value: '${player.gold}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SummaryChip(
              label: 'Seed',
              value: controller.run.seedText,
              fullWidth: true,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: controller.restartRun,
              child: const Text('같은 Seed로 다시 시작'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RoutePaths.title),
              child: const Text('타이틀로 나가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryChip extends StatelessWidget {
  const SummaryChip({
    super.key,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: fullWidth
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.color = AppColors.scrimBg,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ModalScrim extends StatelessWidget {
  const ModalScrim({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(12),
      child: Center(child: child),
    );
  }
}

class PauseMenuOverlay extends StatefulWidget {
  const PauseMenuOverlay({super.key, required this.game, required this.seedText});
  final SampleGame game;
  final String seedText;

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _bgmMuted;
  late bool _sfxMuted;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _bgmVolume = GameSettings.bgmVolume;
      _sfxVolume = GameSettings.sfxVolume;
      _bgmMuted = GameSettings.bgmMuted;
      _sfxMuted = GameSettings.sfxMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Seed: ${widget.seedText}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'BGM',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _bgmMuted ? 0.0 : _bgmVolume,
                    onChanged: _bgmMuted
                        ? null
                        : (v) {
                            setState(() {
                              _bgmVolume = v;
                              GameSettings.bgmVolume = v;
                              SoundManager.applyBgmVolume();
                            });
                          },
                  ),
                ),
                Switch(
                  value: _bgmMuted,
                  onChanged: (v) {
                    setState(() {
                      _bgmMuted = v;
                      GameSettings.bgmMuted = v;
                      if (v) {
                        SoundManager.pauseBgm();
                      } else {
                        SoundManager.playBgmIfUnmuted();
                      }
                    });
                  },
                ),
              ],
            ),
            Text(
              '효과음',
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _sfxMuted ? 0.0 : _sfxVolume,
                    onChanged: _sfxMuted
                        ? null
                        : (v) {
                            setState(() {
                              _sfxVolume = v;
                              GameSettings.sfxVolume = v;
                            });
                          },
                  ),
                ),
                Switch(
                  value: _sfxMuted,
                  onChanged: (v) {
                    setState(() {
                      _sfxMuted = v;
                      GameSettings.sfxMuted = v;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  SoundManager.resumeBgm();
                  widget.game.resumeGame();
                },
                child: const Text('계속하기'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  SoundManager.stopBgm();
                  context.go(RoutePaths.title);
                },
                child: const Text('나가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
