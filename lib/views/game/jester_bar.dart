import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/anomalies/anomaly.dart';
import '../../resources/jester_translation_scope.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';
import 'jester_detail_sheet.dart';
import 'jester_ui_strings.dart';

class JesterBar extends ConsumerStatefulWidget {
  const JesterBar({super.key});

  @override
  ConsumerState<JesterBar> createState() => _JesterBarState();
}

class _JesterBarState extends ConsumerState<JesterBar> {
  OverlayEntry? _sellOverlay;

  @override
  void dispose() {
    _removeSellOverlay();
    super.dispose();
  }

  void _removeSellOverlay() {
    _sellOverlay?.remove();
    _sellOverlay = null;
  }

  void _insertSellOverlay() {
    if (_sellOverlay != null) {
      return;
    }
    final overlayState = Overlay.of(context);

    _sellOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              top: MediaQuery.paddingOf(ctx).top + 6,
              right: 12,
              child: Consumer(
                builder: (context, ref, _) {
                  final anomalies = ref.watch(gameSessionProvider).anomalies;
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (_) => true,
                    onAcceptWithDetails: (details) {
                      ref.read(gameSessionProvider).sellJester(details.data);
                      _removeSellOverlay();
                    },
                    builder: (context, candidate, _) {
                      final idx = candidate.isNotEmpty ? candidate.first : null;
                      final gold = (idx != null &&
                              idx >= 0 &&
                              idx < anomalies.length)
                          ? jesterSellGold(anomalies[idx])
                          : null;
                      final highlight = candidate.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1410),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: highlight
                                ? AppColors.goldCoin
                                : const Color(0xFFC9A227),
                            width: highlight ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          gold != null
                              ? context.tr(
                                  'jesterSellHint',
                                  namedArgs: {'gold': '$gold'},
                                )
                              : context.tr('jesterSellDropHere'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    overlayState.insert(_sellOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameSessionProvider);
    final anomalies = controller.anomalies;
    final t = JesterTranslationScope.of(context);
    final canInteract =
        controller.run.isStageActive && !controller.isInteractionLocked;

    return SizedBox(
      height: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('jesters'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                for (var index = 0; index < 5; index++) ...[
                  if (index > 0) const SizedBox(width: 6),
                  Expanded(
                    child: JesterSlotCard(
                      anomaly: index < anomalies.length
                          ? anomalies[index]
                          : null,
                      slotIndex: index,
                      compact: true,
                      extendedSlot: index == 4,
                      displayName: index < anomalies.length
                          ? localizedJesterName(t, anomalies[index])
                          : '',
                      effectText: index < anomalies.length
                          ? localizedJesterEffect(t, anomalies[index])
                          : '',
                      rarityLabel: (AnomalyRarity r) =>
                          _rarityLabel(context, r),
                      canInteract: canInteract,
                      onOpenDetail: index < anomalies.length
                          ? () => showJesterDetailSheet(
                              context,
                              name: localizedJesterName(t, anomalies[index]),
                              effect: localizedJesterEffect(t, anomalies[index]),
                              rarityText: _rarityLabel(
                                context,
                                anomalies[index].rarity,
                              ),
                              notes: localizedJesterNotes(t, anomalies[index]),
                            )
                          : null,
                      onDragStarted: canInteract && index < anomalies.length
                          ? _insertSellOverlay
                          : null,
                      onDragEnd: canInteract && index < anomalies.length
                          ? _removeSellOverlay
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rarityLabel(BuildContext context, AnomalyRarity rarity) {
    return switch (rarity) {
      AnomalyRarity.common => context.tr('rarityCommon'),
      AnomalyRarity.uncommon => context.tr('rarityUncommon'),
      AnomalyRarity.rare => context.tr('rarityRare'),
      AnomalyRarity.legendary => context.tr('rarityLegendary'),
    };
  }
}

class JesterSlotCard extends StatelessWidget {
  const JesterSlotCard({
    super.key,
    required this.anomaly,
    required this.slotIndex,
    required this.compact,
    required this.extendedSlot,
    required this.displayName,
    required this.effectText,
    required this.rarityLabel,
    required this.canInteract,
    required this.onOpenDetail,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  final Anomaly? anomaly;
  final int slotIndex;
  final bool compact;
  final bool extendedSlot;
  final String displayName;
  final String effectText;
  final String Function(AnomalyRarity rarity) rarityLabel;
  final bool canInteract;
  final VoidCallback? onOpenDetail;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final emptyColors = extendedSlot
        ? [AppColors.jesterExtendedTop, AppColors.jesterExtendedBottom]
        : [AppColors.jesterEmptyTop, AppColors.jesterEmptyBottom];
    final a = anomaly;
    final filled = a != null;
    final rarityText = filled ? rarityLabel(a.rarity) : null;

    final inner = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: filled
              ? [AppColors.jesterFilledTop, AppColors.jesterFilledBottom]
              : emptyColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? AppColors.jesterFilledBorder : Colors.white24,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 10),
        child: filled
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rarityText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.jesterTextDark,
                      fontSize: compact ? 7 : 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName.characters.first
                            : '?',
                        style: TextStyle(
                          color: AppColors.jesterTextBody,
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.jesterTextName,
                      fontSize: compact ? 8 : 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (effectText.isNotEmpty)
                    Text(
                      effectText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.jesterTextDark.withValues(alpha: 0.7),
                        fontSize: compact ? 6 : 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extendedSlot ? 'EXT' : 'JESTER',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: compact ? 8 : 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Icon(
                      extendedSlot
                          ? Icons.add_box_outlined
                          : Icons.add_card_rounded,
                      color: Colors.white30,
                      size: compact ? 22 : 28,
                    ),
                  ),
                  const Spacer(),
                  if (extendedSlot)
                    Text(
                      '5th',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: compact ? 8 : 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
      ),
    );

    if (!filled || !canInteract) {
      return inner;
    }

    Widget body = GestureDetector(
      onTap: onOpenDetail,
      behavior: HitTestBehavior.opaque,
      child: inner,
    );

    if (onDragStarted == null || onDragEnd == null) {
      return body;
    }

    return LongPressDraggable<int>(
      data: slotIndex,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: compact ? 72 : 84,
          height: compact ? 96 : 108,
          child: inner,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: inner,
      ),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd!(),
      child: body,
    );
  }
}
