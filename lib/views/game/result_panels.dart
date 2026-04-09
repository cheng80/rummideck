import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_config.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'widgets/glass_panel.dart';
import 'widgets/summary_chip.dart';

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
