import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'router.dart';
import 'utils/storage_helper.dart';

/// 앱의 루트 위젯.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // child가 null이면 라우트가 비어 보이므로 shrink로 대체하지 않는다(위젯 테스트 포함).
      builder: (context, child) => _LocaleSync(child: child!),
    );
  }
}

/// GetStorage에 저장된 언어가 있으면 첫 프레임 직후 [context.setLocale]로 맞춘다.
///
/// easy_localization 내부에 남은 예전 SharedPreferences 로케일 때문에
/// [EasyLocalization]의 [startLocale]이 무시되는 경우가 있어, 저장값은 여기서 보정한다.
class _LocaleSync extends StatefulWidget {
  const _LocaleSync({required this.child});

  final Widget child;

  @override
  State<_LocaleSync> createState() => _LocaleSyncState();
}

class _LocaleSyncState extends State<_LocaleSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applySavedLocale());
  }

  Future<void> _applySavedLocale() async {
    if (!mounted) return;
    if (!StorageHelper.hasData(StorageKeys.appLocale)) return;
    final code = StorageHelper.readString(StorageKeys.appLocale);
    if (code != 'ko' && code != 'en') return;
    if (!mounted) return;
    if (context.locale.languageCode == code) return;
    await context.setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
