import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../game/sample_game.dart';
import '../battle_bottom_bar.dart';
import '../battle_center.dart';
import '../battle_theme.dart';
import '../battle_top_strip.dart';
import '../game_common.dart';
import '../hand_zone.dart';
import '../jester_bar.dart';

/// 전투 테이블 배경 + 패턴 + CompactBattleLayout.
class BattleTableScene extends StatelessWidget {
  const BattleTableScene({
    super.key,
    required this.game,
    required this.onRunInfo,
    this.showTopStrip = true,
  });

  final SampleGame game;
  final VoidCallback onRunInfo;
  final bool showTopStrip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(child: GameWidget<SampleGame>(game: game)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tableGreen1.withValues(alpha: 0.92),
                  AppColors.tableGreen2.withValues(alpha: 0.88),
                  AppColors.tableGreen3.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: TablePatternPainter())),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CompactBattleLayout(
              game: game,
              onRunInfo: onRunInfo,
              showTopStrip: showTopStrip,
            ),
          ),
        ),
      ],
    );
  }
}

/// 전투 화면 컴팩트 레이아웃 — 조립만 담당.
class CompactBattleLayout extends StatelessWidget {
  const CompactBattleLayout({
    super.key,
    required this.game,
    required this.onRunInfo,
    this.showTopStrip = true,
  });

  final SampleGame game;
  final VoidCallback onRunInfo;
  final bool showTopStrip;

  @override
  Widget build(BuildContext context) {
    const topBandHeight = BattleSpacing.topBandHeightCompact;
    const handHeight = BattleSpacing.handHeightCompact;
    const actionHeight = BattleSpacing.actionHeightCompact;

    return Column(
      children: [
        SizedBox(
          height: topBandHeight,
          child: showTopStrip
              ? CompactTopStrip(
                  onPause: game.pauseGame,
                  onRunInfo: onRunInfo,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 6),
        const StageStatusStrip(),
        const SizedBox(height: 6),
        const JesterBar(),
        const SizedBox(height: 6),
        const Expanded(child: BattleCenterPanel()),
        const SizedBox(height: 6),
        SizedBox(
          height: handHeight,
          child: const FanHandZone(),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: actionHeight,
          child: const BottomBattleBar(),
        ),
      ],
    );
  }
}
