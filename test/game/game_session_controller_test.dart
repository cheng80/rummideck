import 'package:flutter_test/flutter_test.dart';
import 'package:rummideck/game/game_session_controller.dart';
import 'package:rummideck/logic/models/tile.dart';

void main() {
  group('GameSessionController', () {
    test('초기 세션은 seed와 시작 로그를 가진다', () {
      final controller = GameSessionController(seedText: 'MVP-001');

      expect(controller.run.seedText, 'MVP-001');
      expect(controller.logs.first.message, '새 런 시작');
      expect(controller.run.player.hand, hasLength(8));
      expect(controller.handSortMode, HandSortMode.rank);
      expect(_isSortedByRank(controller.run.player.hand), isTrue);
    });

    test('버리기 후 로그가 추가된다', () {
      final controller = GameSessionController(seedText: 'SUBMIT-TEST');

      controller.toggleTileSelection(0);
      controller.toggleTileSelection(1);
      controller.discardSelection();

      expect(controller.logs.first.message, contains('보충'));
    });

    test('재시작 시 같은 seed로 1스테이지부터 다시 시작한다', () {
      final controller = GameSessionController(seedText: 'RESET-TEST');

      controller.restartRun();

      expect(controller.run.stage?.stageIndex, 1);
      expect(controller.run.seedText, 'RESET-TEST');
      expect(controller.logs.first.message, '새 런을 시작했습니다.');
    });

    test('초기 세션은 52장 기준 덱 잔량을 가진다', () {
      final controller = GameSessionController(seedText: 'DECK-COUNT-TEST');

      expect(controller.totalDeckSize, 52);
      expect(controller.run.player.hand, hasLength(8));
      expect(controller.drawPileCount, 44);
    });

    test('랭크 정렬은 숫자 우선, 같으면 색상 순으로 정렬한다', () {
      final controller = GameSessionController(seedText: 'SORT-RANK-TEST');
      controller.run.player.hand
        ..clear()
        ..addAll(const [
          Tile(color: TileColor.black, number: 9),
          Tile(color: TileColor.red, number: 3),
          Tile(color: TileColor.blue, number: 3),
          Tile(color: TileColor.yellow, number: 1),
        ]);

      controller.sortHandByRank();

      expect(controller.run.player.hand.map((tile) => tile.code).toList(), [
        'Y1',
        'R3',
        'B3',
        'K9',
      ]);
    });

    test('수트 정렬은 색상 우선, 같으면 숫자 순으로 정렬한다', () {
      final controller = GameSessionController(seedText: 'SORT-SUIT-TEST');
      controller.run.player.hand
        ..clear()
        ..addAll(const [
          Tile(color: TileColor.black, number: 2),
          Tile(color: TileColor.red, number: 9),
          Tile(color: TileColor.red, number: 1),
          Tile(color: TileColor.blue, number: 3),
          Tile(color: TileColor.yellow, number: 5),
        ]);

      controller.sortHandBySuit();

      expect(controller.run.player.hand.map((tile) => tile.code).toList(), [
        'R1',
        'R9',
        'B3',
        'Y5',
        'K2',
      ]);
    });

    test('버리기 후에도 현재 정렬 모드가 자동 재적용된다', () {
      final controller = GameSessionController(seedText: 'AUTO-SORT-SUIT-TEST');

      controller.sortHandBySuit();
      controller.toggleTileSelection(0);
      controller.toggleTileSelection(1);
      controller.discardSelection();

      expect(controller.handSortMode, HandSortMode.suit);
      expect(_isSortedBySuit(controller.run.player.hand), isTrue);
    });

    test('재시작하면 기본 랭크 정렬로 다시 시작한다', () {
      final controller = GameSessionController(seedText: 'RESET-SORT-TEST');

      controller.sortHandBySuit();
      controller.restartRun();

      expect(controller.handSortMode, HandSortMode.rank);
      expect(_isSortedByRank(controller.run.player.hand), isTrue);
    });

    test('선택 타일은 최대 5장까지만 허용된다', () {
      final controller = GameSessionController(seedText: 'MAX-SELECT-TEST');

      for (var index = 0; index < 5; index++) {
        controller.toggleTileSelection(index);
      }
      controller.toggleTileSelection(5);

      expect(controller.selectedIndices, hasLength(5));
      expect(controller.statusMessage, '타일은 최대 5장까지 선택할 수 있습니다.');
    });
  });
}

bool _isSortedByRank(List<Tile> hand) {
  for (var index = 1; index < hand.length; index++) {
    final previous = hand[index - 1];
    final current = hand[index];
    if (previous.number > current.number) {
      return false;
    }
    if (previous.number == current.number &&
        previous.color.sortOrder > current.color.sortOrder) {
      return false;
    }
  }
  return true;
}

bool _isSortedBySuit(List<Tile> hand) {
  for (var index = 1; index < hand.length; index++) {
    final previous = hand[index - 1];
    final current = hand[index];
    if (previous.color.sortOrder > current.color.sortOrder) {
      return false;
    }
    if (previous.color.sortOrder == current.color.sortOrder &&
        previous.number > current.number) {
      return false;
    }
  }
  return true;
}
