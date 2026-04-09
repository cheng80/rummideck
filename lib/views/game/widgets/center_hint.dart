import 'package:flutter/material.dart';

/// 타일 미선택 시 중앙 안내 문구.
class CenterHint extends StatelessWidget {
  const CenterHint({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxHeight < 84;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Colors.white54,
              size: tight ? 22 : (compact ? 28 : 38),
            ),
            SizedBox(height: tight ? 4 : (compact ? 8 : 10)),
            Text(
              compact ? '손패 타일 선택\n중앙에 놓기' : '손패에서 타일을 선택해\n중앙 플레이 존에 올리세요',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: tight ? 11 : (compact ? 13 : 16),
                fontWeight: FontWeight.w700,
                height: tight ? 1.1 : 1.25,
              ),
            ),
          ],
        );
      },
    );
  }
}
