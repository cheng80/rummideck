import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// 원형 플레이어. anchor=center, position=원의 중심.
///
/// 부모: World (좌표 0,0=화면 중앙)
/// 경계: 중심점이 노란선(Safe Area)까지만 이동하도록 제한

class Player extends PositionComponent with HasGameReference<FlameGame> {
  Player({
    required super.position,
    this.safeAreaTop = 0,
    this.safeAreaBottom = 0,
    this.safeAreaLeft = 0,
    this.safeAreaRight = 0,
  }) : super(size: Vector2.all(_radius * 2), anchor: Anchor.center);

  /// Safe Area 여백 (상/하/좌/우)
  final double safeAreaTop;
  final double safeAreaBottom;
  final double safeAreaLeft;
  final double safeAreaRight;

  /// 원 반지름
  static const double _radius = 24;
  static const double radius = _radius;
  /// MoveToEffect 애니메이션 시간(초)
  static const double _moveDuration = 0.25;

  /// 이동 가능 영역 최소 좌표 (좌상단)
  /// 현재 템플릿 좌표계/렌더 기준에서 중심점이 시각적으로
  /// Safe Area 선까지 가도록 반지름만큼 보정한다.
  Vector2 get _boundsMin => Vector2(
    -game.size.x / 2 + safeAreaLeft + _radius,
    -game.size.y / 2 + safeAreaTop + _radius,
  );
  /// 이동 가능 영역 최대 좌표 (우하단)
  Vector2 get _boundsMax => Vector2(
    game.size.x / 2 - safeAreaRight + _radius,
    game.size.y / 2 - safeAreaBottom + _radius,
  );

  /// 디버그용 경계값
  (Vector2 min, Vector2 max) get debugBounds => (_boundsMin, _boundsMax);

  /// 좌표를 이동 가능 영역 내로 제한
  Vector2 _clamp(Vector2 p) => Vector2(
    p.x.clamp(_boundsMin.x, _boundsMax.x),
    p.y.clamp(_boundsMin.y, _boundsMax.y),
  );

  /// 지정 좌표로 부드럽게 이동 (MoveToEffect)
  void moveTo(Vector2 target) {
    add(
      MoveToEffect(_clamp(target), EffectController(duration: _moveDuration)),
    );
  }

  /// 속도(dx, dy)만큼 즉시 이동 (키보드용)
  void moveByVelocity(double dx, double dy) {
    removeAll(children.whereType<MoveToEffect>());
    position = _clamp(position + Vector2(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    // 그라데이션 원 (청록→초록)
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3CAEE0), Color(0xFF2DB872)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: _radius));
    canvas.drawCircle(Offset.zero, _radius, paint);

    // 흰색 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, _radius, borderPaint);

    // 중심점 디버그 마커
    final centerPaint = Paint()..color = const Color(0xFFFF5252);
    canvas.drawCircle(Offset.zero, 3, centerPaint);

    final crossPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.9)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-8, 0), const Offset(8, 0), crossPaint);
    canvas.drawLine(const Offset(0, -8), const Offset(0, 8), crossPaint);
  }
}
