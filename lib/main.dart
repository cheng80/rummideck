import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'resources/sound_manager.dart';
import 'services/game_settings.dart';
import 'utils/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageHelper.init();
  await SoundManager.preload();
  _applyKeepScreenOn();
  runApp(const App());
}

void _applyKeepScreenOn() {
  if (GameSettings.keepScreenOn) {
    WakelockPlus.enable();
  } else {
    WakelockPlus.disable();
  }
}
