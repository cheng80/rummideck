import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../debug/playbook_clearable_runner.dart';
import '../game/sample_game.dart';
import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../vm/game_session_provider.dart';
import 'game/battle_bottom_bar.dart';
import 'game/battle_center.dart';
import 'game/battle_theme.dart';
import 'game/battle_top_strip.dart';
import 'game/game_common.dart';
import 'game/game_modals.dart';
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

  static const double _framePadding = 12;

  void _toggleOptions() {
    final g = _game;
    if (g == null) return;
    if (_isPaused) {
      g.resumeGame();
    } else {
      g.pauseGame();
    }
  }

  void _openRunInfo() {
    _game?.pauseForRunInfo();
    setState(() => _showRunInfo = true);
    ref.read(gameSessionProvider).setUiTimelinePaused(true);
  }

  void _closeRunInfo() {
    setState(() => _showRunInfo = false);
    ref.read(gameSessionProvider).setUiTimelinePaused(_isPaused);
    if (!_isPaused) {
      _game?.resumeAfterRunInfo();
    }
  }

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
        if (!mounted) return;
        setState(() => _isPaused = paused);
        ref.read(gameSessionProvider).setUiTimelinePaused(paused || _showRunInfo);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);

    ref.listen(gameSessionProvider, (previous, next) {
      if (!kDebugMode) {
        return;
      }
      if (!next.isCatalogLoaded) {
        return;
      }
      if (!ref.read(playbookDebugStartProvider)) {
        return;
      }
      ref.read(playbookDebugStartProvider.notifier).state = false;
      next.debugBootstrapPlaybookToStage(
        PlaybookClearableRunner.kDefaultEnterStageIndex,
      );
    });

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

            final stage = controller.run.stage;
            final topBand = BattleSpacing.topBandHeightCompact;

            final freezeLayerTickers = _isPaused || _showRunInfo;

            Widget gameStack = Stack(
              children: [
                TickerMode(
                  enabled: !freezeLayerTickers,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            BattleSpacing.frameRadius,
                          ),
                          child: BattleTableScene(
                            game: _game!,
                            showTopStrip: false,
                            onRunInfo: _openRunInfo,
                          ),
                        ),
                      ),
                      if (controller.isRunCompleted)
                        const Positioned.fill(
                          child: ModalScrim(child: RunCompletePanel()),
                        ),
                      if (controller.isGameOver)
                        const Positioned.fill(
                          child: ModalScrim(child: GameOverPanel()),
                        ),
                      if (controller.isInteractionLocked &&
                          !controller.isShopOpen &&
                          !controller.isRunCompleted &&
                          !controller.isGameOver)
                        const Positioned.fill(
                          child: AbsorbPointer(
                            absorbing: true,
                            child: ColoredBox(
                              color: AppColors.debugLockTint,
                            ),
                          ),
                        ),
                      if (controller.isCashOutPending)
                        const Positioned.fill(
                          child: CashOutPanel(),
                        ),
                      if (stage != null)
                        Positioned(
                          left: _framePadding,
                          right: _framePadding,
                          top: _framePadding,
                          height: topBand,
                          child: CompactTopStrip(
                            onPause: _toggleOptions,
                            onRunInfo: _openRunInfo,
                          ),
                        ),
                      if (kDebugMode &&
                          stage != null &&
                          controller.isCatalogLoaded &&
                          !controller.isShopOpen &&
                          !controller.isCashOutPending &&
                          !controller.isRunCompleted &&
                          !controller.isGameOver)
                        Positioned(
                          top: _framePadding + topBand + 26,
                          right: _framePadding + 4,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => ref
                                  .read(gameSessionProvider)
                                  .debugOpenShop(),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                child: Text(
                                  'DBG·상점',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amberAccent.shade200,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (controller.isShopOpen)
                        Positioned.fill(
                          child: ShopModalOverlay(
                            topInset: 0,
                            child: ShopPanel(
                              onOpenOptions: _toggleOptions,
                            ),
                          ),
                        ),
                    ],
                  ),
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
                        onClose: _closeRunInfo,
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
