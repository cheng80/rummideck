import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'game_common.dart';

class CompactMetaPanel extends ConsumerWidget {
  const CompactMetaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final combo = controller.previewCombination;
    final score = controller.scoreResolution?.breakdown ?? controller.previewScore;
    final comboLabel =
        controller.scoreResolution?.comboLabel ??
        controller.comboLabel(combo?.type);
    return RailPanel(
      color: AppColors.panelDeep,
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
                  color: AppColors.goldCoin,
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
                child: BigStatTile(
                  color: AppColors.blueAccent,
                  value: '${score?.chipsAfterAnomalies ?? 0}',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'x',
                  style: TextStyle(
                    color: AppColors.coral,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: BigStatTile(
                  color: AppColors.coralGradientEnd,
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

class CompactMetaRow extends StatelessWidget {
  const CompactMetaRow({
    super.key,
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
            color: AppColors.panelInfo,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.metaRowBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: CompactMetaCell(
                  label: 'Ante',
                  value: '$ante/8',
                  valueColor: AppColors.goldAmber,
                ),
              ),
              MetaDivider(compact: compact),
              Expanded(
                child: CompactMetaCell(
                  label: compact ? 'Rnd' : 'Round',
                  value: '$round',
                  valueColor: AppColors.goldAmber,
                ),
              ),
              MetaDivider(compact: compact),
              Expanded(
                child: CompactMetaCell(
                  label: compact ? 'Hand' : 'Hands',
                  value: '$hands',
                  valueColor: AppColors.blueHand,
                ),
              ),
              MetaDivider(compact: compact),
              Expanded(
                child: CompactMetaCell(
                  label: compact ? 'Disc' : 'Discards',
                  value: '$discards',
                  valueColor: AppColors.coralDeep,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MetaDivider extends StatelessWidget {
  const MetaDivider({super.key, this.compact = false});

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

/// Ante / Round / Hands / Discard 그룹 내부의 개별 수치 셀.
class CompactMetaCell extends StatelessWidget {
  const CompactMetaCell({
    super.key,
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

class CompactIconAction extends StatelessWidget {
  const CompactIconAction({
    super.key,
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
