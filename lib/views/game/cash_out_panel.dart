import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'widgets/glass_panel.dart';

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
