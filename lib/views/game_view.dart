import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/sample_game.dart';
import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../vm/game_session_provider.dart';
import 'game/battle_bottom_bar.dart';
import 'game/battle_center.dart';
import 'game/battle_top_strip.dart';
import 'game/game_common.dart';
import 'game/game_modals.dart';
import 'game/battle_theme.dart';
import 'game/hand_zone.dart';
import 'game/jester_bar.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  SampleGame? _game;
  bool _isPaused = false;
  bool _showRunInfo = false;

  @override
  void initState() {
    super.initState();
    SoundManager.playBgm(AssetPaths.bgmMain);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= SampleGame(
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
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ColoredBox(
          color: AppColors.tableGreen3,
          child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            // 태블릿(짧은 변 > 500)에서만 FittedBox 스케일링
            // 기준 해상도는 iPhone 실측치(402×778) 사용
            const double refW = 402;
            const double refH = 778;
            const double refAspect = refW / refH;
            final shortSide = maxWidth < maxHeight ? maxWidth : maxHeight;
            final needsScale = shortSide > 500;
            final frameWidth = needsScale
                ? maxHeight * refAspect
                : maxWidth;
            final frameHeight = maxHeight;
            if (!controller.isCatalogLoaded) {
              return Center(
                child: SizedBox(
                  width: frameWidth,
                  height: frameHeight,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                ),
              );
            }

            Widget gameStack = Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                BattleSpacing.frameRadius,
                              ),
                              child: BattleTableScene(
                                game: _game!,
                                onRunInfo: () {
                                  setState(() {
                                    _showRunInfo = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (controller.isShopOpen)
                            const Positioned.fill(
                              child: ModalScrim(child: ShopPanel()),
                            ),
                          if (controller.isRunCompleted)
                            const Positioned.fill(
                              child: ModalScrim(child: RunCompletePanel()),
                            ),
                          if (controller.isGameOver)
                            const Positioned.fill(
                              child: ModalScrim(child: GameOverPanel()),
                            ),
                          if (_isPaused)
                            Positioned.fill(
                              child: ModalScrim(
                                child: PauseMenuOverlay(
                                  game: _game!,
                                  seedText: controller.run.seedText,
                                ),
                              ),
                            ),
                          if (_showRunInfo)
                            Positioned.fill(
                              child: ModalScrim(
                                child: RunInfoPanel(
                                  onClose: () {
                                    setState(() {
                                      _showRunInfo = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          if (controller.isInteractionLocked &&
                              !_showRunInfo &&
                              !controller.isShopOpen &&
                              !controller.isRunCompleted &&
                              !controller.isGameOver &&
                              !_isPaused)
                            const Positioned.fill(
                              child: AbsorbPointer(
                                absorbing: true,
                                child: ColoredBox(
                                  color: AppColors.debugLockTint,
                                ),
                              ),
                            ),
                        ],
            );

            if (needsScale) {
              gameStack = FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: refW,
                  height: refH,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: const Size(refW, refH),
                    ),
                    child: gameStack,
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: gameStack,
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}

class BattleTableScene extends StatelessWidget {
  const BattleTableScene({
    super.key,
    required this.game,
    required this.onRunInfo,
  });

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
            ),
          ),
        ),
      ],
    );
  }
}

class CompactBattleLayout extends StatelessWidget {
  const CompactBattleLayout({
    super.key,
    required this.game,
    required this.onRunInfo,
  });

  final SampleGame game;
  final VoidCallback onRunInfo;

  @override
  Widget build(BuildContext context) {
    const topBandHeight = BattleSpacing.topBandHeightCompact;
    const handHeight = BattleSpacing.handHeightCompact;
    const actionHeight = BattleSpacing.actionHeightCompact;

    return Column(
      children: [
        SizedBox(
          height: topBandHeight,
          child: CompactTopStrip(
            onPause: game.pauseGame,
            onRunInfo: onRunInfo,
          ),
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
