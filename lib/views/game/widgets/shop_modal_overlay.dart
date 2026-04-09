import 'package:flutter/material.dart';

import '../battle_theme.dart';
import 'glass_panel.dart';

/// 상점 전체 화면 덮개 — 딤 + SafeArea + GlassPanel.
class ShopModalOverlay extends StatelessWidget {
  const ShopModalOverlay({
    super.key,
    required this.topInset,
    required this.child,
  });

  final double topInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.52)),
        Positioned(
          left: 6,
          right: 6,
          top: topInset,
          bottom: 6,
          child: SafeArea(
            top: topInset == 0,
            bottom: false,
            left: false,
            right: false,
            minimum: const EdgeInsets.only(top: 4),
            child: GlassPanel(
              color: AppColors.modalBg,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
