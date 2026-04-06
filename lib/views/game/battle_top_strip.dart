import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../resources/asset_paths.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'game_common.dart';

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

class BlindHeaderCard extends StatelessWidget {
  const BlindHeaderCard({
    super.key,
    required this.blindLabel,
    required this.targetScore,
    required this.rewardLabel,
  });

  final String blindLabel;
  final int targetScore;
  final String rewardLabel;

  static Color _blindBadgeColor(String label) => switch (label) {
    'Small Blind' => AppColors.blindSmall,
    'Big Blind'   => AppColors.blindBig,
    _             => AppColors.blindBoss,
  };

  Widget _blindBadge({
    required double size,
    required bool tiny,
  }) {
    final shortBlind = switch (blindLabel) {
      'Small Blind' => 'SMALL\nBLIND',
      'Big Blind'   => 'BIG\nBLIND',
      _             => 'BOSS\nBLIND',
    };
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _blindBadgeColor(blindLabel),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            shortBlind,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: tiny ? 8 : 10,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rewardBadge({
    required double labelFont,
    required double rewardFont,
    required bool tiny,
  }) {
    return Align(
      alignment: Alignment.center,
      child: SubPanelSurface(
        alpha: 0.24,
        padding: EdgeInsets.symmetric(
          horizontal: tiny ? 9 : 12,
          vertical: tiny ? 5 : 6,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reward ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: labelFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                rewardLabel,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: rewardFont,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 120 || constraints.maxHeight < 130;
        final tiny = constraints.maxWidth < 80 || constraints.maxHeight < 90;
        final titleFont = tiny ? 9.0 : (compact ? 12.0 : 16.0);
        final labelFont = tiny ? 8.0 : (compact ? 9.0 : 11.0);
        final valueFont = tiny ? 18.0 : (compact ? 22.0 : 30.0);
        final rewardFont = tiny ? 14.0 : (compact ? 17.0 : 22.0);
        final badgeSize = tiny ? 38.0 : (compact ? 48.0 : 60.0);

        return Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.panelDark,
                  borderRadius: BorderRadius.circular(BattleSpacing.panelRadius),
                  border: Border.all(color: AppColors.goldBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: compact ? 128 : 164,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blindLabel,
                            style: TextStyle(
                              fontFamily: AssetPaths.fontAngduIpsul140,
                              color: Colors.white,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: tiny ? 4 : 8),
                          _blindBadge(size: badgeSize, tiny: tiny),
                          SizedBox(height: tiny ? 4 : 8),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Score at least',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: labelFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: tiny ? 2 : 4),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              compactNumber(targetScore),
                              style: TextStyle(
                                color: AppColors.coralWarm,
                                fontSize: valueFont,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          SizedBox(height: tiny ? 4 : 6),
                          _rewardBadge(
                            labelFont: labelFont,
                            rewardFont: rewardFont,
                            tiny: tiny,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
