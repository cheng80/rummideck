# Current Implementation Status

> **세션 시작**: [`START_HERE.md`](../START_HERE.md) → [`PLAN_CHECKLIST.md`](../PLAN_CHECKLIST.md) 순으로 본다.  
> **실행 단위 진행표**: `PLAN_CHECKLIST.md`에서 체크박스로 관리한다. 본 문서는 상태 스냅샷·보류 사유용이다.  
> **게임성 검증 (2026)**: 로직만으로는 재미 검증이 어렵다고 보아, 첫 전투~1차 보스까지 **한 번의 완전한 순회**와 **딜·드로우·리필·점수 연출**(`PLAN_CHECKLIST.md` §0·§5.1)을 우선 과제로 둔다.
> **재작성 기준 (2026-04-05)**: 현재 게임 로직은 부분 수정 대신 **문서 기준 재작성 대상으로 간주**한다. 아래 완료 항목은 참고용 자산이며, 새 구현의 정답 소스로 보지 않는다.

## 목적

이 문서는 현재 구현 상태와 아직 문서에 정의되지 않아 임의 구현을 보류한 항목을 정리한다.

핵심 원칙:

- 구현된 것과 미구현된 것을 명확히 분리한다
- 미구현 항목은 문서 정의가 생기기 전까지 임의 수치를 넣지 않는다

## 1. 완료된 구현

### Pure Dart 로직

- Tile / TileColor
- CombinationType / CombinationResult
- Combination evaluator
- Score calculator
- SeededRng
- Stage target calculator

### 런 상태

- RunContext
- PlayerState
- StageState
- 손패 보충
- 조합 제출 / 버리기
- 스테이지 클리어 / 실패
- 같은 런에서 다음 스테이지 시작 시 새 손패 드로우

### 상점 로직

- ShopState
- ShopOffer
- anomaly 구매
- anomaly 교체
- 리롤 비용 5 시작, 리롤마다 +1, 상점 진입 시 리셋
- MVP anomaly 8종 카탈로그

### UI 연결

- GameView와 RunContext 연결
- 상단 HUD
- anomaly 슬롯
- 조합 미리보기
- 손패 8개 표시
- 제출 / 버리기 버튼
- 상점 / 게임오버 / Pause 최상위 오버레이
- `Run Info` 조합표 모달 기초 UI

### 테스트

- 조합 판정 테스트
- 점수 계산 테스트
- RNG 재현 테스트
- RunContext 테스트
- ShopState 테스트
- GameSessionController 테스트

### 데이터 번역 자산

- `data/common/jesters_common.json`에 번역 키 추가
- `assets/translations/data/en/jesters.json` 원문 분리
- `assets/translations/data/ko/jesters.json` 한글 번역 작성
- `docs/logic-rewrite-baseline.md`로 재작성 기준선 확정

## 2. 문서 정의가 부족해 보류한 항목

### Gold 획득 수치

문서에 정의된 것:

- Balatro 원형은 Blind별 보상 `Small $3 / Big $4 / Boss $5`
- 리롤 비용은 5
- 새 상점 진입 시 리롤 비용 리셋

문서에 비어 있는 것:

- 현재 MVP에서 Blind별 보상 대신 단일 공식을 계속 쓸지 여부

현재 상태:

- UI와 상점 소비는 구현됨
- 자동 Gold 지급 구현됨
- 현재 공식: `10 + (RemainingPlays × 5)` 이며 문서 정답과 불일치

### 핸드 레벨업 정책

문서에 정의된 것:

- Balatro 원형은 Planet/업그레이드 기반 핸드 레벨업

문서에 비어 있는 것:

- 현재 MVP에서 Planet을 비활성화한 상태로 레벨을 어떻게 다룰지

현재 상태:

- `Run Info` 표는 존재함
- 현재 코드는 조합 사용 횟수 기반 임시 레벨업을 사용함
- Balatro 원형과 불일치하므로 재작성 대상

### Two Pair

문서 상태:

- `10_game_rules.md` / `20_score_system.md` 기준 현재 구현값 문서화 완료

현재 상태:

- 구현 및 테스트 완료

### Overload / Perfect Straight / Wild Combo

문서 상태:

- 개념은 존재
- MVP에서 보류 가능

현재 상태:

- 미구현

### 덱 구성 확정

문서에 명시된 것:

- 색 4개
- 숫자 1~13

문서에 비어 있는 것:

- 실제 덱이 단일 세트인지 중복 세트인지

현재 상태:

- 임시로 4색 x 1~13 단일 세트를 사용
- 추후 문서 확정 시 조정 필요

## 3. 지금 기준 다음 우선순위

1. 문서 대비 현재 불일치 정리: Hands 4/5, Jester 슬롯 3/5, Ante×Blind 구조, Anomaly 잔존 의존
2. Pure Dart 코어 로직 재설계 및 재구현
3. Jester 카탈로그/번역 로더 연결
4. 새 로직을 게임 화면에 최소 경로로 재연결
5. 화면 무스크롤/연출 검증 재진입

## 4. 현재 확인된 핵심 불일치

- 현재 런타임은 `Anomaly` 타입과 `mvp_anomalies.dart`를 사용하고 있어 `jesters_common.json` 기반 Jester 시스템과 다르다.
- 현재 기본 Hands는 `5`이고, 재작성 기준 문서는 `4`다.
- 현재 Jester 구매 슬롯은 `3`이고, 재작성 기준 문서는 `5`다.
- 현재 진행은 단순 stage 1~5 구조이며, 문서 기준인 `Small / Big / Boss` 3단 블라인드 진행이 아니다.
- 현재 `Run Info`는 조합표 UI까지는 들어갔지만, 코드의 레벨 상승 공식은 Planet 기반 원형 규칙과 다르다.
- 현재 제출 규칙은 “선택 타일 전체가 유효 조합이어야 함”에 가깝고, 문서 기준인 “비조합 Play 허용 / 최고 우선순위 조합만 채점 / 나머지 discard”와 다르다.

## 5. 주의사항

- 위 미정 항목은 문서 확정 전까지 임의 밸런싱 금지
- 실행을 위해 필요한 값이라도 문서 없는 경우는 먼저 문서화 후 구현
