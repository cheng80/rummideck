import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/game_session_controller.dart';
import '../../logic/models/tile.dart';
import '../../utils/tile_utils.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'widgets/battle_tile_card.dart';
import 'widgets/board_info_badge.dart';
import 'widgets/breakdown_badge.dart';
import 'widgets/center_hint.dart';
import 'widgets/debug_measured_tile.dart';
import 'widgets/log_tape.dart';

class BattleCenterPanel extends ConsumerWidget {
  const BattleCenterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final indices = controller.selectedIndices;
    final selectedTiles = indices
        .map((index) => controller.run.player.hand[index])
        .toList();
    final submittedTiles = controller.submittedTiles;
    final combo = controller.previewCombination;
    final score = controller.previewScore;
    final resolution = controller.scoreResolution;
    final lastLogs = controller.logs.take(2).toList();
    final boardTiles =
        resolution != null && submittedTiles.isNotEmpty ? submittedTiles : selectedTiles;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 310;
        final headerHeight = compact ? 44.0 : 52.0;
        final reserveBottom = compact ? 72.0 : 92.0;
        final displayedScore = resolution?.breakdown ?? score;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.centerPanelBg,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.centerPanelBorder, width: 2),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              compact ? 12 : 16,
              16,
              compact ? 10 : 14,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: BoardInfoBadge(
                          label: 'Combination',
                          value: resolution?.comboLabel ??
                              controller.comboLabel(combo?.type),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BoardInfoBadge(
                          label: 'Projected',
                          value: '${displayedScore?.finalScore ?? 0}',
                          valueColor: AppColors.scoreFinal,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  top: headerHeight + (compact ? 6 : 10),
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
                          child: Align(
                            alignment: boardTiles.isEmpty
                                ? Alignment.center
                                : Alignment.bottomCenter,
                            child: boardTiles.isEmpty
                                ? CenterHint(compact: compact)
                                : PlayedTilesStage(
                                    tiles: boardTiles,
                                    resolution: resolution,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: compact
                            ? LogTape(logs: lastLogs, compact: true)
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: LogTape(logs: lastLogs)),
                                  const SizedBox(width: 12),
                                  if (displayedScore != null)
                                    BreakdownBadge(score: displayedScore),
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

class PlayedTilesStage extends ConsumerStatefulWidget {
  const PlayedTilesStage({
    super.key,
    required this.tiles,
    required this.resolution,
  });

  final List<Tile> tiles;
  final ScoreResolutionState? resolution;

  @override
  ConsumerState<PlayedTilesStage> createState() => _PlayedTilesStageState();
}

class _PlayedTilesStageState extends ConsumerState<PlayedTilesStage> {
  Timer? _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _restartSequence();
  }

  @override
  void didUpdateWidget(covariant PlayedTilesStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resolution?.phase != widget.resolution?.phase ||
        !sameTileList(oldWidget.tiles, widget.tiles)) {
      _restartSequence();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _restartSequence() {
    _timer?.cancel();
    final resolution = widget.resolution;
    if (resolution == null ||
        resolution.phase == ScoreResolutionPhase.finalScore ||
        widget.tiles.isEmpty) {
      setState(() {
        _activeIndex = -1;
      });
      return;
    }

    setState(() {
      _activeIndex = 0;
    });

    if (widget.tiles.length <= 1) {
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (ref.read(gameSessionProvider).uiTimelinePaused) {
        return;
      }
      final next = _activeIndex + 1;
      if (next >= widget.tiles.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _activeIndex = next;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlayedTilesOverlay(
      tiles: widget.tiles,
      resolution: widget.resolution,
      activeIndex: _activeIndex,
    );
  }
}

class PlayedTilesOverlay extends StatelessWidget {
  const PlayedTilesOverlay({
    super.key,
    required this.tiles,
    required this.resolution,
    required this.activeIndex,
  });

  final List<Tile> tiles;
  final ScoreResolutionState? resolution;
  final int activeIndex;

  static const double _tileWidth = 48;
  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasResolution = resolution != null;
    final totalWidth =
        (_tileWidth * tiles.length) + (_spacing * (tiles.length - 1));
    final totalHeight = _tileWidth * 1.28;
    final frameColor = _frameColor();
    final popupText = _popupText();

    return SizedBox(
      width: totalWidth,
      height: totalHeight + 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < tiles.length; index++) ...[
                if (index > 0) const SizedBox(width: _spacing),
                index == 0
                    ? DebugMeasuredTile(
                        label: hasResolution
                            ? 'score_first_tile_${resolution!.phase.name}'
                            : 'selected_first_tile',
                        child: BattleTileCard(
                          tile: tiles[index],
                          width: _tileWidth,
                          lifted: true,
                        ),
                      )
                    : BattleTileCard(
                        tile: tiles[index],
                        width: _tileWidth,
                        lifted: true,
                      ),
              ],
            ],
          ),
          if (hasResolution &&
              resolution!.phase != ScoreResolutionPhase.finalScore &&
              activeIndex >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: (activeIndex * (_tileWidth + _spacing)) - 6,
              top: -6,
              child: IgnorePointer(
                child: Container(
                  width: _tileWidth + 12,
                  height: (_tileWidth * 1.28) + 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: frameColor, width: 3),
                    color: frameColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          if (hasResolution &&
              resolution!.phase != ScoreResolutionPhase.finalScore &&
              activeIndex >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: (activeIndex * (_tileWidth + _spacing)) - 2,
              top: -52,
              child: TweenAnimationBuilder<double>(
                key: ValueKey<String>(
                  '${resolution!.phase.name}_${activeIndex}_$popupText',
                ),
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.linear,
                builder: (context, value, child) {
                  final fadeSlice = 0.2 / 0.7;
                  final opacity = value < fadeSlice
                      ? value / fadeSlice
                      : value > (1 - fadeSlice)
                      ? (1 - value) / fadeSlice
                      : 1.0;
                  final scale = value < fadeSlice
                      ? 0.96 + (value / fadeSlice) * 0.08
                      : 1.04;
                  final translateY = -(value * 18);

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, translateY),
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: Text(
                  popupText,
                  style: TextStyle(
                    color: frameColor,
                    fontSize: _tileWidth * 0.76,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          if (hasResolution && resolution!.phase == ScoreResolutionPhase.finalScore)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '+${resolution!.breakdown.finalScore}',
                  style: const TextStyle(
                    color: AppColors.scoreFinal,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _frameColor() {
    if (resolution == null) {
      return Colors.transparent;
    }
    return switch (resolution!.phase) {
      ScoreResolutionPhase.chips => AppColors.blueChips,
      ScoreResolutionPhase.mult => AppColors.coralAlt,
      ScoreResolutionPhase.finalScore => AppColors.scoreFinal,
    };
  }

  String _popupText() {
    if (resolution == null) {
      return '';
    }
    return switch (resolution!.phase) {
      ScoreResolutionPhase.chips =>
        '+${tiles[activeIndex.clamp(0, tiles.length - 1)].number}',
      ScoreResolutionPhase.mult => 'x${resolution!.breakdown.mult}',
      ScoreResolutionPhase.finalScore => '',
    };
  }
}

