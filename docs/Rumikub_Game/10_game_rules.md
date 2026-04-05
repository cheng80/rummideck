# 10_game_rules.md

## 1. 목적
이 문서는 Balatro의 **게임 진행 구조와 족보 규칙을 그대로 유지**하면서, 입력을 타일 시스템으로 치환한 **완전한 룰 정의 문서**이다.

## 1.1 현재 구현 기준 메모 (2026-04-06)

- Balatro 원형 기준 기본값은 **Hand Size 8 / Hands 4 / Discards 3 / Jester 슬롯 5**다.
- 현재 코드에는 `Hands = 5`, stage 직진 구조, `Anomaly` 명칭 등 문서와 다른 임시 구현이 남아 있다.
- 재작성 기준은 아래 본문과 `docs/logic-rewrite-baseline.md`를 우선한다.
- 현재 프로젝트는 Balatro 원형 외에 `High Tile`, `Crown Straight`, `Crown Straight Flush`, `Color Straight`, `Long Straight`를 추가 사용한다.
- 현재 Straight 규칙에서 Ace는 **상단 크라운(10-11-12-13-1)** 에만 사용하며, `1-2-3-4-5`는 MVP 1차에서 미지원으로 잠근다.

---

# 2. 게임 정의

이 게임은 다음과 같이 정의된다:

👉 **Balatro의 규칙을 그대로 유지하고, 카드 대신 타일로 플레이하는 게임**

- 점수 구조: Balatro 그대로
- 조커 시스템: Jester로 명칭만 변경
- 족보 구조: 포커 기반 그대로 유지
- 입력: 타일 (1~13 × 4색)

---

# 3. 타일 시스템

## 3.1 기본 구성
- 숫자: 1 ~ 13
- 색상: Red / Blue / Yellow / Black
- 총 52개

---

## 3.2 Rank 매핑

| 숫자 | Rank |
|------|------|
| 1 | Ace |
| 2~10 | Number |
| 11 | Jack |
| 12 | Queen |
| 13 | King |

---

## 3.3 Suit 매핑

| 색상 | Suit |
|------|------|
| Red | Heart (♥) |
| Blue | Spade (♠) |
| Yellow | Diamond (♦) |
| Black | Club (♣) |

---

## 3.4 핵심 규칙

👉 모든 타일은 반드시 다음 속성을 가진다

- number (1~13)
- color (R/B/Y/K)
- rank (A~K)
- suit (♥♠♦♣)

---

# 4. 기본 플레이 구조

## 4.1 손패
- 기본 손패: 8

## 4.2 라운드 자원
- Hands (플레이 횟수): 4
- Discards (버리기): 3

---

## 4.3 턴 흐름

1. 타일 선택
2. 족보 생성
3. 점수 계산
4. 점수 누적
5. 손패 보충
6. 반복

### 4.4 Play 허용 규칙

- 선택한 타일에 완성 조합이 없어도 `Play`는 항상 가능하다.
- 완성 조합이 없으면 해당 제출은 최소 `High Tile`로 처리한다.
- 선택한 타일 안에 여러 의미가 있더라도, **가장 높은 우선순위 조합 1개만** 점수 계산 대상으로 사용한다.
- 점수 계산에 포함되지 않은 나머지 선택 타일은 **Discard와 동일하게 소모**된다.
- 즉, `Play`는 항상 가능하지만, 실제 점수 반영은 “선택한 타일 중 최고 우선순위 조합 1개”만 담당한다.

---

# 5. 족보 (핸드) 정의

👉 Balatro 기준 그대로 유지

---

## 5.1 현재 구현 족보

| Hand | 타일 조건 |
|------|----------|
| High Tile | 타일 1개 제출 |
| Pair | 같은 숫자 2개 |
| Two Pair | 다른 숫자 Pair 2개 |
| Three of a Kind | 같은 숫자 3개 |
| Straight | 연속 숫자 5개 |
| Crown Straight | `10-11-12-13-1` |
| Flush | 같은 색 5개 |
| Full House | Triple + Pair |
| Four of a Kind | 같은 숫자 4개 |
| Straight Flush | 같은 색 + 연속 5개 |
| Crown Straight Flush | 같은 색 `10-11-12-13-1` |
| Color Straight | 같은 색 연속 4개 |
| Long Straight | 같은 색 연속 6개 이상 |

---

## 5.2 Balatro 원형 족보와의 관계

- Balatro 원형 기본 핸드는 `High Card / Pair / Two Pair / Three of a Kind / Straight / Flush / Full House / Four of a Kind / Straight Flush`다.
- 이 프로젝트는 타일 시스템 적응을 위해 `Crown Straight`, `Crown Straight Flush`, `Color Straight`, `Long Straight`를 **프로젝트 확장 핸드**로 추가한다.
- 따라서 “Balatro 카피”는 기본 구조와 점수 철학을 따른다는 뜻이며, 위 4종은 의도적으로 확장된 규칙으로 본다.

---

## 5.3 목표 설계상 보류 족보

| Hand | 조건 |
|------|------|
| Five of a Kind | 같은 숫자 5개 |
| Flush House | Full House + Flush |
| Flush Five | Five of a Kind + Flush |

---

# 6. 족보 판정 규칙

## 6.1 우선순위

현재 구현 우선순위:

`Long Straight` → `Crown Straight Flush` → `Straight Flush` → `Full House` → `Four of a Kind` → `Flush` → `Crown Straight` → `Straight` → `Color Straight` → `Three of a Kind` → `Two Pair` → `Pair` → `High Tile`

---

## 6.2 포함 관계

- Straight Flush → Straight 포함
- Full House → Pair 포함
- Three → Pair 포함

👉 Jester 트리거 조건에 사용됨

---

## 6.3 제출 해석 규칙

- 제출된 타일 묶음 전체를 한 개의 핸드로 강제 해석하지 않는다.
- 먼저 선택 타일 안에서 **최고 우선순위 유효 조합 1개**를 찾는다.
- 찾은 조합의 구성 타일만 점수 계산에 사용한다.
- 선택했지만 조합에 포함되지 않은 타일은 점수 없이 버려진다.
- 유효 조합이 전혀 없으면 가장 높은 숫자 타일 1장을 기준으로 `High Tile`로 처리한다.

예:
- `7, 7, 3` 제출 → `Pair(7,7)` 점수 계산, `3`은 discard 처리
- `4, 6, 9` 제출 → 조합 없음, 가장 높은 타일 `9` 기준 `High Tile`

---

## 6.4 Straight 규칙

- 현재 구현은 **중복 숫자 없이 연속**이면 Straight 계열로 본다.
- Ace(1)는 현재 **상단 크라운 조합**에서만 사용한다.

예:
- 4-5-6-7-8 → Straight
- 10-11-12-13-1 → Crown Straight
- 1-2-3-4-5 → 아직 미지원

---

## 6.5 Flush 규칙

- 같은 색 5개

---

# 7. 게임 진행 구조

## 7.1 Ante / Blind 구조

각 Ante는 3개의 Blind로 구성된다.

- Small Blind
- Big Blind
- Boss Blind

Small / Big는 스킵 가능하고 Boss는 필수다.

---

## 7.2 Ante 흐름

```text
Ante 1
→ Small Blind
→ Shop
→ Big Blind
→ Shop
→ Boss Blind
→ Shop
→ Ante 2
```

- Ante 8 Boss는 Finisher Blind다.
- MVP는 첫 전투~1차 보스까지를 우선 검증 대상으로 삼되, 구조 자체는 Ante 8 기준으로 유지한다.

---

## 7.3 목표 점수

각 Blind는 목표 점수를 가진다.

달성 못하면 실패

---

## 7.4 스킵 규칙

- Small / Big는 스킵 가능
- Boss는 필수

---

# 8. Jester 시스템 (조커)

- 슬롯: 5개
- 상점에서 획득
- 점수 및 규칙 변경

👉 게임 핵심 시스템

---

# 9. 제거된 시스템

다음은 현재 제거 상태

- Tarot
- Planet
- Spectral
- Voucher

> 단, **핸드 레벨업 원리 자체는 Balatro 원형처럼 Planet 계열 업그레이드가 정답**이다. 현재 코드의 “사용 횟수 기반 레벨업”은 임시 구현으로 간주한다.

---

# 10. 설계 원칙

### 원칙 1
Balatro 구조 유지

### 원칙 2
타일은 입력만 변경

### 원칙 3
Jester가 게임을 지배

---

# 11. 금지사항

- 족보 변경 ❌
- 카드 구조 변경 ❌
- Suit 제거 ❌
- Rank 제거 ❌

---

# 12. 한 줄 정의

👉 Balatro를 그대로 유지하고, 입력만 타일로 바꾼 게임
