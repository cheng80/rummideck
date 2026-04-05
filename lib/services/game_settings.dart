import '../app_config.dart';
import '../utils/storage_helper.dart';

/// 게임 설정 저장/로드.
class GameSettings {
  GameSettings._();

  static const _defaultBgmVolume = 0.5;
  static const _defaultSfxVolume = 1.0;
  static const _defaultBgmMuted = false;
  static const _defaultSfxMuted = false;
  static const _defaultKeepScreenOn = true;

  static double get bgmVolume => StorageHelper.readDouble(
        StorageKeys.bgmVolume,
        defaultValue: _defaultBgmVolume,
      );

  static set bgmVolume(double v) {
    StorageHelper.write(StorageKeys.bgmVolume, v.clamp(0.0, 1.0));
  }

  static double get sfxVolume => StorageHelper.readDouble(
        StorageKeys.sfxVolume,
        defaultValue: _defaultSfxVolume,
      );

  static set sfxVolume(double v) {
    StorageHelper.write(StorageKeys.sfxVolume, v.clamp(0.0, 1.0));
  }

  static bool get bgmMuted => StorageHelper.readBool(
        StorageKeys.bgmMuted,
        defaultValue: _defaultBgmMuted,
      );

  static set bgmMuted(bool v) =>
      StorageHelper.write(StorageKeys.bgmMuted, v);

  static bool get sfxMuted => StorageHelper.readBool(
        StorageKeys.sfxMuted,
        defaultValue: _defaultSfxMuted,
      );

  static set sfxMuted(bool v) =>
      StorageHelper.write(StorageKeys.sfxMuted, v);

  static bool get keepScreenOn => StorageHelper.readBool(
        StorageKeys.keepScreenOn,
        defaultValue: _defaultKeepScreenOn,
      );

  static set keepScreenOn(bool v) =>
      StorageHelper.write(StorageKeys.keepScreenOn, v);

}
