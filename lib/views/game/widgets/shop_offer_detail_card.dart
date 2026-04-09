import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../battle_theme.dart';

/// 상점 오퍼 한 줄 카드 — 이름·희귀도·효과·가격·구매 버튼.
class ShopOfferDetailCard extends StatelessWidget {
  const ShopOfferDetailCard({
    super.key,
    required this.name,
    required this.rarityLabel,
    required this.effect,
    required this.notes,
    required this.price,
    required this.canBuy,
    required this.buyLabel,
    required this.onBuy,
  });

  final String name;
  final String rarityLabel;
  final String effect;
  final String? notes;
  final int price;
  final bool canBuy;
  final String buyLabel;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldCoin.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldCoin.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  rarityLabel,
                  style: const TextStyle(
                    color: AppColors.goldCoin,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (effect.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              effect,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('jesterNotesLabel'),
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              notes!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: AppColors.goldCoin.withValues(alpha: canBuy ? 1 : 0.45),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '$price G',
                style: TextStyle(
                  color: AppColors.goldCoin.withValues(alpha: canBuy ? 1 : 0.5),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onBuy,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  backgroundColor: AppColors.goldCta,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                ),
                child: Text(
                  buyLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
