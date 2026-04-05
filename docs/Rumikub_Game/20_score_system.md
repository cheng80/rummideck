# 20_score_system.md

## 1. 목적
이 문서는 Balatro의 **점수 계산 시스템을 그대로 유지**하면서, 입력을 타일(1~13 × 4색)로 치환했을 때의 **완전한 계산 규칙**을 정의한다.

## 1.1 현재 구현 기준 메모 (2026-04-05)

- 아래 표와 수식은 **현재 코드의 실제 계산식**을 기준으로 적는다.
- 현재 구현은 핸드별 **기본 Mult를 두지 않고**, `Mult = 1 + anomaly 합산`으로 계산한다.
- 타일 숫자 보너스는 `floor(선택 타일 숫자 합 × 0.2)` 이며, Chips 단계에 더한다.
- 현재 구현 점수식:

`Final Score = (Base Chips + Number Bonus + Anomaly Chips) × (1 + Anomaly Mult) × Anomaly XMult`

---

## 2. 핵심 점수 공식

Final Score = Chips × Mult × XMult

- Chips: 기본 점수
- Mult: 합산 배수
- XMult: 곱연산 배수

---

## 3. 점수 계산 순서 (절대 규칙)

1. 핸드 판정
2. 핸드 기본 Chips / Mult 적용
3. 카드(타일) Chips 추가
4. Jester Chips 적용
5. Mult 합산
6. XMult 곱연산
7. 최종 점수 산출

👉 순서 변경 금지

---

## 4. 타일의 Rank / Suit 이중 속성

타일은 숫자와 색상 외에 Rank와 Suit를 동시에 가진다.

### 4.1 Rank 매핑

| 숫자 | Rank |
|------|------|
| 1 | Ace |
| 2~10 | Number |
| 11 | Jack |
| 12 | Queen |
| 13 | King |

### 4.2 Suit 매핑

| 색상 | Suit |
|------|------|
| Red | Heart (♥) |
| Blue | Spade (♠) |
| Yellow | Diamond (♦) |
| Black | Club (♣) |

---

## 5. 현재 구현 기본 핸드 점수

| Hand | Base Chips |
|------|-----------:|
| High Tile | 5 |
| Pair | 10 |
| Two Pair | 20 |
| Three of a Kind | 30 |
| Straight | 35 |
| Crown Straight | 45 |
| Flush | 40 |
| Full House | 50 |
| Four of a Kind | 60 |
| Straight Flush | 75 |
| Crown Straight Flush | 95 |
| Color Straight | 55 |
| Long Straight | 100 |

현재 구현에는 별도 핸드 레벨 시스템이 아직 없다.

---

## 7. 카드(타일) 점수

각 타일은 Chips에 추가 점수를 제공한다.

---

## 8. 포함 관계

- Three of a Kind → Pair 포함
- Straight Flush → Straight + Flush 포함
- Full House → Pair 포함

---

## 9. Mult 규칙

- Mult는 모두 합산

---

## 10. XMult 규칙

- XMult는 모두 곱연산

---

## 11. 설계 원칙

### 원칙 1
Chips → Mult → XMult 순서 유지

### 원칙 2
- Chips = 안정
- Mult = 성장
- XMult = 폭발

### 원칙 3
후반은 Jester 중심

### 원칙 4
타일은 반드시 Rank + Suit를 동시에 가진다

---

## 12. 금지사항

- 계산 순서 변경 ❌
- Mult 곱연산 ❌
- XMult 합산 ❌
- 조건 없는 XMult ❌
- Suit/Rank 제거 ❌

---

## 13. 구현 예시

```dart
class Tile {
  final int number;
  final TileColor color;
  final Suit suit;
  final Rank rank;
}
```

---

## 14. 한 줄 정의

👉 점수는 핸드에서 시작하고, Jester로 증폭되며, XMult로 폭발한다.
