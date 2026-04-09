import 'package:flutter/material.dart';

import '../battle_theme.dart';
import '../game_common.dart';

/// Chips / Mult / xMult 미니 점수 분해 표시.
class BreakdownBadge extends StatelessWidget {
  const BreakdownBadge({super.key, required this.score});

  final dynamic score;

  @override
  Widget build(BuildContext context) {
    return SubPanelSurface(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TinyMetric(
            label: 'Chips',
            value: '${score.chipsAfterAnomalies}',
            color: AppColors.blueChips,
          ),
          const SizedBox(width: 8),
          TinyMetric(
            label: 'Mult',
            value: '${score.mult}',
            color: AppColors.coral,
          ),
          if (score.xMult != null && score.xMult != 1.0) ...[
            const SizedBox(width: 8),
            TinyMetric(
              label: 'xMult',
              value: 'x${score.xMult}',
              color: AppColors.goldBonus,
            ),
          ],
        ],
      ),
    );
  }
}

/// 라벨 + 값 소형 수치 표시.
class TinyMetric extends StatelessWidget {
  const TinyMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
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
