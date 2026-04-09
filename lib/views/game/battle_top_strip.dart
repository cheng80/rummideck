import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'blind_header_card.dart';
import 'meta_panel.dart';

class CompactTopStrip extends ConsumerWidget {
  const CompactTopStrip({
    super.key,
    required this.onPause,
    required this.onRunInfo,
  });

  final VoidCallback onPause;
  final VoidCallback onRunInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final stage = controller.run.stage!;
    final ante = ((stage.stageIndex - 1) ~/ 3) + 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: BlindHeaderCard(
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
                child: CompactMetaPanel(),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: CompactMetaRow(
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
                child: CompactIconAction(
                  label: 'Options',
                  icon: Icons.pause_rounded,
                  background: AppColors.goldCta,
                  foreground: Colors.black,
                  onTap: onPause,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: CompactIconAction(
                  label: 'Run Info',
                  icon: Icons.article_outlined,
                  background: AppColors.redAction,
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
