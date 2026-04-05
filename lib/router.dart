import 'package:go_router/go_router.dart';

import 'app_config.dart';
import 'views/game_view.dart';
import 'views/setting_view.dart';
import 'views/title_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.title,
  routes: [
    GoRoute(
      path: RoutePaths.title,
      builder: (context, state) => const TitleView(),
    ),
    GoRoute(
      path: RoutePaths.game,
      builder: (context, state) => const GameView(),
    ),
    GoRoute(
      path: RoutePaths.setting,
      builder: (context, state) => const SettingView(),
    ),
  ],
);
