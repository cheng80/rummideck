import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/anomalies/anomaly.dart';
import '../../logic/jester/jester_anomaly.dart';
import '../../vm/game_session_provider.dart';
import 'battle_theme.dart';

class JesterBar extends ConsumerWidget {
  const JesterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameSessionProvider);
    final anomalies = controller.anomalies;
    return SizedBox(
      height: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jesters',
            style: TextStyle(
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
                      compact: true,
                      extendedSlot: index == 4,
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
}

class JesterSlotCard extends StatelessWidget {
  const JesterSlotCard({
    super.key,
    required this.anomaly,
    required this.compact,
    this.extendedSlot = false,
  });

  final Anomaly? anomaly;
  final bool compact;
  final bool extendedSlot;

  @override
  Widget build(BuildContext context) {
    final emptyColors = extendedSlot
        ? [AppColors.jesterExtendedTop, AppColors.jesterExtendedBottom]
        : [AppColors.jesterEmptyTop, AppColors.jesterEmptyBottom];
    final a = anomaly;
    final filled = a != null;
    final rarityLabel = filled ? _rarityLabel(a.rarity) : null;

    return DecoratedBox(
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
                    rarityLabel!,
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
                        a.name.isNotEmpty
                            ? a.name[0].toUpperCase()
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
                    a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.jesterTextName,
                      fontSize: compact ? 8 : 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_effectLabel(a) != null)
                    Text(
                      _effectLabel(a)!,
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
  }

  String _rarityLabel(AnomalyRarity rarity) {
    return switch (rarity) {
      AnomalyRarity.common => 'COMMON',
      AnomalyRarity.uncommon => 'UNCOMMON',
      AnomalyRarity.rare => 'RARE',
      AnomalyRarity.legendary => 'LEGENDARY',
    };
  }

  String? _effectLabel(Anomaly anomaly) {
    if (anomaly is JesterAnomaly) {
      return anomaly.effectText;
    }
    return null;
  }
}
