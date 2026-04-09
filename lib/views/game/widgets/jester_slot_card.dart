import 'package:flutter/material.dart';

import '../../../logic/anomalies/anomaly.dart';
import '../battle_theme.dart';

/// 제스터 슬롯(빈 칸·보유 카드) 공통 카드 UI. 바·상점 등에서 재사용.
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
