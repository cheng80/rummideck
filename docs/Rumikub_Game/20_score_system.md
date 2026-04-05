# 20_score_system.md

## 1. 목적
이 문서는 Balatro의 **점수 계산 시스템을 그대로 유지**하면서, 입력을 타일(1~13 × 4색)로 치환했을 때의 **완전한 계산 규칙**을 정의한다.

## 1.1 현재 구현 기준 메모 (2026-04-06)

- 아래 표와 수식은 **현재 코드의 실제 계산식**을 기준으로 적는다.
- 현재 구현은 핸드별 **기본 Mult를 두지 않고**, `Mult = 1 + Jester/Anomaly 합산`으로 계산한다.
- 타일 숫자 보너스는 `floor(선택 타일 숫자 합 × 0.2)` 이며, Chips 단계에 더한다.
- 현재 구현 점수식:

`Final Score = (Base Chips + Number Bonus + Jester Chips) × (1 + Jester Mult) × Jester XMult`

---

## 2. 핵심 점수 공식

Final Score = Chips × Mult × XMult

- Chips: 기본 점수
- Mult: 합산 배수
- XMult: 곱연산 배수

---

## 3. 점수 계산 순서 (절대 규칙)

1. 핸드 판정
2. 제출 타일 중 점수 계산 대상 조합 타일 확정
3. Hand 기본 Chips 적용
4. Number Bonus 적용
5. Jester Chips 적용
6. Jester Mult 합산
7. Jester XMult 곱연산
8. 최종 점수 산출

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

| Hand | Base Chips | Balatro 원형 비교 |
|------|-----------:|
| High Tile | 5 | High Card `5 x 1` 기반 |
| Pair | 10 | Pair `10 x 2` 기반 |
| Two Pair | 20 | Two Pair `20 x 2` 기반 |
| Three of a Kind | 30 | Three of a Kind `30 x 3` 기반 |
| Straight | 35 | 프로젝트 확장치, Balatro 원형은 `30 x 4` |
| Crown Straight | 45 | 프로젝트 확장 핸드 |
| Flush | 40 | 프로젝트 확장치, Balatro 원형은 `35 x 4` |
| Full House | 50 | 프로젝트 확장치, Balatro 원형은 `40 x 4` |
| Four of a Kind | 60 | Four of a Kind `60 x 7` 기반 |
| Straight Flush | 75 | 프로젝트 확장치, Balatro 원형은 `100 x 8` |
| Crown Straight Flush | 95 | 프로젝트 확장 핸드 |
| Color Straight | 55 | 프로젝트 확장 핸드 |
| Long Straight | 100 | 프로젝트 확장 핸드 |

현재 코드에는 핸드별 고정 Mult가 없고, Balatro 원형과 같은 `Base Chips + Base Mult` 이중 구조도 아직 완전히 반영되지 않았다.

---

## 6. 핸드 레벨업

- Balatro 원형에서 포커 핸드 레벨은 **Planet 카드 등 업그레이드 효과**로 상승한다.
- 현재 코드의 “사용 횟수 기반 레벨업”은 원형 복제 기준으로는 **임시 구현**이다.
- `Run Info` 표가 레벨을 보여주더라도, 최종 정답은 Planet/업그레이드 시스템 연동이다.

---

## 7. 제출 타일 처리 규칙

- 플레이어는 완성 조합이 없는 타일 묶음도 `Play`할 수 있다.
- 점수 계산은 제출된 전체 타일이 아니라, 그 안에서 판정된 **최고 우선순위 조합 1개**에 대해서만 수행한다.
- 조합에 포함되지 않은 나머지 제출 타일은 점수 계산에 기여하지 않으며, 결과적으로 `Discard`와 같은 소모 처리를 받는다.
- 유효 조합이 전혀 없을 때는 가장 높은 숫자 타일 1장을 기준으로 `High Tile` 점수를 계산한다.
- `Number Bonus` 역시 **실제 점수 계산 대상으로 확정된 타일들**만 기준으로 합산한다.

예:
- `7, 7, 3` → `Pair(7,7)`만 점수 계산, `3`은 버려짐
- `2, 5, 11` → `11` 기준 `High Tile`

---

## 8. 카드(타일) 점수

각 타일은 Chips에 추가 점수를 제공한다.

---

## 9. 포함 관계

- Three of a Kind → Pair 포함
- Straight Flush → Straight + Flush 포함
- Full House → Pair 포함

---

## 10. Mult 규칙

- Mult는 모두 합산

---

## 11. XMult 규칙

- XMult는 모두 곱연산

---

## 12. 설계 원칙

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

## 13. 금지사항

- 계산 순서 변경 ❌
- Mult 곱연산 ❌
- XMult 합산 ❌
- 조건 없는 XMult ❌
- Suit/Rank 제거 ❌

---

## 14. 구현 예시

```dart
class Tile {
  final int number;
  final TileColor color;
  final Suit suit;
  final Rank rank;
}
```

---

## 15. 한 줄 정의

👉 점수는 핸드에서 시작하고, Jester로 증폭되며, XMult로 폭발한다.
