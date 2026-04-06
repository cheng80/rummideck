import 'package:flutter/widgets.dart';

import '../app_config.dart';
import 'storage_helper.dart';

/// 앱 시작 시 [EasyLocalization]에 넘길 로케일을 결정한다.
///
/// - [StorageKeys.appLocale]에 `ko`/`en`이 있으면 그대로 사용.
/// - 없으면 기기 [Locale]과 지원 목록을 맞춘 뒤, 없으면 [fallback]을 쓴다.
Locale resolveStartupLocale({
  List<Locale> supportedLocales = const [Locale('ko'), Locale('en')],
  Locale fallback = const Locale('ko'),
}) {
  if (StorageHelper.hasData(StorageKeys.appLocale)) {
    final code = StorageHelper.readString(StorageKeys.appLocale);
    if (code == 'ko') return const Locale('ko');
    if (code == 'en') return const Locale('en');
  }

  final device = WidgetsBinding.instance.platformDispatcher.locale;
  for (final locale in supportedLocales) {
    if (locale.languageCode == device.languageCode) {
      return locale;
    }
  }
  return fallback;
}
