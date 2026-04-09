import 'package:flutter/material.dart';

import '../../resources/asset_paths.dart';
import 'battle_theme.dart';
import 'game_common.dart';

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
