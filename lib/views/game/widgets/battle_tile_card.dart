import 'package:flutter/material.dart';

import '../../../logic/models/tile.dart';
import '../battle_theme.dart';

/// 럼미 타일 한 장의 공통 비주얼 (손패·보드·드로우 비행 등).
class BattleTileCard extends StatelessWidget {
  const BattleTileCard({
    super.key,
    required this.tile,
    required this.width,
    this.lifted = false,
    this.dimmed = false,
  });

  final Tile tile;
  final double width;
  final bool lifted;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.28;
    final color = _tileTint(tile.color);
    final opacity = dimmed ? 0.45 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.tileFaceTop.withValues(alpha: opacity),
            AppColors.tileFaceBottom.withValues(alpha: opacity),
          ],
        ),
        borderRadius: BorderRadius.circular(BattleSpacing.tileRadius),
        border: Border.all(
          color: lifted ? AppColors.tileBorderLifted : AppColors.tileBorderNormal,
          width: lifted ? 2.5 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dimmed ? 0.08 : 0.22),
            blurRadius: lifted ? 14 : 10,
            offset: Offset(0, lifted ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.08,
          vertical: width * 0.06,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: width * 0.12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${tile.number}',
                    style: TextStyle(
                      color: color.withValues(alpha: opacity),
                      fontSize: width * 0.72,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tileTint(TileColor color) {
    return switch (color) {
      TileColor.red => AppColors.tileRed,
      TileColor.blue => AppColors.tileBlue,
      TileColor.yellow => AppColors.tileYellow,
      TileColor.black => AppColors.tileBlack,
    };
  }
}
