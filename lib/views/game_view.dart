import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_config.dart';
import '../game/game_session_controller.dart';
import '../game/sample_game.dart';
import '../logic/models/combination.dart';
import '../logic/models/tile.dart';
import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../services/game_settings.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  SampleGame? _game;
  late final GameSessionController _controller;
  bool _isPaused = false;
  bool _showRunInfo = false;

  @override
  void initState() {
    super.initState();
    SoundManager.playBgm(AssetPaths.bgmMain);
    _controller = GameSessionController(seedText: 'MVP-001');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= () {
      return SampleGame(
        safeAreaTop: 0,
        safeAreaBottom: 0,
        safeAreaLeft: 0,
        safeAreaRight: 0,
        onPauseStateChanged: (paused) {
          if (mounted) {
            setState(() {
              _isPaused = paused;
            });
          }
        },
      );
    }();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const targetAspectRatio = 390 / 844;
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            var frameWidth = maxWidth;
            var frameHeight = frameWidth / targetAspectRatio;

            if (frameHeight > maxHeight) {
              frameHeight = maxHeight;
              frameWidth = frameHeight * targetAspectRatio;
            }

            return Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: frameWidth,
                    height: frameHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _BattleTableScene(
                              controller: _controller,
                              game: _game!,
                              onRunInfo: () {
                                setState(() {
                                  _showRunInfo = true;
                                });
                              },
                            ),
                          ),
                        ),
                        if (_controller.isShopOpen)
                          Positioned.fill(
                            child: _ModalScrim(
                              child: _ShopPanel(controller: _controller),
                            ),
                          ),
                        if (_controller.isRunCompleted)
                          Positioned.fill(
                            child: _ModalScrim(
                              child: _RunCompletePanel(controller: _controller),
                            ),
                          ),
                        if (_controller.isGameOver)
                          Positioned.fill(
                            child: _ModalScrim(
                              child: _GameOverPanel(controller: _controller),
                            ),
                          ),
                        if (_isPaused)
                          Positioned.fill(
                            child: _ModalScrim(
                              child: _PauseMenuOverlay(
                                game: _game!,
                                seedText: _controller.run.seedText,
                              ),
                            ),
                          ),
                        if (_showRunInfo)
                          Positioned.fill(
                            child: _ModalScrim(
                              child: _RunInfoPanel(
                                controller: _controller,
                                onClose: () {
                                  setState(() {
                                    _showRunInfo = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        if (_controller.isInteractionLocked &&
                            !_showRunInfo &&
                            !_controller.isShopOpen &&
                            !_controller.isRunCompleted &&
                            !_controller.isGameOver &&
                            !_isPaused)
                          const Positioned.fill(
                            child: AbsorbPointer(
                              absorbing: true,
                              child: ColoredBox(color: Color(0x01000000)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BattleTableScene extends StatelessWidget {
  const _BattleTableScene({
    required this.controller,
    required this.game,
    required this.onRunInfo,
  });

  final GameSessionController controller;
  final SampleGame game;
  final VoidCallback onRunInfo;

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
                  const Color(0xFF153A35).withValues(alpha: 0.92),
                  const Color(0xFF1F5C4F).withValues(alpha: 0.88),
                  const Color(0xFF102A24).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _TablePatternPainter())),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _CompactBattleLayout(
                  controller: controller,
                  game: game,
                  viewport: constraints.biggest,
                  onRunInfo: onRunInfo,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactBattleLayout extends StatelessWidget {
  const _CompactBattleLayout({
    required this.controller,
    required this.game,
    required this.viewport,
    required this.onRunInfo,
  });

  final GameSessionController controller;
  final SampleGame game;
  final Size viewport;
  final VoidCallback onRunInfo;

  @override
  Widget build(BuildContext context) {
    final compact = viewport.width < 720 || viewport.height < 900;
    final handHeight = compact ? 190.0 : 210.0;
    final actionHeight = compact ? 34.0 : 40.0;
    final topBandHeight = compact ? 154.0 : 164.0;

    return Column(
      children: [
        SizedBox(
          height: topBandHeight,
          child: _CompactTopStrip(
            controller: controller,
            onPause: game.pauseGame,
            onRunInfo: onRunInfo,
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        _StageStatusStrip(controller: controller),
        SizedBox(height: compact ? 6 : 8),
        _JesterBar(controller: controller),
        SizedBox(height: compact ? 6 : 8),
        Expanded(child: _BattleCenterPanel(controller: controller)),
        SizedBox(height: compact ? 6 : 8),
        SizedBox(
          height: handHeight,
          child: _FanHandZone(controller: controller),
        ),
        SizedBox(height: compact ? 4 : 6),
        SizedBox(
          height: actionHeight,
          child: _BottomBattleBar(controller: controller),
        ),
      ],
    );
  }
}

class _CompactTopStrip extends StatelessWidget {
  const _CompactTopStrip({
    required this.controller,
    required this.onPause,
    required this.onRunInfo,
  });

  final GameSessionController controller;
  final VoidCallback onPause;
  final VoidCallback onRunInfo;

  @override
  Widget build(BuildContext context) {
    final stage = controller.run.stage!;
    final ante = ((stage.stageIndex - 1) ~/ 3) + 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _BlindHeaderCard(
            blindLabel: switch (((stage.stageIndex - 1) % 3) + 1) {
              1 => 'Small Blind',
              2 => 'Big Blind',
              _ => 'Boss Blind',
            },
            targetScore: stage.targetScore,
            rewardLabel: _blindRewardLabel(stage.stageIndex),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _CompactMetaPanel(controller: controller),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _CompactMetaRow(
                  ante: ante,
                  round: stage.stageIndex,
                  hands: controller.run.player.playsLeft,
                  discards: controller.run.player.discardsLeft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: _CompactIconAction(
                  label: 'Options',
                  icon: Icons.pause_rounded,
                  background: const Color(0xFFF0A618),
                  foreground: Colors.black,
                  onTap: onPause,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _CompactIconAction(
                  label: 'Run Info',
                  icon: Icons.article_outlined,
                  background: const Color(0xFFE4554C),
                  foreground: Colors.white,
                  onTap: onRunInfo,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _blindRewardLabel(int stageIndex) {
    return switch (((stageIndex - 1) % 3) + 1) {
      1 => '\$\$\$',
      2 => '\$\$\$\$',
      _ => '\$\$\$\$\$',
    };
  }
}

class _BlindHeaderCard extends StatelessWidget {
  const _BlindHeaderCard({
    required this.blindLabel,
    required this.targetScore,
    required this.rewardLabel,
  });

  final String blindLabel;
  final int targetScore;
  final String rewardLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 120 || constraints.maxHeight < 130;
        final tiny = constraints.maxWidth < 80 || constraints.maxHeight < 90;
        final titleFont = tiny ? 9.0 : (compact ? 12.0 : 16.0);
        final labelFont = tiny ? 8.0 : (compact ? 9.0 : 11.0);
        final valueFont = tiny ? 18.0 : (compact ? 22.0 : 30.0);
        final rewardFont = tiny ? 14.0 : (compact ? 17.0 : 22.0);
        final badgeSize = tiny ? 38.0 : (compact ? 48.0 : 60.0);
        final shortBlind = switch (blindLabel) {
          'Small Blind' => 'SMALL\nBLIND',
          'Big Blind' => 'BIG\nBLIND',
          _ => 'BOSS\nBLIND',
        };

        return Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2626),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x66C39A39), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: compact ? 128 : 164,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blindLabel,
                            style: TextStyle(
                              fontFamily: AssetPaths.fontAngduIpsul140,
                              color: Colors.white,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: tiny ? 4 : 8),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: badgeSize,
                              height: badgeSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: blindLabel == 'Small Blind'
                                    ? const Color(0xFF4258D6)
                                    : blindLabel == 'Big Blind'
                                    ? const Color(0xFFC78B18)
                                    : const Color(0xFF7E2F9A),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  shortBlind,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: tiny ? 8 : 10,
                                    fontWeight: FontWeight.w900,
                                    height: 0.95,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: tiny ? 4 : 8),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Score at least',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: labelFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: tiny ? 2 : 4),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _compactNumber(targetScore),
                              style: TextStyle(
                                color: const Color(0xFFFF7860),
                                fontSize: valueFont,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          SizedBox(height: tiny ? 4 : 6),
                          Align(
                            alignment: Alignment.center,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(
                                  tiny ? 10 : 14,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: tiny ? 9 : 12,
                                  vertical: tiny ? 5 : 6,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Reward ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: labelFont,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        rewardLabel,
                                        style: TextStyle(
                                          color: const Color(0xFFF3C55B),
                                          fontSize: rewardFont,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                    ],
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
          ],
        );
      },
    );
  }
}

class _StageStatusStrip extends StatelessWidget {
  const _StageStatusStrip({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final stage = controller.run.stage!;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: _StatusBadge(
              label: 'Round score',
              value: _compactNumber(stage.currentScore),
              valueColor: Colors.white,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatusBadge(
              label: 'Gold',
              value: '\$${controller.run.player.gold}',
              valueColor: const Color(0xFFF3C55B),
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.alignment,
  });

  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: alignment == CrossAxisAlignment.end
                      ? TextAlign.right
                      : TextAlign.left,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Ante / Round / Hands / Discard 그룹 내부의 개별 수치 셀.
class _CompactMetaCell extends StatelessWidget {
  const _CompactMetaCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 30 || constraints.maxWidth < 52;
        final ultraCompact =
            constraints.maxHeight < 24 || constraints.maxWidth < 36;
        final labelFontSize = ultraCompact
            ? 6.5
            : compact
            ? 7.0
            : 8.0;
        final valueFontSize = ultraCompact
            ? 10.0
            : compact
            ? 12.0
            : 16.0;
        final verticalPadding = ultraCompact ? 2.0 : (compact ? 3.0 : 6.0);
        final horizontalPadding = ultraCompact ? 3.0 : 6.0;
        final spacing = ultraCompact ? 1.0 : (compact ? 2.0 : 4.0);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactIconAction extends StatelessWidget {
  const _CompactIconAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMetaPanel extends StatelessWidget {
  const _CompactMetaPanel({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final combo = controller.previewCombination;
    final score = controller.previewScore;
    final comboLabel = controller.comboLabel(combo?.type);
    return _RailPanel(
      color: const Color(0xFF181F24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  comboLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'lvl.4',
                style: TextStyle(
                  color: Color(0xFFF4CC54),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _BigStatTile(
                  color: const Color(0xFF1E9AFF),
                  value: '${score?.chipsAfterAnomalies ?? 0}',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'x',
                  style: TextStyle(
                    color: Color(0xFFFF6B5C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: _BigStatTile(
                  color: const Color(0xFFFF5B4F),
                  value: '${score?.mult ?? 1}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactMetaRow extends StatelessWidget {
  const _CompactMetaRow({
    required this.ante,
    required this.round,
    required this.hands,
    required this.discards,
  });

  final int ante;
  final int round;
  final int hands;
  final int discards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 320;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF10161C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x44FFFFFF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CompactMetaCell(
                  label: 'Ante',
                  value: '$ante/8',
                  valueColor: const Color(0xFFF0A941),
                ),
              ),
              _MetaDivider(compact: compact),
              Expanded(
                child: _CompactMetaCell(
                  label: compact ? 'Rnd' : 'Round',
                  value: '$round',
                  valueColor: const Color(0xFFF0A941),
                ),
              ),
              _MetaDivider(compact: compact),
              Expanded(
                child: _CompactMetaCell(
                  label: compact ? 'Hand' : 'Hands',
                  value: '$hands',
                  valueColor: const Color(0xFF39A1FF),
                ),
              ),
              _MetaDivider(compact: compact),
              Expanded(
                child: _CompactMetaCell(
                  label: compact ? 'Disc' : 'Discards',
                  value: '$discards',
                  valueColor: const Color(0xFFFF7750),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _JesterBar extends StatelessWidget {
  const _JesterBar({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final anomalies = controller.anomalies;
    return SizedBox(
      height: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jesters',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                for (var index = 0; index < 5; index++) ...[
                  if (index > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _JesterSlotCard(
                      anomaly: index < anomalies.length
                          ? anomalies[index]
                          : null,
                      compact: true,
                      extendedSlot: index == 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JesterSlotCard extends StatelessWidget {
  const _JesterSlotCard({
    required this.anomaly,
    required this.compact,
    this.extendedSlot = false,
  });

  final dynamic anomaly;
  final bool compact;
  final bool extendedSlot;

  @override
  Widget build(BuildContext context) {
    final emptyColors = extendedSlot
        ? [const Color(0xFF21312E), const Color(0xFF172322)]
        : [const Color(0xFF25453F), const Color(0xFF1B312C)];
    final filled = anomaly != null;
    final rarityLabel = filled ? _rarityLabel(anomaly.rarity) : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: filled
              ? [const Color(0xFFF3E6B8), const Color(0xFFC9994A)]
              : emptyColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? const Color(0xFFFFF0C5) : Colors.white24,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 10),
        child: filled
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rarityLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF5F3C0C),
                      fontSize: compact ? 8 : 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      anomaly.name.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2E2A20),
                        fontSize: compact ? 28 : 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    anomaly.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF2A2519),
                      fontSize: compact ? 9 : 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extendedSlot ? 'EXT' : 'JESTER',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: compact ? 8 : 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Icon(
                      extendedSlot
                          ? Icons.add_box_outlined
                          : Icons.add_card_rounded,
                      color: Colors.white30,
                      size: compact ? 22 : 28,
                    ),
                  ),
                  const Spacer(),
                  if (extendedSlot)
                    Text(
                      '5th',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: compact ? 8 : 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  String _rarityLabel(dynamic rarity) {
    return switch (rarity.toString()) {
      'AnomalyRarity.common' => 'COMMON',
      'AnomalyRarity.uncommon' => 'UNCOMMON',
      'AnomalyRarity.rare' => 'RARE',
      'AnomalyRarity.legendary' => 'LEGENDARY',
      _ => 'JESTER',
    };
  }
}

class _BattleCenterPanel extends StatelessWidget {
  const _BattleCenterPanel({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final indices = controller.selectedIndices;
    final selectedTiles = indices
        .map((index) => controller.run.player.hand[index])
        .toList();
    final combo = controller.previewCombination;
    final score = controller.previewScore;
    final lastLogs = controller.logs.take(2).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 310;
        final reserveBottom = compact ? 72.0 : 92.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x552C7A66),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0x55D8C27A), width: 2),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              compact ? 12 : 16,
              16,
              compact ? 10 : 14,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BoardInfoBadge(
                        label: 'Combination',
                        value: controller.comboLabel(combo?.type),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BoardInfoBadge(
                        label: 'Projected',
                        value: '${score?.finalScore ?? 0}',
                        valueColor: const Color(0xFFFFF17C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 14),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.25,
                              colors: [
                                Colors.white.withValues(alpha: 0.09),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: reserveBottom),
                          child: Center(
                            child: selectedTiles.isEmpty
                                ? _CenterHint(compact: compact)
                                : Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (final tile in selectedTiles)
                                        _BattleTileCard(
                                          tile: tile,
                                          width: 48,
                                          lifted: true,
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: compact
                            ? _LogTape(logs: lastLogs, compact: true)
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: _LogTape(logs: lastLogs)),
                                  const SizedBox(width: 12),
                                  if (score != null)
                                    _BreakdownBadge(score: score),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomBattleBar extends StatelessWidget {
  const _BottomBattleBar({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final locked = !controller.run.isStageActive;
    return Row(
      children: [
        Expanded(
          child: _LargeActionButton(
            label: 'Discard',
            subtitle: '${controller.run.player.discardsLeft} left',
            color: const Color(0xFF8E5BD9),
            onPressed: locked ? null : controller.discardSelection,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LargeActionButton(
            label: 'Play Hand',
            subtitle:
                '${controller.selectedCount}/${GameSessionController.maxSelectableTiles}',
            color: const Color(0xFF1A9CFF),
            onPressed: locked ? null : controller.submitSelection,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LargeActionButton(
            label: controller.handSortMode == HandSortMode.rank
                ? 'Rank'
                : 'Suit',
            subtitle: 'toggle order',
            color: const Color(0xFFF0A21F),
            foreground: Colors.black,
            onPressed: locked
                ? null
                : () {
                    if (controller.handSortMode == HandSortMode.rank) {
                      controller.sortHandBySuit();
                    } else {
                      controller.sortHandByRank();
                    }
                  },
          ),
        ),
      ],
    );
  }
}

class _FanHandZone extends StatefulWidget {
  const _FanHandZone({required this.controller});

  final GameSessionController controller;

  @override
  State<_FanHandZone> createState() => _FanHandZoneState();
}

class _FanHandZoneState extends State<_FanHandZone> {
  static const double _deckLaneWidth = 72;
  static const Duration _drawFlightDuration = Duration(milliseconds: 360);

  final List<_DrawFlight> _flights = <_DrawFlight>[];
  int _nextFlightId = 0;
  int? _previousDrawPileCount;

  @override
  void initState() {
    super.initState();
    _previousDrawPileCount = widget.controller.drawPileCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final initialHandCount = widget.controller.run.player.hand.length;
      if (initialHandCount > 0) {
        _spawnDrawFlights(
          drawnCount: initialHandCount,
          handCount: initialHandCount,
        );
      }
    });
  }

  @override
  void dispose() {
    widget.controller.setInteractionLocked(false);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FanHandZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentDrawPileCount = widget.controller.drawPileCount;
    final previousDrawPileCount = _previousDrawPileCount;
    if (previousDrawPileCount != null && currentDrawPileCount < previousDrawPileCount) {
      _spawnDrawFlights(
        drawnCount: previousDrawPileCount - currentDrawPileCount,
        handCount: widget.controller.run.player.hand.length,
      );
    }
    _previousDrawPileCount = currentDrawPileCount;
  }

  void _spawnDrawFlights({
    required int drawnCount,
    required int handCount,
  }) {
    if (drawnCount <= 0 || handCount <= 0) {
      return;
    }

    widget.controller.setInteractionLocked(true);
    final startIndex = (handCount - drawnCount).clamp(0, handCount);
    for (var offset = 0; offset < drawnCount; offset++) {
      final slotIndex = (startIndex + offset).clamp(0, handCount - 1);
      final flight = _DrawFlight(
        id: _nextFlightId++,
        targetSlot: slotIndex,
        totalHandCount: handCount,
        delay: Duration(milliseconds: offset * 55),
      );
      setState(() {
        _flights.add(flight);
      });
      unawaited(
        Future<void>.delayed(
          flight.delay + _drawFlightDuration + const Duration(milliseconds: 120),
          () {
            if (!mounted) {
              return;
            }
            setState(() {
              _flights.removeWhere((entry) => entry.id == flight.id);
            });
            if (_flights.isEmpty) {
              widget.controller.setInteractionLocked(false);
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hand = widget.controller.run.player.hand;
    final selected = widget.controller.selectedIndices.toSet();
    final selectionFull = widget.controller.isSelectionFull;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = hand.length;
          if (count == 0) {
            return const SizedBox.shrink();
          }

          final handWidth = (constraints.maxWidth - _deckLaneWidth).clamp(
            0.0,
            constraints.maxWidth,
          );
          final rows = count > 8 ? 2 : 1;
          final rowOneCount = rows == 1 ? count : count.clamp(0, 8);
          final rowTwoCount = rows == 1 ? 0 : count - rowOneCount;
          final availableHeight = constraints.maxHeight - 28;
          final rowHeight = rows == 1
              ? availableHeight
              : (availableHeight - 18) / 2;
          final tileHeight = rowHeight.clamp(56.0, rows == 1 ? 92.0 : 74.0);
          final cardWidth = (tileHeight * 0.52).clamp(
            34.0,
            rows == 1 ? 52.0 : 42.0,
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (rowOneCount > 0)
                _HandRow(
                  tiles: hand.take(rowOneCount).toList(),
                  selectedIndices: selected,
                  selectionFull: selectionFull,
                  controller: widget.controller,
                  cardWidth: cardWidth,
                  top: rows == 1 ? 14 : 6,
                  indexOffset: 0,
                  availableWidth: handWidth,
                ),
              if (rowTwoCount > 0)
                _HandRow(
                  tiles: hand.skip(rowOneCount).take(rowTwoCount).toList(),
                  selectedIndices: selected,
                  selectionFull: selectionFull,
                  controller: widget.controller,
                  cardWidth: cardWidth,
                  top: tileHeight + 18,
                  indexOffset: rowOneCount,
                  availableWidth: handWidth,
                ),
              Positioned(
                right: 8,
                top: rows == 1 ? 12 : 18,
                bottom: 24,
                width: _deckLaneWidth - 12,
                child: Align(
                  alignment: Alignment.center,
                  child: _DeckStackBadge(
                    drawPileCount: widget.controller.drawPileCount,
                    totalDeckSize: widget.controller.totalDeckSize,
                    discardPileCount: widget.controller.discardPileCount,
                  ),
                ),
              ),
              for (final flight in _flights)
                _DrawFlightCard(
                  key: ValueKey<int>(flight.id),
                  flight: flight,
                  zoneSize: constraints.biggest,
                  handWidth: handWidth,
                  deckLaneWidth: _deckLaneWidth,
                  duration: _drawFlightDuration,
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Text(
                  'Hand ${hand.length}/16',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: constraints.maxWidth < 380 ? 11 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DrawFlight {
  const _DrawFlight({
    required this.id,
    required this.targetSlot,
    required this.totalHandCount,
    required this.delay,
  });

  final int id;
  final int targetSlot;
  final int totalHandCount;
  final Duration delay;
}

class _DeckStackBadge extends StatelessWidget {
  const _DeckStackBadge({
    required this.drawPileCount,
    required this.totalDeckSize,
    required this.discardPileCount,
  });

  final int drawPileCount;
  final int totalDeckSize;
  final int discardPileCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 6,
                top: 4,
                child: _DeckBackCard(
                  width: 40,
                  tint: const Color(0x55FFFFFF),
                ),
              ),
              Positioned(
                left: 3,
                top: 2,
                child: _DeckBackCard(
                  width: 40,
                  tint: const Color(0x77FFFFFF),
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                child: _DeckBackCard(width: 40),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$drawPileCount/$totalDeckSize',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'D $discardPileCount',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _DeckBackCard extends StatelessWidget {
  const _DeckBackCard({required this.width, this.tint = Colors.white});

  final double width;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.38;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF58B3FF).withValues(alpha: tint.a),
            const Color(0xFF1E79DA).withValues(alpha: tint.a),
          ],
        ),
        border: Border.all(color: const Color(0xFFF2F5FB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width * 0.5,
          height: width * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
      ),
    );
  }
}

class _DrawFlightCard extends StatelessWidget {
  const _DrawFlightCard({
    super.key,
    required this.flight,
    required this.zoneSize,
    required this.handWidth,
    required this.deckLaneWidth,
    required this.duration,
  });

  final _DrawFlight flight;
  final Size zoneSize;
  final double handWidth;
  final double deckLaneWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final target = _targetOffset();
    final begin = Offset(
      zoneSize.width - (deckLaneWidth * 0.7),
      zoneSize.height * 0.52,
    );
    final totalDuration = flight.delay + duration;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: totalDuration,
        curve: Curves.easeOutCubic,
        onEnd: null,
        builder: (context, value, child) {
          final delayedValue =
              ((value * totalDuration.inMilliseconds) - flight.delay.inMilliseconds) /
                  duration.inMilliseconds;
          final normalized = delayedValue.clamp(0.0, 1.0);
          final progress = Curves.easeOutCubic.transform(normalized);
          final current = Offset.lerp(begin, target, progress)!;
          final liftArc = (1 - (progress - 0.5).abs() * 2) * 16;
          return Positioned(
            left: current.dx,
            top: current.dy - liftArc,
            child: Opacity(
              opacity: (1 - (progress * 0.08)).clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: (1 - progress) * -0.18,
                child: const _DeckBackCard(width: 34),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _targetOffset() {
    final totalCount = flight.totalHandCount;
    final rows = totalCount > 8 ? 2 : 1;
    final rowOneCount = rows == 1 ? totalCount : totalCount.clamp(0, 8);
    final rowTwoCount = rows == 1 ? 0 : totalCount - rowOneCount;
    final availableHeight = zoneSize.height - 28;
    final rowHeight = rows == 1 ? availableHeight : (availableHeight - 18) / 2;
    final tileHeight = rowHeight.clamp(56.0, rows == 1 ? 92.0 : 74.0);
    final cardWidth = (tileHeight * 0.52).clamp(
      34.0,
      rows == 1 ? 52.0 : 42.0,
    );
    final isSecondRow = flight.targetSlot >= rowOneCount;
    final rowCount = isSecondRow ? rowTwoCount : rowOneCount;
    final localIndex = isSecondRow ? flight.targetSlot - rowOneCount : flight.targetSlot;
    final top = isSecondRow ? tileHeight + 28 : (rows == 1 ? 24.0 : 16.0);

    final totalNaturalWidth = cardWidth * rowCount;
    final overlap = rowCount == 1
        ? 0.0
        : ((totalNaturalWidth - handWidth + 28) / (rowCount - 1)).clamp(
            0.0,
            cardWidth * 0.62,
          );
    final step = cardWidth - overlap;
    final usedWidth = step * (rowCount - 1) + cardWidth;
    final startX = (handWidth - usedWidth) / 2;

    return Offset(startX + (step * localIndex), top + 10);
  }
}

class _HandRow extends StatelessWidget {
  const _HandRow({
    required this.tiles,
    required this.selectedIndices,
    required this.selectionFull,
    required this.controller,
    required this.cardWidth,
    required this.top,
    required this.indexOffset,
    required this.availableWidth,
  });

  final List<Tile> tiles;
  final Set<int> selectedIndices;
  final bool selectionFull;
  final GameSessionController controller;
  final double cardWidth;
  final double top;
  final int indexOffset;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final count = tiles.length;
    if (count == 0) {
      return const SizedBox.shrink();
    }

    final totalNaturalWidth = cardWidth * count;
    final overlap = count == 1
        ? 0.0
        : ((totalNaturalWidth - availableWidth + 28) / (count - 1)).clamp(
            0.0,
            cardWidth * 0.62,
          );
    final step = cardWidth - overlap;
    final usedWidth = step * (count - 1) + cardWidth;
    final startX = (availableWidth - usedWidth) / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var localIndex = 0; localIndex < count; localIndex++)
          Positioned(
            left: startX + (step * localIndex),
            top:
                top +
                (selectedIndices.contains(indexOffset + localIndex) ? 0 : 10),
            child: Transform.rotate(
              angle: _fanAngle(localIndex, count),
              child: GestureDetector(
                onTap: () =>
                    controller.toggleTileSelection(indexOffset + localIndex),
                child: _BattleTileCard(
                  tile: tiles[localIndex],
                  width: cardWidth,
                  lifted: selectedIndices.contains(indexOffset + localIndex),
                  dimmed:
                      selectionFull &&
                      !selectedIndices.contains(indexOffset + localIndex),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _fanAngle(int index, int count) {
    if (count <= 1) {
      return 0;
    }
    final mid = (count - 1) / 2;
    return ((index - mid) / count) * 0.24;
  }
}

class _BattleTileCard extends StatelessWidget {
  const _BattleTileCard({
    required this.tile,
    required this.width,
    this.lifted = false,
    this.dimmed = false,
  });

  final Tile tile;
  final double width;
  final bool lifted;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.28;
    final color = _tileTint(tile.color);
    final opacity = dimmed ? 0.45 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFEFB).withValues(alpha: opacity),
            const Color(0xFFF1E8D7).withValues(alpha: opacity),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: lifted ? const Color(0xFFF2C14E) : const Color(0xFFD8C4A0),
          width: lifted ? 2.5 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dimmed ? 0.08 : 0.22),
            blurRadius: lifted ? 14 : 10,
            offset: Offset(0, lifted ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.08,
          vertical: width * 0.06,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: width * 0.12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${tile.number}',
                    style: TextStyle(
                      color: color.withValues(alpha: opacity),
                      fontSize: width * 0.72,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tileTint(TileColor color) {
    return switch (color) {
      TileColor.red => const Color(0xFFD74452),
      TileColor.blue => const Color(0xFF233E9A),
      TileColor.yellow => const Color(0xFFE07A26),
      TileColor.black => const Color(0xFF193A2B),
    };
  }
}

class _CenterHint extends StatelessWidget {
  const _CenterHint({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxHeight < 84;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Colors.white54,
              size: tight ? 22 : (compact ? 28 : 38),
            ),
            SizedBox(height: tight ? 4 : (compact ? 8 : 10)),
            Text(
              compact ? '손패 타일 선택\n중앙에 놓기' : '손패에서 타일을 선택해\n중앙 플레이 존에 올리세요',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: tight ? 11 : (compact ? 13 : 16),
                fontWeight: FontWeight.w700,
                height: tight ? 1.1 : 1.25,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BoardInfoBadge extends StatelessWidget {
  const _BoardInfoBadge({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 190 || constraints.maxHeight < 42;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 14,
              vertical: compact ? 8 : 10,
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _LogTape extends StatelessWidget {
  const _LogTape({required this.logs, this.compact = false});

  final List<dynamic> logs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Run Log',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            if (logs.isEmpty)
              const Text(
                '아직 기록이 없습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              )
            else
              for (final entry in logs.take(compact ? 1 : 2))
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'S${entry.stageIndex}  ${entry.message}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 10 : 11,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownBadge extends StatelessWidget {
  const _BreakdownBadge({required this.score});

  final dynamic score;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TinyMetric(label: 'Chips', value: '${score.chipsAfterAnomalies}'),
            const SizedBox(width: 12),
            _TinyMetric(label: 'Mult', value: '${score.mult}'),
            const SizedBox(width: 12),
            _TinyMetric(label: 'X', value: score.xMult.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RailPanel extends StatelessWidget {
  const _RailPanel({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x66C39A39), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _BigStatTile extends StatelessWidget {
  const _BigStatTile({required this.color, required this.value});

  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeActionButton extends StatelessWidget {
  const _LargeActionButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
    this.foreground = Colors.white,
  });

  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onPressed;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledBackgroundColor: color.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _TablePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final seeds = [
      Offset(size.width * 0.18, size.height * 0.12),
      Offset(size.width * 0.38, size.height * 0.22),
      Offset(size.width * 0.77, size.height * 0.18),
      Offset(size.width * 0.26, size.height * 0.58),
      Offset(size.width * 0.66, size.height * 0.52),
      Offset(size.width * 0.84, size.height * 0.76),
    ];

    for (final center in seeds) {
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * 0.16,
        height: size.height * 0.1,
      );
      canvas.drawOval(rect.shift(const Offset(18, 14)), shadowPaint);
      canvas.drawOval(rect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _compactNumber(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < raw.length; index++) {
    final reversedIndex = raw.length - index;
    buffer.write(raw[index]);
    if (reversedIndex > 1 && reversedIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

class _ShopPanel extends StatelessWidget {
  const _ShopPanel({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final offers = controller.run.currentShopOffers;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: _GlassPanel(
        color: const Color(0xF010233A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '상점',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            if (offers.isEmpty)
              const Text(
                '현재 구매 가능한 변칙 타일이 없습니다.',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...List.generate(offers.length, (index) {
                final offer = offers[index];
                final needReplace = controller.anomalies.length >= 3;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.anomaly.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${offer.anomaly.rarity.name} / ${offer.price} Gold',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: controller.run.player.gold >= offer.price
                            ? () => controller.buyOffer(
                                index,
                                replaceIndex: needReplace ? 0 : null,
                              )
                            : null,
                        child: Text(needReplace ? '교체 구매' : '구매'),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        controller.run.player.gold >= controller.rerollCost
                        ? controller.rerollShop
                        : null,
                    child: Text('리롤 ${controller.rerollCost}G'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.advanceToNextStage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63E6BE),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('다음 스테이지'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RunInfoPanel extends StatelessWidget {
  const _RunInfoPanel({required this.controller, required this.onClose});

  final GameSessionController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
      child: _GlassPanel(
        color: const Color(0xF010233A),
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
                Expanded(child: _GuideTab(label: '포커 핸드', selected: true)),
                const SizedBox(width: 8),
                Expanded(child: _GuideTab(label: '블라인드', selected: false)),
                const SizedBox(width: 8),
                Expanded(child: _GuideTab(label: '바우처', selected: false)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 2),
                child: Column(
                  children: _handGuideRows()
                      .map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _HandGuideRow(
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
                  backgroundColor: const Color(0xFFF0A618),
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

  List<_HandGuideEntry> _handGuideRows() {
    final player = controller.run.player;

    _HandGuideEntry buildRow(
      CombinationType type,
      String name,
      int chips,
      int mult,
    ) {
      return _HandGuideEntry(
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

class _HandGuideEntry {
  const _HandGuideEntry({
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

class _GuideTab extends StatelessWidget {
  const _GuideTab({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE4554C) : const Color(0xFF3C434A),
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

class _HandGuideRow extends StatelessWidget {
  const _HandGuideRow({
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
                color: const Color(0xFFE8EEF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lv.$level',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2C3340),
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
                  colors: [Color(0xFF2196F3), Color(0xFFFF5B4F)],
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
                  color: Color(0xFFF0A21F),
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

class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final stage = controller.run.stage!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: _GlassPanel(
        color: const Color(0xF0331120),
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

class _RunCompletePanel extends StatelessWidget {
  const _RunCompletePanel({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    final stage = controller.run.stage!;
    final player = controller.run.player;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: _GlassPanel(
        color: const Color(0xF0102C20),
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
                  child: _SummaryChip(
                    label: 'Final Score',
                    value: '${stage.currentScore}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryChip(label: 'Gold', value: '${player.gold}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SummaryChip(
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.color = const Color(0xCC08111F),
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

class _ModalScrim extends StatelessWidget {
  const _ModalScrim({required this.child});

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

class _PauseMenuOverlay extends StatefulWidget {
  const _PauseMenuOverlay({required this.game, required this.seedText});
  final SampleGame game;
  final String seedText;

  @override
  State<_PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<_PauseMenuOverlay> {
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
