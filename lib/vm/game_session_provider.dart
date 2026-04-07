import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_session_controller.dart';

final selectedSeedProvider = StateProvider<String>((ref) => 'MVP-001');

/// 디버그: 타이틀에서 켠 뒤 게임 진입 시 [GameSessionController.debugBootstrapPlaybookToStage] 실행.
final playbookDebugStartProvider = StateProvider<bool>((ref) => false);

final gameSessionProvider = ChangeNotifierProvider.autoDispose<GameSessionController>(
  (ref) {
    final seed = ref.watch(selectedSeedProvider);
    return GameSessionController(seedText: seed);
  },
);
