# UI 위젯 분리 순차 플랜

> **보관**: 완료 스냅샷. 진행 안내는 [`docs/refactoring.md`](../../refactoring.md).  
> **기준**: `AGENTS.md` 프롬프트 구조(Goal / Context / Constraints / Done when)  
> **원칙**: `refactoring-plan.md`(동일 폴더) — 작은 단위 변경, 실행 가능한 코드 유지, UI/Logic 분리  
> **금지**: 게임 규칙·점수·RNG 로직 변경 없음(표현/파일 위치만)

---

## 공통 Context

- **위치**: `lib/views/game/` 및 하위 `widgets/`
- **이미 분리됨**: `widgets/battle_tile_card.dart`, `widgets/jester_slot_card.dart`
- **검증**: 매 단계 끝 `dart analyze lib/views/...`, `flutter test` (최소 `test/game/`)

---

## Phase 1 — 모달 표면: `GlassPanel`, `ModalScrim` ✅

### Done when
- [x] `lib/views/game/widgets/glass_panel.dart`, `modal_scrim.dart` 추가
- [x] `game_modals.dart`, `game_view.dart`에서 정의 제거 후 import만 변경
- [x] `dart analyze` 통과

---

## Phase 2 — 요약 칩: `SummaryChip` ✅

### Done when
- [x] `lib/views/game/widgets/summary_chip.dart`
- [x] `game_modals.dart`에서 클래스 제거 및 import
- [x] analyze 통과

---

## Phase 3 — 상점 오퍼 카드: `ShopOfferDetailCard` ✅

### Done when
- [x] `lib/views/game/widgets/shop_offer_detail_card.dart`에 공개 클래스
- [x] `ShopPanel`에서 import 사용
- [x] analyze 통과

---

## Phase 4 — 상점 모달 셸: `ShopModalOverlay` ✅

### Done when
- [x] `lib/views/game/widgets/shop_modal_overlay.dart`
- [x] `game_modals.dart` 슬림화, `game_view.dart` import 변경
- [x] analyze 통과

---

## Phase 5 — 전투 중앙 조각 (`battle_center.dart`) ✅

### Goal
`CenterHint`, `BoardInfoBadge`, `LogTape`, `BreakdownBadge`, `TinyMetric`, `DebugMeasuredTile`을 역할별 파일로 분리.

### Done when
- [x] `widgets/center_hint.dart`, `board_info_badge.dart`, `log_tape.dart`, `breakdown_badge.dart`, `debug_measured_tile.dart`
- [x] `battle_center.dart`는 조립 위주로 축소 (`BattleCenterPanel`, `PlayedTilesStage`, `PlayedTilesOverlay`만 잔류)
- [x] analyze 통과

---

## Phase 6 — 손패 조각 (`hand_zone.dart`) ✅

### Goal
`DrawFlightCard`, `HandRow`, `HandFooterInfo`, `DrawFlight`, `HandSlotLayout`을 분리.

### Done when
- [x] `widgets/hand_components.dart`에 통합
- [x] `hand_zone.dart`는 `FanHandZone` 상태 관리만 잔류
- [x] analyze 통과

---

## Phase 7 — 씬 조립 (`game_view.dart`) ✅

### Goal
`BattleTableScene`, `CompactBattleLayout`을 별도 파일로 옮겨 `GameView`는 오버레이·라우팅만 담당.

### Done when
- [x] `widgets/battle_scene.dart`
- [x] `game_view.dart` 불필요 import 제거
- [x] analyze 통과

---

## Phase 8 — 타이틀·설정 (스킵)

> 모두 private 위젯(`_` 접두사)이며 각 파일 내에서만 사용 → 재사용 수요 없어 현시점 분리 불필요.  
> 향후 타 화면에서 재사용 수요가 생기면 그때 분리한다.

---

## 최종 검증 ✅

- `dart analyze lib/` — 0 errors, 0 warnings (기존 info 1건만)
- `flutter test` — 55/55 통과

---

## 분리된 위젯 목록 (widgets/)

| 파일 | 위젯 | 원래 위치 |
|------|-------|-----------|
| `battle_tile_card.dart` | `BattleTileCard` | `hand_zone.dart` |
| `jester_slot_card.dart` | `JesterSlotCard` | `jester_bar.dart` |
| `glass_panel.dart` | `GlassPanel` | `game_modals.dart` |
| `modal_scrim.dart` | `ModalScrim` | `game_modals.dart` |
| `summary_chip.dart` | `SummaryChip` | `game_modals.dart` |
| `shop_offer_detail_card.dart` | `ShopOfferDetailCard` | `game_modals.dart` |
| `shop_modal_overlay.dart` | `ShopModalOverlay` | `game_modals.dart` |
| `center_hint.dart` | `CenterHint` | `battle_center.dart` |
| `board_info_badge.dart` | `BoardInfoBadge` | `battle_center.dart` |
| `log_tape.dart` | `LogTape` | `battle_center.dart` |
| `breakdown_badge.dart` | `BreakdownBadge`, `TinyMetric` | `battle_center.dart` |
| `debug_measured_tile.dart` | `DebugMeasuredTile` | `battle_center.dart` |
| `hand_components.dart` | `DrawFlight`, `HandSlotLayout`, `HandFooterInfo`, `DrawFlightCard`, `HandRow` | `hand_zone.dart` |
| `battle_scene.dart` | `BattleTableScene`, `CompactBattleLayout` | `game_view.dart` |
