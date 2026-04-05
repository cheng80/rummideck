import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../resources/sound_manager.dart';
import 'components/game_hud.dart';
import 'components/player.dart';
import 'components/space_bg.dart';

/// 샘플 게임: 화면 터치 또는 방향키/WASD로 플레이어 이동.
///
/// 구조: Backdrop + World + Viewport(HUD) 분리
class SampleGame extends FlameGame with TapCallbacks, KeyboardEvents {
  SampleGame({
    this.safeAreaTop = 0,
    this.safeAreaBottom = 0,
    this.safeAreaLeft = 0,
    this.safeAreaRight = 0,
    this.onPauseStateChanged,
  });

  /// Safe Area 여백 (상/하/좌/우)
  final double safeAreaTop;
  final double safeAreaBottom;
  final double safeAreaLeft;
  final double safeAreaRight;
  final ValueChanged<bool>? onPauseStateChanged;

  /// 게임 진행 여부
  bool isPlaying = false;

  late Player _player;
  GameHud? _hud;

  /// 현재 눌린 이동 키 목록
  final Set<LogicalKeyboardKey> _keysPressed = {};
  /// 키보드 이동 속도 (px/s)
  static const double _keyMoveSpeed = 280;

  Vector2 _initialPlayerPosition() => Vector2(
    (safeAreaLeft - safeAreaRight) / 2 + Player.radius,
    (safeAreaTop - safeAreaBottom) / 2 + Player.radius,
  );

  @override
  Future<void> onLoad() async {
    camera.backdrop.add(SpaceBg());
    _hud = GameHud(
      safeAreaTop: safeAreaTop,
      safeAreaBottom: safeAreaBottom,
      safeAreaLeft: safeAreaLeft,
      safeAreaRight: safeAreaRight,
    );
    camera.viewport.add(_hud!);
    _player = Player(
      position: _initialPlayerPosition(),
      safeAreaTop: safeAreaTop,
      safeAreaBottom: safeAreaBottom,
      safeAreaLeft: safeAreaLeft,
      safeAreaRight: safeAreaRight,
    );
    world.add(_player);
    isPlaying = true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying) return;
    // 화면 좌표를 카메라가 보는 world 좌표로 변환한다.
    final target = camera.globalToLocal(event.canvasPosition);
    _player.moveTo(target);
  }

  /// 이동에 사용하는 키 (방향키 + WASD)
  static final _moveKeys = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyD,
  };

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (isPlaying) pauseGame();
        return KeyEventResult.handled;
      }
      if (_moveKeys.contains(event.logicalKey)) {
        _keysPressed.add(event.logicalKey);
      }
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
    return KeyEventResult.ignored;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    // dt 기반 이동량 계산 (속도 * 시간)
    double dx = 0;
    double dy = 0;
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      dy -= _keyMoveSpeed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      dy += _keyMoveSpeed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      dx -= _keyMoveSpeed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      dx += _keyMoveSpeed * dt;
    }

    if (dx != 0 || dy != 0) {
      _player.moveByVelocity(dx, dy);
    }
  }

  /// 게임 일시정지
  void pauseGame() {
    if (!isPlaying) return;
    isPlaying = false;
    _keysPressed.clear();
    SoundManager.pauseBgm();
    pauseEngine();
    onPauseStateChanged?.call(true);
  }

  /// 게임 재개
  void resumeGame() {
    resumeEngine();
    isPlaying = true;
    onPauseStateChanged?.call(false);
  }
}
