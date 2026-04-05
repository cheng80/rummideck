/// 앱 전반에서 사용하는 상수 모음.
class AppConfig {
  AppConfig._();

  static const String appTitle = 'Rummideck';
  static const String gameTitle = 'Rummi';
  static const String gameTitleSub = 'deck';
  static const String gameSubtitle = '화면을 터치하면 플레이어가 이동합니다';
}

/// GetStorage 키 상수.
class StorageKeys {
  StorageKeys._();

  static const String bgmVolume = 'bgm_volume';
  static const String sfxVolume = 'sfx_volume';
  static const String bgmMuted = 'bgm_muted';
  static const String sfxMuted = 'sfx_muted';
  static const String keepScreenOn = 'keep_screen_on';
}

class RoutePaths {
  RoutePaths._();

  static const String title = '/';
  static const String game = '/game';
  static const String setting = '/setting';
}
