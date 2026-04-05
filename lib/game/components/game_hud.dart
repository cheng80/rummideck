import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../sample_game.dart';

/// HUD. 일시정지 버튼만 표시.
class GameHud extends PositionComponent with HasGameReference<SampleGame> {
  GameHud({
    this.safeAreaTop = 0,
    this.safeAreaBottom = 0,
    this.safeAreaLeft = 0,
    this.safeAreaRight = 0,
  });

  /// Safe Area 여백
  final double safeAreaTop;
  final double safeAreaBottom;
  final double safeAreaLeft;
  final double safeAreaRight;

  @override
  Future<void> onLoad() async {
    priority = 10;
    final s = game.size;
    // 버튼 크기: 화면 너비의 14%
    final btnSize = s.x * 0.14;
    // 버튼 세로 위치: 상단 Safe Area + 60px
    final cy = safeAreaTop + 60;

    add(
      _PauseButton(
        position: Vector2(12, cy - btnSize / 2),
        size: Vector2.all(btnSize),
      ),
    );
    add(_SafeAreaDebugRect());
  }
}

/// 디버그: Safe Area 외곽 경계를 라인 사각형으로 표시.
class _SafeAreaDebugRect extends PositionComponent
    with HasGameReference<SampleGame> {
  @override
  void render(Canvas canvas) {
    final s = game.size;
    // Safe Area 경계 좌표 (좌/상/우/하)
    final left = game.safeAreaLeft;
    final top = game.safeAreaTop;
    final right = s.x - game.safeAreaRight;
    final bottom = s.y - game.safeAreaBottom;

    final rect = Rect.fromLTRB(left, top, right, bottom);
    final paint = Paint()
      ..color = Colors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, paint);

    final center = Offset((left + right) / 2, (top + bottom) / 2);
    final centerPaint = Paint()..color = const Color(0xFFFF5252);
    canvas.drawCircle(center, 4, centerPaint);

    final crossPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.9)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      crossPaint,
    );
  }
}

class _PauseButton extends PositionComponent
    with TapCallbacks, HasGameReference<SampleGame> {
  _PauseButton({required super.position, required super.size})
      : super(anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    // 둥근 모서리 배경
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.x * 0.25),
    );
    canvas.drawRRect(
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );

    // 일시정지 아이콘 막대 크기 및 간격
    final barW = size.x * 0.14;
    final barH = size.y * 0.45;
    final gap = size.x * 0.12;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW * 0.3),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW * 0.3),
      ),
      paint,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    // 탭 시 게임 일시정지
    game.pauseGame();
  }
}
