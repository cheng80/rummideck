import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 우주 배경. 그라데이션 + 반짝이는 별.
class SpaceBg extends PositionComponent with HasGameReference {
  /// 별 개수
  static const int _starCount = 120;
  final Random _rng = Random();

  late List<_Star> _stars;
  late Paint _bgPaint;

  @override
  Future<void> onLoad() async {
    size = game.size;
    priority = -1;

    _bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF05051A),
          Color(0xFF0A0A2E),
          Color(0xFF12123A),
          Color(0xFF0A0A2E),
          Color(0xFF05051A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    _stars = List.generate(_starCount, (_) => _createStar());
  }

  /// 랜덤 별 생성 (위치, 크기, 색, 반짝임 속도)
  _Star _createStar() {
    // 반지름: 0.3 ~ 2.1
    final radius = _rng.nextDouble() * 1.8 + 0.3;
    return _Star(
      x: _rng.nextDouble() * size.x,
      y: _rng.nextDouble() * size.y,
      radius: radius,
      baseAlpha: _rng.nextDouble() * 0.5 + 0.3,
      twinkleSpeed: _rng.nextDouble() * 2.0 + 0.5,
      twinkleOffset: _rng.nextDouble() * 2 * pi,
      color: _starColor(),
    );
  }

  /// 별 색상 랜덤 선택 (흰 70%, 하늘 15%, 노랑 10%, 빨강 5%)
  Color _starColor() {
    final roll = _rng.nextDouble();
    if (roll < 0.7) return Colors.white;
    if (roll < 0.85) return const Color(0xFFAADDFF);
    if (roll < 0.95) return const Color(0xFFFFEEAA);
    return const Color(0xFFFFAAAA);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 각 별의 반짝임 시간 갱신
    for (final star in _stars) {
      star.time += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);

    for (final star in _stars) {
      // sin으로 반짝임 알파 계산
      final twinkle = sin(star.time * star.twinkleSpeed + star.twinkleOffset);
      final alpha = (star.baseAlpha + twinkle * 0.3).clamp(0.05, 1.0);
      final paint = Paint()..color = star.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(star.x, star.y), star.radius, paint);

      // 큰 별만 글로우 효과
      if (star.radius > 1.2) {
        final glowPaint = Paint()
          ..color = star.color.withValues(alpha: alpha * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(
          Offset(star.x, star.y),
          star.radius * 2.5,
          glowPaint,
        );
      }
    }
  }
}

/// 별 데이터 (위치, 크기, 반짝임 파라미터)
class _Star {
  final double x, y, radius, baseAlpha, twinkleSpeed, twinkleOffset;
  final Color color;
  /// 반짝임용 누적 시간
  double time = 0;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.baseAlpha,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
  });
}
