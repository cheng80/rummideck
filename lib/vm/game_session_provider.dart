import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_session_controller.dart';

final selectedSeedProvider = StateProvider<String>((ref) => 'MVP-001');

final gameSessionProvider = ChangeNotifierProvider.autoDispose<GameSessionController>(
  (ref) {
    final seed = ref.watch(selectedSeedProvider);
    return GameSessionController(seedText: seed);
  },
);
