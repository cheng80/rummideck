import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/game_session_controller.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'game_common.dart';

class BottomBattleBar extends ConsumerWidget {
  const BottomBattleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final locked = !controller.run.isStageActive;
    return Row(
      children: [
        Expanded(
          child: LargeActionButton(
            label: 'Discard',
            color: AppColors.purpleDiscard,
            onPressed: locked ? null : controller.discardSelection,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LargeActionButton(
            label: 'Play Hand',
            color: AppColors.blueButton,
            onPressed: locked ? null : controller.submitSelection,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LargeActionButton(
            label: controller.handSortMode == HandSortMode.rank
                ? 'Rank'
                : 'Suit',
            color: AppColors.goldAction,
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
