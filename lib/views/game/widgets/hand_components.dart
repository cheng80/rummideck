import 'package:flutter/material.dart';

import '../../../game/game_session_controller.dart';
import '../../../logic/models/tile.dart';
import 'battle_tile_card.dart';

/// 드로우 비행 애니메이션 데이터.
class DrawFlight {
  const DrawFlight({
    required this.id,
    required this.tile,
    required this.targetSlot,
    required this.targetLayout,
    required this.delay,
  });

  final int id;
  final Tile tile;
  final int targetSlot;
  final HandSlotLayout targetLayout;
  final Duration delay;
}

/// 팬 손패 슬롯 한 장의 위치·크기·회전.
class HandSlotLayout {
  const HandSlotLayout({
    required this.left,
    required this.top,
    required this.angle,
    required this.width,
  });

  final double left;
  final double top;
  final double angle;
  final double width;
}

/// 덱·손패·디스카드 잔량 표시줄.
class HandFooterInfo extends StatelessWidget {
  const HandFooterInfo({
    super.key,
    required this.handCount,
    required this.drawPileCount,
    required this.totalDeckSize,
    required this.discardPileCount,
    required this.compact,
  });

  final int handCount;
  final int drawPileCount;
  final int totalDeckSize;
  final int discardPileCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.85),
      fontSize: compact ? 10 : 12,
      fontWeight: FontWeight.w800,
      height: 1,
    );
    final secondaryStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.68),
      fontSize: compact ? 9 : 11,
      fontWeight: FontWeight.w700,
      height: 1,
    );

    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Discard $discardPileCount',
              style: secondaryStyle,
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Center(
            child: Text('Hand $handCount/16', style: labelStyle),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Center(
            child: Text('Deck $drawPileCount/$totalDeckSize', style: labelStyle),
          ),
        ),
      ],
    );
  }
}

/// 드로우 비행 카드 애니메이션.
class DrawFlightCard extends StatelessWidget {
  const DrawFlightCard({
    super.key,
    required this.flight,
    required this.zoneSize,
    required this.duration,
  });

  final DrawFlight flight;
  final Size zoneSize;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final target = Offset(
      flight.targetLayout.left,
      flight.targetLayout.top + 10,
    );
    final begin = Offset(zoneSize.width + 26, zoneSize.height * 0.54);
    final totalDuration = flight.delay + duration;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: totalDuration,
        curve: Curves.linear,
        builder: (context, value, child) {
          final delayedValue =
              ((value * totalDuration.inMilliseconds) -
                      flight.delay.inMilliseconds) /
                  duration.inMilliseconds;
          final normalized = delayedValue.clamp(0.0, 1.0);
          final progress = Curves.easeOutCubic.transform(normalized);
          final current = Offset.lerp(begin, target, progress)!;
          final liftArc = (1 - (progress - 0.5).abs() * 2) * 14;

          return Stack(
            children: [
              Positioned(
                left: current.dx,
                top: current.dy - liftArc,
                child: Opacity(
                  opacity: normalized <= 0 ? 0 : 1,
                  child: Transform.rotate(
                    angle: (-0.14 * (1 - progress)) +
                        (flight.targetLayout.angle * progress),
                    child: BattleTileCard(
                      tile: flight.tile,
                      width: flight.targetLayout.width,
                      lifted: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 손패 한 줄(슬롯 목록) 렌더링.
class HandRow extends StatelessWidget {
  const HandRow({
    super.key,
    required this.tiles,
    required this.selectedIndices,
    required this.selectionFull,
    required this.controller,
    required this.layouts,
    required this.indexOffset,
    required this.exiting,
  });

  final List<Tile?> tiles;
  final Set<int> selectedIndices;
  final bool selectionFull;
  final GameSessionController controller;
  final List<HandSlotLayout> layouts;
  final int indexOffset;
  final bool exiting;

  @override
  Widget build(BuildContext context) {
    final count = tiles.length;
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var localIndex = 0; localIndex < count; localIndex++)
          if (tiles[localIndex] != null)
            Positioned(
              left: layouts[localIndex].left,
              top:
                  layouts[localIndex].top +
                  (selectedIndices.contains(indexOffset + localIndex) ? 0 : 10),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInCubic,
                offset: exiting ? const Offset(0, 1.5) : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  opacity: exiting ? 0 : 1,
                  child: Transform.rotate(
                    angle: layouts[localIndex].angle,
                    child: GestureDetector(
                      onTap: () =>
                          controller.toggleTileSelection(indexOffset + localIndex),
                      child: BattleTileCard(
                        tile: tiles[localIndex]!,
                        width: layouts[localIndex].width,
                        lifted: selectedIndices.contains(indexOffset + localIndex),
                        dimmed:
                            selectionFull &&
                            !selectedIndices.contains(indexOffset + localIndex),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
