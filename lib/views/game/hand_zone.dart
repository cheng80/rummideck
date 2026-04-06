import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/game_session_controller.dart';
import '../../logic/models/tile.dart';
import '../../utils/tile_utils.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';

class FanHandZone extends ConsumerStatefulWidget {
  const FanHandZone({super.key});

  @override
  ConsumerState<FanHandZone> createState() => _FanHandZoneState();
}

class _FanHandZoneState extends ConsumerState<FanHandZone> {
  static const Duration _drawFlightDuration = HandAnimationDurations.drawFlight;

  final List<DrawFlight> _flights = <DrawFlight>[];
  List<Tile?> _visibleSlots = <Tile?>[];
  List<Tile>? _pendingFinalHand;
  int _nextFlightId = 0;
  Size? _lastHandZoneSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _transitionToHand(List<Tile>.from(ref.read(gameSessionProvider).run.player.hand));
    });
  }

  List<Tile>? _lastActualHand;

  @override
  void didUpdateWidget(covariant FanHandZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncToActualHand();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _syncToActualHand() {
    final actual = List<Tile>.from(ref.read(gameSessionProvider).run.player.hand);
    final baseline = _pendingFinalHand ?? _visibleSlots.whereType<Tile>().toList();
    if (sameTileList(baseline, actual)) {
      return;
    }
    if (_flights.isNotEmpty) {
      _pendingFinalHand = actual;
      return;
    }
    _transitionToHand(actual);
  }

  void _transitionToHand(List<Tile> actualHand) {
    final handZoneSize = _lastHandZoneSize;
    if (actualHand.isEmpty) {
      setState(() {
        _visibleSlots = <Tile?>[];
        _pendingFinalHand = null;
        _flights.clear();
      });
      _setInteractionLockDeferred(false);
      return;
    }

    final existingCodes = _visibleSlots.whereType<Tile>().map((tile) => tile.code).toSet();
    final incomingEntries = <MapEntry<int, Tile>>[];
    for (var index = 0; index < actualHand.length; index++) {
      final tile = actualHand[index];
      if (!existingCodes.contains(tile.code)) {
        incomingEntries.add(MapEntry(index, tile));
      }
    }

    final nextVisibleSlots = <Tile?>[
      for (final tile in actualHand)
        existingCodes.contains(tile.code) ? tile : null,
    ];

    if (incomingEntries.isEmpty) {
      setState(() {
        _visibleSlots = nextVisibleSlots;
        _pendingFinalHand = null;
      });
      return;
    }

    if (handZoneSize == null) {
      setState(() {
        _visibleSlots = actualHand.map<Tile?>((tile) => tile).toList();
        _pendingFinalHand = null;
        _flights.clear();
      });
      _setInteractionLockDeferred(false);
      return;
    }

    final targetLayouts = _buildAllHandSlotLayouts(
      count: actualHand.length,
      zoneSize: handZoneSize,
    );

    setState(() {
      _visibleSlots = nextVisibleSlots;
      _pendingFinalHand = actualHand;
      _flights
        ..clear()
        ..addAll(
          [
            for (var order = 0; order < incomingEntries.length; order++)
              DrawFlight(
                id: _nextFlightId++,
                tile: incomingEntries[order].value,
                targetSlot: incomingEntries[order].key,
                targetLayout: targetLayouts[incomingEntries[order].key],
                delay: HandAnimationDurations.drawStagger * order,
              ),
          ],
        );
    });

    _setInteractionLockDeferred(true);
    final lastDelay = incomingEntries.length <= 1
        ? Duration.zero
        : Duration(milliseconds: (incomingEntries.length - 1) * 55);
    for (final flight in _flights) {
      unawaited(
        Future<void>.delayed(
          flight.delay + _drawFlightDuration + HandAnimationDurations.flightSettle,
          () => _completeFlight(flight),
        ),
      );
    }
    unawaited(
      Future<void>.delayed(
        lastDelay + _drawFlightDuration + HandAnimationDurations.flightSettle,
        () {
          if (!mounted) {
            return;
          }
          setState(() {
            _visibleSlots = (_pendingFinalHand ?? actualHand)
                .map<Tile?>((tile) => tile)
                .toList();
            _pendingFinalHand = null;
            _flights.clear();
          });
          _setInteractionLockDeferred(false);
          _syncToActualHand();
        },
      ),
    );
  }

  void _completeFlight(DrawFlight flight) {
    if (!mounted ||
        _pendingFinalHand == null ||
        flight.targetSlot >= _visibleSlots.length) {
      return;
    }
    setState(() {
      _visibleSlots[flight.targetSlot] = flight.tile;
      _flights.removeWhere((entry) => entry.id == flight.id);
    });
  }

  void _setInteractionLockDeferred(bool locked) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(gameSessionProvider).setInteractionLocked(locked);
    });
  }


  List<HandSlotLayout> _buildHandSlotLayouts({
    required int count,
    required double cardWidth,
    required double top,
    required double availableWidth,
  }) {
    if (count <= 0) {
      return const <HandSlotLayout>[];
    }

    final totalNaturalWidth = cardWidth * count;
    final overlap = count == 1
        ? 0.0
        : ((totalNaturalWidth - availableWidth + 28) / (count - 1)).clamp(
            0.0,
            cardWidth * 0.62,
          );
    final step = cardWidth - overlap;
    final usedWidth = step * (count - 1) + cardWidth;
    final startX = (availableWidth - usedWidth) / 2;

    return List<HandSlotLayout>.generate(
      count,
      (index) => HandSlotLayout(
        left: startX + (step * index),
        top: top,
        angle: _fanAngle(index, count),
        width: cardWidth,
      ),
    );
  }

  List<HandSlotLayout> _buildAllHandSlotLayouts({
    required int count,
    required Size zoneSize,
  }) {
    final rows = count > 8 ? 2 : 1;
    final rowOneCount = rows == 1 ? count : count.clamp(0, 8);
    final rowTwoCount = rows == 1 ? 0 : count - rowOneCount;
    final availableHeight = zoneSize.height - 28;
    final rowHeight = rows == 1
        ? availableHeight
        : (availableHeight - 18) / 2;
    final tileHeight = rowHeight.clamp(56.0, rows == 1 ? 92.0 : 74.0);
    final cardWidth = (tileHeight * 0.52).clamp(
      34.0,
      rows == 1 ? 52.0 : 42.0,
    );

    return <HandSlotLayout>[
      ..._buildHandSlotLayouts(
        count: rowOneCount,
        cardWidth: cardWidth,
        top: rows == 1 ? 14 : 6,
        availableWidth: zoneSize.width,
      ),
      ..._buildHandSlotLayouts(
        count: rowTwoCount,
        cardWidth: cardWidth,
        top: tileHeight + 18,
        availableWidth: zoneSize.width,
      ),
    ];
  }

  double _fanAngle(int index, int count) {
    if (count <= 1) {
      return 0;
    }
    final mid = (count - 1) / 2;
    return ((index - mid) / count) * 0.24;
  }

  Widget _buildHandStack({
    required BoxConstraints constraints,
    required List<Tile?> visibleSlots,
    required List<Tile> actualHand,
    required Set<int> selected,
    required bool selectionFull,
    required GameSessionController controller,
  }) {
    final handWidth = constraints.maxWidth;
    final count = visibleSlots.length;
    final rows = count > 8 ? 2 : 1;
    final rowOneCount = rows == 1 ? count : count.clamp(0, 8);
    final rowTwoCount = rows == 1 ? 0 : count - rowOneCount;
    final availableHeight = constraints.maxHeight - 28;
    final rowHeight = rows == 1
        ? availableHeight
        : (availableHeight - 18) / 2;
    final tileHeight = rowHeight.clamp(56.0, rows == 1 ? 92.0 : 74.0);
    final cardWidth = (tileHeight * 0.52).clamp(
      34.0,
      rows == 1 ? 52.0 : 42.0,
    );
    final rowOneLayouts = _buildHandSlotLayouts(
      count: rowOneCount,
      cardWidth: cardWidth,
      top: rows == 1 ? 14 : 6,
      availableWidth: handWidth,
    );
    final rowTwoLayouts = _buildHandSlotLayouts(
      count: rowTwoCount,
      cardWidth: cardWidth,
      top: tileHeight + 18,
      availableWidth: handWidth,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (rowOneCount > 0)
          HandRow(
            tiles: visibleSlots.take(rowOneCount).toList(),
            selectedIndices: selected,
            selectionFull: selectionFull,
            controller: controller,
            layouts: rowOneLayouts,
            indexOffset: 0,
            exiting: controller.isHandExitAnimating,
          ),
        if (rowTwoCount > 0)
          HandRow(
            tiles: visibleSlots.skip(rowOneCount).take(rowTwoCount).toList(),
            selectedIndices: selected,
            selectionFull: selectionFull,
            controller: controller,
            layouts: rowTwoLayouts,
            indexOffset: rowOneCount,
            exiting: controller.isHandExitAnimating,
          ),
        for (final flight in _flights)
          DrawFlightCard(
            key: ValueKey<int>(flight.id),
            flight: flight,
            zoneSize: constraints.biggest,
            duration: _drawFlightDuration,
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: HandFooterInfo(
            handCount: actualHand.length,
            drawPileCount: controller.drawPileCount,
            totalDeckSize: controller.totalDeckSize,
            discardPileCount: controller.discardPileCount,
            compact: constraints.maxWidth < 380,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);
    final actualHand = controller.run.player.hand;

    if (_lastActualHand == null || !sameTileList(_lastActualHand!, actualHand)) {
      _lastActualHand = List<Tile>.from(actualHand);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncToActualHand();
        }
      });
    }

    final visibleSlots = _visibleSlots;
    final selected = controller.selectedIndices.toSet();
    final selectionFull = controller.isSelectionFull;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(BattleSpacing.frameRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _lastHandZoneSize = constraints.biggest;
          if (actualHand.isEmpty && _flights.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildHandStack(
            constraints: constraints,
            visibleSlots: visibleSlots,
            actualHand: actualHand,
            selected: selected,
            selectionFull: selectionFull,
            controller: controller,
          );
        },
      ),
    );
  }
}

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
