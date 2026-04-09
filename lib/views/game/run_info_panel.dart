import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/game_session_controller.dart';
import '../../logic/models/combination.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'widgets/glass_panel.dart';

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
                color: AppColors.guideRowBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lv.$level',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.guideRowText,
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
                  colors: [AppColors.gradientBlue, AppColors.coralGradientEnd],
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
