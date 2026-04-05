# 10_game_rules.md

## 1. 목적
이 문서는 Balatro의 **게임 진행 구조와 족보 규칙을 그대로 유지**하면서, 입력을 타일 시스템으로 치환한 **완전한 룰 정의 문서**이다.

## 1.1 현재 구현 기준 메모 (2026-04-05)

- 아래 문서의 Balatro 원형 설명과 별개로, **현재 코드의 런타임 규칙**은 이 메모를 우선한다.
- 현재 MVP 구현은 **Pair를 기본 허용**하며, **Two Pair도 활성화**되어 있다.
- 현재 MVP 구현은 Balatro 원형 외에 `High Tile`, `Crown Straight`, `Crown Straight Flush`, `Color Straight`, `Long Straight`를 추가 사용한다.
- 현재 Straight 규칙에서 Ace는 **상단 크라운(10-11-12-13-1)** 에만 사용되며, `1-2-3-4-5`는 아직 Straight로 판정하지 않는다.

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

## 5.2 목표 설계상 보류 족보

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

## 6.3 Straight 규칙

- 현재 구현은 **중복 숫자 없이 연속**이면 Straight 계열로 본다.
- Ace(1)는 현재 **상단 크라운 조합**에서만 사용한다.

예:
- 4-5-6-7-8 → Straight
- 10-11-12-13-1 → Crown Straight
- 1-2-3-4-5 → 아직 미지원

---

## 6.4 Flush 규칙

- 같은 색 5개

---

# 7. 게임 진행 구조

## 7.1 Stage 구조 (Ante 대응)

각 Stage는 3단계로 구성됨:

- Easy (Small Blind)
- Mid (Big Blind)
- Boss (Boss Blind)

---

## 7.2 목표 점수

각 Stage는 목표 점수를 가진다.

달성 못하면 실패

---

## 7.3 스킵 규칙

- Easy / Mid는 스킵 가능
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
