# Stitch MVP Design Plan

## 목적

`docs/Rumikub_Game` 문서를 기준으로 MVP 화면 디자인 가이드를 만들고, 이를 `Stitch MCP` 생성 흐름에 연결한다.

앱의 기본 구조는 `docs/code-flow-analysis.md`의 골격을 유지한다.

- `main.dart -> App -> Router -> View -> Flame Game`
- 초기 생성 대상은 Flutter 위젯 구현이 아니라 `Stitch`용 모바일 세로 화면 설계안이다.
- 생성된 결과는 이후 Flutter/Flame UI 레이어에 이식한다.

## 고정 원칙

- 플랫폼: 모바일 세로형
- 엔진 구조: Flutter + Flame
- UI와 로직 분리
- 턴 종료 시 계산, 프레임 기반 점수 계산 금지
- 점수 규칙은 `Chips -> Mult -> XMult`
- 랜덤은 반드시 Seed 기반

## 디자인 목표

- 한눈에 현재 런 상태를 읽을 수 있어야 한다.
- 손패 8개와 조합 미리보기가 즉시 이해되어야 한다.
- 변칙 타일 3개가 빌드 엔진으로 강하게 보이도록 해야 한다.
- 점수 폭발 감각은 과장하되 정보 구조는 단순해야 한다.
- 기존 타이틀 화면의 우주/아케이드 톤은 유지하되, 실제 플레이 화면은 정보 밀도를 더 높인다.

## Stitch 제작 범위

### Phase A. 디자인 기준 문서화

- `.stitch/DESIGN.md`
- `.stitch/SITE.md`
- `.stitch/next-prompt.md`

완료 기준:

- Stitch에 넣을 디자인 시스템 문구가 고정됨
- MVP 대상 화면 우선순위가 정리됨
- 첫 생성 프롬프트가 준비됨

### Phase B. 화면 생성 우선순위

1. `game_mvp`
2. `shop_mvp`
3. `title_mvp`
4. `pause_overlay`
5. `seed_entry`

이 순서를 택하는 이유:

- MVP 검증의 핵심은 실제 플레이 화면이다.
- 현재 코드 골격상 `GameView`가 가장 큰 구조 변경 지점이다.
- 상점은 런 방향 결정 요소라서 두 번째로 중요하다.

### Phase C. Stitch 결과 검토 기준

- 세로형 모바일 기준에서 상단 HUD, 중단 anomaly 슬롯, 하단 손패/행동 버튼의 계층이 분명한가
- 손패 8개가 한눈에 들어오는가
- 점수와 목표 점수의 대비가 충분한가
- 제출 버튼과 버리기 버튼의 역할 차이가 즉시 보이는가
- Flame HUD 또는 Flutter overlay로 이식 가능한 구조인가

### Phase D. Flutter/Flame 이식

- Stitch 산출물에서 정보 구조와 시각 규칙만 가져온다.
- 실제 게임 상태 바인딩은 Flutter 위젯과 Pure Dart 로직에서 수행한다.
- Flame은 배경/연출/게임 루프에 집중하고, 정보 UI는 Flutter overlay 또는 HUD 성격으로 유지한다.

## 화면별 요구사항 요약

### 1. Game MVP

- 상단: Stage, score/target, plays, discards, gold, seed
- 중단: anomaly 슬롯 3개, 현재 선택 조합 미리보기, 예상 점수
- 하단: 손패 8개, submit, discard

### 2. Shop MVP

- 상단: current gold, stage clear summary
- 중앙: 3개 offer 슬롯
- 하단: reroll, leave, current anomaly 3칸

### 3. Title MVP

- 현재 우주/아케이드 감성 유지
- Seed 시작, 계속, 설정 진입 구조 후보 포함 가능

### 4. Pause Overlay

- Seed 재표시
- continue / settings / quit
- 볼륨 슬라이더는 현 구조와 결합 가능해야 함

## 구현 전 결정사항

- 첫 Stitch 생성은 `game_mvp` 한 장면으로 시작한다.
- 이 장면은 실제 한 턴 진행 중 상태를 보여주는 정적 설계안이다.
- Pair, Overload, Perfect Straight 전용 UI는 1차 디자인에서 과도하게 드러내지 않는다.
- anomaly는 8종 MVP 풀을 기준으로 표현하되, 슬롯은 3칸만 노출한다.

## 산출물 체크리스트

- [x] Stitch용 디자인 방향 문서
- [x] Stitch용 사이트 맵/화면 맵
- [x] 첫 배턴 프롬프트
- [ ] Stitch 프로젝트 메타데이터
- [ ] `game_mvp` 생성 결과
- [ ] `shop_mvp` 생성 결과
- [ ] Flutter/Flame 반영 계획 업데이트

## 다음 실행

1. Stitch 프로젝트를 모바일 타입으로 생성한다.
2. `game_mvp` 프롬프트로 첫 화면을 생성한다.
3. 결과를 기준으로 `.stitch/DESIGN.md`를 보정한다.
4. 이후 `shop_mvp`와 `title_mvp`를 생성한다.
