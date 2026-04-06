import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'resources/sound_manager.dart';
import 'services/game_settings.dart';
import 'utils/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await StorageHelper.init();
  await SoundManager.preload();
  _applyKeepScreenOn();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko'),
      saveLocale: true,
      child: const App(),
    ),
  );
}

/// 저장된 설정에 따라 화면 꺼짐 방지 적용.
void _applyKeepScreenOn() {
  if (GameSettings.keepScreenOn) {
    WakelockPlus.enable();
  } else {
    WakelockPlus.disable();
  }
}
