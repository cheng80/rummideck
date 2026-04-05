# Logic Rewrite Baseline

> 기준일: **2026-04-05**  
> 목적: 기존 구현을 참고만 하고, **새 Pure Dart 게임 로직을 다시 짤 때의 단일 기준선**을 고정한다.  
> 우선 문서: `10_game_rules.md` → `20_score_system.md` → `21_anomaly_system.md` → `30_progression.md` → `40_shop_system.md` → `50_architecture.md`

---

## 1. 원칙

- 새 로직은 **UI와 완전히 분리된 Pure Dart**로 작성한다.
- 문서 간 충돌은 이 문서에서 **MVP 구현값**으로 잠근다.
- 기존 `RunContext`, `ShopState`, `GameSessionController`는 참고용이며, 재작성 시 정답 소스로 간주하지 않는다.
- 재작성 1차 목표는 **첫 전투 ~ 1차 보스**까지 끊기지 않는 단일 런이다.

---

## 2. MVP 재작성 범위

### 2.1 반드시 다시 구현할 것

- Tile / Rank / Suit / Color 매핑
- Hand evaluator
- Score pipeline
- Seeded RNG
- Ante / Blind 진행
- Boss 제약 진입 지점
- Shop / Jester catalog / reroll / buy / sell
- Jester translation lookup

### 2.2 이번 단계에서 미룰 것

- Endless
- Stake 전체 효과
- Tag 보상 실구현
- Tarot / Planet / Voucher / Booster runtime
- Legendary 특수 획득 경로
- Sticker / Edition 전체 확률 처리

---

## 3. 핵심 용어 잠금

- 내부 용어는 **Ante / Blind / Boss / Jester / Shop / Run** 을 유지한다.
- 화면 표시에서만 Easy / Mid / Boss 같은 단순화 용어를 허용한다.
- 데이터 키는 `jester` 기준으로 유지한다.

---

## 4. 타일/덱 기준

- 덱: **1~13 × 4색 = 52타일**
- 색상 매핑:
  - `red -> hearts`
  - `blue -> spades`
  - `yellow -> diamonds`
  - `black -> clubs`
- 랭크 매핑:
  - `1 -> Ace`
  - `11 -> Jack`
  - `12 -> Queen`
  - `13 -> King`
- 재작성 1차는 **단일 52타일 덱**으로 고정한다.

---

## 5. 핸드 판정 기준

### 5.1 MVP에서 구현 대상으로 잠그는 핸드

- `highTile`
- `pair`
- `twoPair`
- `triple`
- `straight`
- `crownStraight`
- `flush`
- `fullHouse`
- `quad`
- `straightFlush`
- `crownStraightFlush`
- `colorStraight`
- `longStraight`

### 5.2 보류 핸드

- `fiveOfAKind`
- `flushHouse`
- `flushFive`
- 문서상 아이디어 단계의 특수 핸드

### 5.3 판정 규칙 잠금

- Pair는 **기본 허용**
- Two Pair는 **기본 허용**
- 유효 조합이 없어도 `Play`는 허용하며, 이 경우 가장 높은 숫자 타일 1장을 기준으로 `highTile` 처리
- 선택 타일 중 조합에 포함되지 않은 나머지 타일은 점수 없이 discard 처리
- Ace는 현재 MVP에서 **`10-11-12-13-1` 크라운 조합**에만 사용
- `1-2-3-4-5` Straight는 이번 재작성 1차에서 **미지원**
- 우선순위:
  - `longStraight`
  - `crownStraightFlush`
  - `straightFlush`
  - `fullHouse`
  - `quad`
  - `flush`
  - `crownStraight`
  - `straight`
  - `colorStraight`
  - `triple`
  - `twoPair`
  - `pair`
  - `highTile`

---

## 6. 점수 파이프라인 기준

### 6.1 계산 순서

1. 핸드 판정
2. 제출 타일 중 점수 계산 대상 조합 타일 확정
3. Base Chips 산정
4. Number Bonus 산정
5. Jester Chips 적용
6. Jester Mult 합산
7. Jester XMult 곱연산
8. 최종 점수 반영

### 6.2 MVP 계산식 잠금

`Final = (BaseChips + NumberBonus + JesterChipDelta) × (1 + JesterMultDelta) × JesterXMult`

### 6.3 Number Bonus

- `floor(점수 계산 대상으로 확정된 타일 숫자 합 × 0.2)`

### 6.4 Base Chips

- `highTile = 5`
- `pair = 10`
- `twoPair = 20`
- `triple = 30`
- `straight = 35`
- `crownStraight = 45`
- `flush = 40`
- `fullHouse = 50`
- `quad = 60`
- `straightFlush = 75`
- `crownStraightFlush = 95`
- `colorStraight = 55`
- `longStraight = 100`

### 6.5 조합표 레벨 표시

- `Run Info`의 포커 핸드 표는 각 조합의 `레벨 / 이름 / chips x mult / 업그레이드 상태`를 표시한다.
- Balatro 원형 기준에서 핸드 레벨은 **Planet 카드 등 업그레이드 효과**로 상승한다.
- 현재 코드의 “해당 조합 10회 사용마다 레벨 +1” 규칙은 임시 구현이며, 재작성 정답 규칙으로 채택하지 않는다.

---

## 7. 진행 구조 기준

### 7.1 라운드 자원

- Hand size: `8`
- Hands per blind: `4`
- Discards per blind: `3`
- Jester slots: `5`

### 7.2 진행 흐름

1. Run 시작
2. Ante 1 Small Blind
3. Shop
4. Ante 1 Big Blind
5. Shop
6. Ante 1 Boss Blind
7. Shop
8. 다음 Ante

### 7.3 Blind 배율

- Small: `1.0`
- Big: `1.5`
- Boss: `2.0`

### 7.4 보상/스킵 기준

- Blind 보상은 `Small $3 / Big $4 / Boss $5`를 기준으로 둔다
- Blind를 이길 때마다 Shop 진입 구조를 유지한다
- Small / Big 스킵은 구조만 고려하고, 실제 버튼/보상은 2차로 미룸
- Boss는 스킵 불가

### 7.5 Boss 제약

- 재작성 1차에서는 Boss 전용 제약 **1종만** 넣어도 된다
- 단, 구조는 `BlindModifier`처럼 확장 가능하게 잡는다

---

## 8. Jester/상점 기준

### 8.1 데이터 소스

- 카탈로그 원본: `data/common/jesters_common.json`
- 번역:
  - `assets/translations/data/en/jesters.json`
  - `assets/translations/data/ko/jesters.json`

### 8.2 슬롯/상점

- Jester 보유 슬롯: **5**
- Shop offer 슬롯: **2**
- reroll 시작 비용: **$5**
- reroll마다 비용 **+1**
- 새 상점 진입 시 reroll 비용 리셋

### 8.3 번역 로딩

- 표시 우선순위:
  1. locale 번역값
  2. `displayName` / `effectText` / `notes` 원문 fallback

### 8.4 재작성 1차 Jester 런타임 목표

- JSON 로드
- rarity / cost / trigger / structured fields 파싱
- 구매 / 판매 / 리롤
- 점수형 Jester 일부 실제 적용

---

## 9. 아키텍처 기준

### 9.1 권장 레이어

- `logic/models`
- `logic/evaluator`
- `logic/scoring`
- `logic/progression`
- `logic/jester`
- `logic/shop`
- `logic/run`
- `logic/localization`

### 9.2 상태 분리

- `RunState`
- `BlindState`
- `PlayerState`
- `DeckState`
- `ShopState`

### 9.3 이벤트

- `onBlindSelected`
- `onHandPlayed`
- `onCardScored`
- `onHandScored`
- `onDiscard`
- `onRoundEnd`
- `onShopEnter`

재작성 1차는 이벤트를 전부 구현하지 않아도 되지만, **Jester가 이벤트에 반응하는 구조**는 반드시 남긴다.

---

## 10. 첫 구현 순서

1. 데이터 모델 재정의
2. evaluator 재작성
3. score pipeline 재작성
4. blind/ante progression 재작성
5. jester catalog + translation loader 작성
6. shop runtime 재작성
7. run orchestration 재작성
8. 최소 UI 연결

---

## 11. 완료 기준

이 문서 기준 1차 완료는 아래를 의미한다.

- Seed 하나로 동일 런 재현 가능
- Ante 1 Small / Big / Boss를 순서대로 진행 가능
- 손패 선택 / 제출 / 점수 반영 / 보충이 새 로직으로 동작
- Shop에서 Jester를 표시하고 reroll / buy가 동작
- Jester 이름/효과/노트가 locale에 따라 번역 fallback 포함해 노출 가능
