# Doc-Driven Workflow

## 목적

이 문서는 앞으로 이 프로젝트에서 작업을 시작할 때 반드시 먼저 확인할 문서 순서와 구현 진행 순서를 고정한다.

핵심 원칙:

- 항상 문서를 먼저 읽고 작업한다
- 작업 순서는 `MVP_CHECKLIST.md` 기준으로 판단한다
- 디자인 생성은 구현 순서상 필요해지는 시점에만 진행한다
- `Stitch MCP`는 디자인 산출 단계에서 사용하며, 현재 우선순위를 앞지르지 않는다

## 1. 문서 참조 우선순위

충돌 시 아래 순서를 따른다.

1. `docs/Rumikub_Game/10_game_rules.md`
2. `docs/Rumikub_Game/20_score_system.md`
3. `docs/Rumikub_Game/21_anomaly_system.md`
4. `docs/Rumikub_Game/30_progression.md`
5. `docs/Rumikub_Game/50_architecture.md`
6. `docs/Rumikub_Game/60_content_rules.md`
7. `docs/Rumikub_Game/40_shop_system.md`
8. `docs/Rumikub_Game/70_playtest.md`
9. `docs/Rumikub_Game/80_mvp_checklist.md`
10. `docs/code-flow-analysis.md`
11. `docs/refactoring.md` (UI·Riverpod 리팩토링 완료 요약·아카이브; 규칙 충돌 시 위 1–10 우선)

설명:

- 게임 규칙과 점수 규칙이 가장 우선이다
- 아키텍처는 규칙을 구현하는 구조 기준이다
- `code-flow-analysis.md`는 앱 골격 유지 기준이다
- `refactoring.md`는 이력·구조 참고용이며 설계 문서와 충돌하지 않게 읽는다

## 2. 구현 진행 순서

반드시 아래 순서를 지킨다.

### Step 1. Pure Dart 로직

먼저 구현해야 하는 항목:

- Tile
- TileColor
- CombinationType
- CombinationResult
- Combination evaluator
- Score calculator
- Stage target calculator
- SeededRng

완료 전에는:

- Flame UI 확장
- 본격적인 디자인 반영
- 상점 화면 구현

위 항목을 앞당기지 않는다.

### Step 2. Run 상태

- RunContext
- PlayerState
- StageState
- 손패 보충
- 플레이 / 버리기 처리
- 스테이지 클리어 / 실패 판정

### Step 3. Shop 로직

- ShopState
- ShopOffer
- anomaly 구매 / 교체 / 리롤

### Step 4. UI 연결

- Flutter/Flame 화면 반영
- HUD
- 손패 표시
- anomaly 슬롯
- submit / discard

### Step 5. 디자인 고도화

- Stitch MCP 활용
- 화면 다듬기
- 일관된 디자인 시스템 보정

## 3. 현재 위치 진단

현재 코드 상태:

- 앱 골격은 존재
- 라우팅 구조 존재
- Flame 배경/일시정지 셸 존재
- Pure Dart 로직 계층 존재
- RunContext / ShopState / anomaly 카탈로그 구현됨
- 기본 게임 화면이 현재 로직과 연결됨
- 로그와 seed 기반 재현 테스트 일부 구현됨

현재 위치 판정:

- `Phase 4. UI 연결` 완료
- `Phase 5. 로그/테스트 도구 연결` 진행 중

즉 다음 실제 구현 작업은 아래여야 한다.

1. 문서에 비어 있는 실행 규칙 확정
2. 게임 루프 미완성 지점 보강
3. 화면 안정화와 무스크롤 검증
4. 게임 화면 위젯 테스트 보강

## 4. 작업 시작 전 체크

새 작업을 시작할 때마다 아래를 확인한다.

- 이 작업이 현재 단계보다 앞선 작업은 아닌가
- 관련 규칙 문서를 먼저 읽었는가
- 로직이 UI를 참조하지 않는가
- Random 직접 사용 가능성이 없는가
- 점수 순서가 `Chips -> Mult -> XMult`를 깨지 않는가

## 5. Stitch 사용 시점

`Stitch MCP`는 아래 시점부터 사용한다.

- Pure Dart 핵심 로직의 구조가 정리된 뒤
- 최소한 `Game MVP` 화면에 필요한 정보 구조가 코드 레벨에서 확정된 뒤
- 화면 검증과 시각적 구조 구체화가 필요해졌을 때

즉 현재 시점의 Stitch 관련 파일은 준비 문서이며, 구현 우선순위를 대체하지 않는다.

## 6. 다음 작업 고정

다음 작업은 아래 순서로 진행한다.

1. 미확정 문서 항목을 식별하고 문서에 반영
2. Gold 보상 규칙 등 실행 경계값 확정
3. 현재 게임 화면의 SafeArea / 레터박스 / 오버레이 순서 안정화
4. 게임 화면 위젯 테스트와 재현성 도구 보강
5. 이후에 Stitch 활용 검토
