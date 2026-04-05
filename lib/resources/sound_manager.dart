import 'package:flame_audio/flame_audio.dart';

import '../services/game_settings.dart';
import 'asset_paths.dart';

/// 앱 전역 사운드 관리. BGM 1종, BtnSnd 효과음.
class SoundManager {
  SoundManager._();

  static String? _currentBgm;

  /// BGM·효과음 미리 로드. 앱 시작 시 호출.
  static Future<void> preload() async {
    await Future.wait([
      FlameAudio.audioCache.load(AssetPaths.sfxBtnSnd),
      FlameAudio.audioCache.load(AssetPaths.bgmMain),
    ]);
  }

  /// BGM 재생. 음소거 시에는 _currentBgm만 갱신.
  static Future<void> playBgm(String path) async {
    if (_currentBgm == path) return;
    await stopBgm();
    _currentBgm = path;
    if (GameSettings.bgmMuted) return;
    await FlameAudio.bgm.play(path, volume: GameSettings.bgmVolume);
  }

  static Future<void> stopBgm() async {
    FlameAudio.bgm.stop();
    _currentBgm = null;
  }

  static void pauseBgm() => FlameAudio.bgm.pause();

  static void resumeBgm() {
    if (GameSettings.bgmMuted) return;
    if (_currentBgm == null) return;
    if (FlameAudio.bgm.isPlaying) return;
    FlameAudio.bgm.resume();
  }

  static Future<void> playBgmIfUnmuted() async {
    if (GameSettings.bgmMuted) return;
    if (_currentBgm == null) return;
    if (FlameAudio.bgm.isPlaying) return;
    await FlameAudio.bgm.play(_currentBgm!, volume: GameSettings.bgmVolume);
  }

  static void applyBgmVolume() {
    if (GameSettings.bgmMuted) return;
    FlameAudio.bgm.audioPlayer.setVolume(GameSettings.bgmVolume);
  }

  static void playSfx(String path) {
    if (GameSettings.sfxMuted) return;
    FlameAudio.play(path, volume: GameSettings.sfxVolume);
  }
}
