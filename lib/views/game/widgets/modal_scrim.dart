import 'package:flutter/material.dart';

/// 전체 화면 어두운 배경 + 가운데 정렬 자식(게임 오버·런 완료·일시정지 등).
class ModalScrim extends StatelessWidget {
  const ModalScrim({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(12),
      child: Center(child: child),
    );
  }
}
