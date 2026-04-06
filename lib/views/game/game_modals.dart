import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_config.dart';
import '../../game/game_session_controller.dart';
import '../../game/sample_game.dart';
import '../../logic/models/combination.dart';
import '../../resources/asset_paths.dart';
import '../../resources/sound_manager.dart';
import '../../services/game_settings.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';

class ShopPanel extends ConsumerWidget {
  const ShopPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final offers = controller.run.currentShopOffers;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: GlassPanel(
        color: AppColors.modalBg,
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
