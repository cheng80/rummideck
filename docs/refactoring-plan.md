# Riverpod + 모듈 분리 리팩토링 플랜

> **기준일**: 2026-04-06  
> **최종 갱신**: 2026-04-06 (Phase 1–3, 5–7 전체 완료) · 2026-04 문서 동기화 (연출·상점·디버그)  
> **원칙**: CURSOR.md — "작은 단위 변경", "실행 가능한 코드 유지", "UI/Logic 분리"  
> **참조 프로젝트**: `flame_tab_order` (easy_localization), `hivetodo` (Riverpod 3 + ConsumerWidget)

---

## 현재 상태

| 항목 | 상태 |
|------|------|
| `game_view.dart` 기능 단위 분리 | ✅ 완료 (7개 독립 import 파일) |
| `flutter_riverpod` 의존성 + `ProviderScope` | ✅ 완료 |
| `GameSessionController` → `ChangeNotifierProvider` | ✅ 완료 (`vm/game_session_provider.dart`) |
| `GameView` → `ConsumerStatefulWidget` | ✅ 완료 |
| `part of` → `import` 전환 | ✅ 완료 |
| 하위 위젯 `ConsumerWidget` 전환 | ✅ 완료 (controller prop 전면 제거) |
| `easy_localization` 다국어 구조 | ✅ 완료 (ko/en) |
| Provider 세분화 (최소 리빌드) | ⬜ 미완 (Phase 4, 프로파일링 후) |
| `flutter analyze` | ✅ 에러 0 (info 3 기존) |
| `flutter test` (logic/game) | ✅ 52개 전부 통과 |

---

## 디렉토리 구조 (완료)

```
lib/views/
  game_view.dart            ← 루트 ConsumerStatefulWidget + BattleTableScene/CompactBattleLayout
  game/
    game_common.dart        ← StageStatusStrip(ConsumerWidget), 공통 위젯(StatusBadge, RailPanel 등), compactNumber()
    battle_top_strip.dart   ← CompactTopStrip(ConsumerWidget), CompactMetaPanel(ConsumerWidget), BlindHeaderCard 등
    jester_bar.dart         ← JesterBar(ConsumerWidget), JesterSlotCard
    battle_center.dart      ← BattleCenterPanel(ConsumerWidget), PlayedTilesStage/Overlay, LogTape, BreakdownBadge 등
    hand_zone.dart          ← FanHandZone(ConsumerStatefulWidget), BattleTileCard, HandRow, DrawFlightCard 등
    battle_bottom_bar.dart  ← BottomBattleBar(ConsumerWidget)
    game_modals.dart        ← ShopPanel, RunInfoPanel, GameOverPanel, RunCompletePanel(ConsumerWidget),
                               PauseMenuOverlay(StatefulWidget), ModalScrim, GlassPanel
lib/vm/
  game_session_provider.dart ← ChangeNotifierProvider.autoDispose<GameSessionController>
lib/game/
  game_presentation_clock.dart ← UI 연출 일시정지·delay (GameSessionController가 소유)
```

게임 뷰 보조:

- `lib/views/game/jester_detail_sheet.dart` — 제스터 상세 다이얼로그 (`JesterBar` / 상점 공통)

---

## 완료된 리팩토링 단계

### Phase 1: 인프라 ✅

- [x] `flutter_riverpod` 의존성 추가
- [x] `main.dart`에 `ProviderScope` 적용
- [x] `GameSessionController` → `ChangeNotifierProvider.autoDispose`
- [x] `GameView` → `ConsumerStatefulWidget`
- [x] `game_view.dart` → 7개 part 파일 기능 분리

### Phase 2: `part` → `import` 전환 ✅

- [x] 7개 파일 모두 `part of` → 독립 `import` 파일로 전환
- [x] 모든 위젯 `_` prefix 제거 → public 클래스
- [x] `game_view.dart`에서 `part` 선언 → `import` 추가

### Phase 3: ConsumerWidget 전환 ✅

- [x] `BottomBattleBar` → ConsumerWidget
- [x] `StageStatusStrip` → ConsumerWidget
- [x] `JesterBar` → ConsumerWidget
- [x] `CompactTopStrip` + `CompactMetaPanel` → ConsumerWidget
- [x] `BattleCenterPanel` → ConsumerWidget
- [x] `ShopPanel` / `GameOverPanel` / `RunCompletePanel` / `RunInfoPanel` → ConsumerWidget
- [x] `FanHandZone` → ConsumerStatefulWidget (`ref.watch` build, `ref.read` 콜백/dispose)
- [x] `BattleTableScene` / `CompactBattleLayout` → controller prop 제거
- [x] `GameView` → controller prop 전달 최소화 (const 생성자 활용)

---

## 남은 리팩토링 단계

### Phase 4: Provider 세분화 (선택적, 성능 최적화)

> Phase 3 완료 후 실제 플레이에서 성능 이슈가 관측될 때 진행.  
> 현재 단일 `gameSessionProvider`가 모든 상태를 관리하므로, `notifyListeners()` 호출 시 모든 ConsumerWidget이 리빌드됨.

- [ ] `gameSessionProvider`에서 파생 Provider 분리:
  - `scoreProvider` (점수 관련 상태만)
  - `handProvider` (손패/선택 상태만)
  - `shopProvider` (상점 상태만)
  - `stageProvider` (스테이지/블라인드 상태만)
- [ ] `ref.watch(gameSessionProvider.select(...))` 로 세밀한 구독 범위 지정
- [ ] 또는 `GameSessionController`를 여러 Notifier로 분리

### Phase 5: 문서 갱신 ✅

- [x] `PLAN_CHECKLIST.md` §9 백로그 → 완료 반영
- [x] `docs/current-implementation-status.md` 업데이트
- [x] `START_HERE.md` 우선순위 갱신

### Phase 6: 위젯/함수 분리 — 반복 제거 및 재사용성 확보

> 코드 분석 결과 기반. 한 번에 한 카테고리씩 진행하며 `flutter analyze` + `flutter test` 통과 확인.

#### 6-A. 공통 상수 추출 ✅

- [x] `lib/views/game/battle_theme.dart` 생성:
  - `AppColors` — 골드(`0xFFF3C55B`), 테이블 그린, 스크림, 락 틴트 등 산재된 색상 통합
  - `BattleSpacing` — compact/normal 간격, 프레임 radius, 종횡비 등
  - `ModalDimens` — 모달 maxWidth, 패딩, 테두리 radius
  - `HandAnimationDurations` — 드로우 지속시간, 딜레이 간격
- [x] 각 UI 파일에서 하드코딩된 상수를 위 클래스로 교체 (game_view, hand_zone, jester_bar, battle_bottom_bar, game_common, battle_center, battle_top_strip, game_modals)

#### 6-B. 공통 Decoration/위젯 추출 ✅

- [x] `SubPanelSurface` — 반투명 검정 + borderRadius 래퍼 (`LogTape`, `BreakdownBadge` 등에서 활용)
- [x] `LogTape`, `BreakdownBadge` → `SubPanelSurface` 래퍼로 교체
- [ ] `StatusBadge`/`BoardInfoBadge` — 레이아웃 차이(Row vs Column)로 통합 보류, 현행 유지

#### 6-C. 긴 build 메서드 분리 ✅

- [x] `BlindHeaderCard.build` → `_blindBadge`, `_rewardBadge` private 메서드 추출 (+ `SubPanelSurface` 활용)
- [x] `FanHandZone.build` → `_buildHandStack` private 메서드로 Stack 레이아웃 분리
- [ ] `PlayedTilesOverlay.build`, `RunInfoPanel.build`, `ShopPanel.build` — 현재 규모에서는 분리 실익 적음, 보류

#### 6-D. 유틸리티 함수 통합 ✅

- [x] 타일 리스트 비교 → `lib/utils/tile_utils.dart`에 `sameTileList()` 공용 함수 생성, `battle_center`·`hand_zone`에서 교체
- [x] 블라인드 색상 → `AppColors.blindSmall/blindBig/blindBoss` 상수로 추출, `BlindHeaderCard._blindBadgeColor`에서 활용
- [ ] 색상 명암 계산 (`HSLColor` 패턴, `title_view`) → 보류 (사용 빈도 낮음)

#### 6-E. 타입 안전성 개선 ✅

- [x] `JesterSlotCard.anomaly`의 `dynamic` → `Anomaly?`으로 변경
- [x] `_rarityLabel(dynamic)` → `_rarityLabel(AnomalyRarity)` 타입 안전 switch
- [x] `LargeActionButton.subtitle` 미사용 필드 제거 (`required` 파라미터 삭제, 호출부 정리)

### Phase 7: 하드코딩 색상 전수 추출 + 레이아웃 정리 ✅

> 남은 모든 `Color(0x...)` 리터럴을 `AppColors`로 추출하고, 미사용 파라미터를 정리한다.

- [x] `battle_center.dart`: `Color(0x552C7A66)` → `AppColors.centerPanelBg`, `Color(0x55D8C27A)` → `AppColors.centerPanelBorder`
- [x] `battle_top_strip.dart`: `Color(0x44FFFFFF)` → `AppColors.metaRowBorder`, 패널 색상 6종 추출
- [x] `game_modals.dart`: 모달 배경/보더/텍스트 색상 7종 추출
- [x] `title_view.dart`: 타이틀 화면 테마 색상 14종 추출
- [x] `game_view.dart`: `CompactBattleLayout.viewport` 미사용 파라미터 제거, `BattleTableScene` 불필요 `LayoutBuilder` 제거

### Phase 8: 반응형 레이아웃 (iPad/iPhone 동일 비율) ✅

- [x] `FittedBox` 기반 스케일링: 기준 해상도 402×778에서 렌더링 후 화면에 맞게 확대
- [x] 조건부 적용: iPhone(`shortSide ≤ 500`)은 스케일링 없이 전체 화면, iPad는 `FittedBox` 적용
- [x] SafeArea 밖 `Colors.black`, SafeArea 안 여백 `AppColors.tableGreen3`
- [x] 중앙 패널 타일 위치 `Alignment.bottomCenter`로 변경

---

## 전환 규칙 (완료 기록)

1. **한 번에 한 파일씩** 전환하고 `flutter analyze` + `flutter test` 통과 확인
2. **기능 변경 없이** 구조만 바꾸기 (리팩토링과 기능 개발 분리)
3. **네이밍 컨벤션**: `_CompactTopStrip` → `CompactTopStrip` (파일명 유지)
4. **import 순서**: dart → package → project relative
5. **테스트 깨지면 즉시 수정** (CURSOR.md: "실행 가능한 코드 유지")

---

## 참고: hivetodo 아키텍처 패턴

```
model/   → 순수 데이터 모델
service/ → 외부 서비스 (알림, 리뷰 등)
vm/      → Notifier + Provider (상태 관리)
view/    → ConsumerWidget / ConsumerStatefulWidget
util/    → 유틸리티
```

- `AsyncNotifierProvider`: 비동기 데이터 목록 (DB)
- `NotifierProvider`: 앱 전역 설정 (테마, wakelock)
- `NotifierProvider.autoDispose`: 일회성 UI 상태 (필터, 편집 시트)
- `Provider`: 파생 상태 (여러 Provider를 ref.watch로 조합)
- 코드 생성 없이 수동 `final xxxProvider = ...` 선언

---

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-04-06 | Phase 1 완료: Riverpod 인프라 + part 분리 |
| 2026-04-06 | Phase 2 완료: part → import 전환, 위젯 public 전환 |
| 2026-04-06 | Phase 3 완료: 모든 게임 위젯 ConsumerWidget/ConsumerStatefulWidget 전환, controller prop 전면 제거 |
| 2026-04-06 | Phase 5 완료: PLAN_CHECKLIST.md, START_HERE.md, current-implementation-status.md 갱신 |
| 2026-04-06 | Phase 6 계획 추가: 위젯/함수 분리 — 반복 제거 및 재사용성 확보 |
| 2026-04-06 | Phase 6-A 완료: battle_theme.dart 생성, 8개 파일 상수 교체 |
| 2026-04-06 | Phase 6-D 완료: sameTileList 공용 함수, 중복 제거 |
| 2026-04-06 | Phase 6-E 완료: JesterSlotCard.anomaly 타입 안전화 |
| 2026-04-06 | Phase 6-B 완료: SubPanelSurface 추출, LogTape/BreakdownBadge 교체 |
| 2026-04-06 | Phase 6-C 완료: BlindHeaderCard·FanHandZone build 분리 |
| 2026-04-06 | Phase 6-E 추가: LargeActionButton.subtitle 미사용 필드 제거 |
| 2026-04-06 | 추가 상수화: CompactMetaRow/Panel, 블라인드 배지 색상 → AppColors |
| 2026-04-06 | Phase 7 완료: 남은 하드코딩 색상 전수 추출 (game_modals, title_view, battle_center, battle_top_strip) |
| 2026-04-06 | game_view.dart 정리: CompactBattleLayout.viewport 미사용 파라미터 제거 |
| 2026-04-06 | 반응형 레이아웃: FittedBox 기반 iPad/iPhone 동일 비율 스케일링 구현 |
| 2026-04-06 | 배경 처리: SafeArea 밖 black, SafeArea 안 여백 AppColors.tableGreen3 |
| 2026-04-06 | Phase 6~7 전체 완료 — 모든 리팩토링 단계 마감 |
| 2026-04 | `GamePresentationClock`, 캐시아웃·상점 UI(1/3·2/3), `jester_detail_sheet`, `debugOpenShop` / `DBG·상점` — `START_HERE`, `current-implementation-status`, `PLAN_CHECKLIST`, `40_shop_system` 문서 반영 |
