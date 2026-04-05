# 30\_progression.md

## 1. 목적

이 문서는 Balatro의 \*\*진행 구조(Ante / Blind / Stake / Seed)\*\*를 그대로 유지하면서, 프로젝트에 적용되는 **완전한 진행/난이도 시스템**을 정의한다.

> 원칙: **구조와 규칙은 원본과 동일, 표시 용어만 단순화 가능**

---

# 2. 핵심 개념

## 2.1 용어 매핑 (표시용)

| 원본 용어       | 프로젝트 표시         |
| ----------- | --------------- |
| Ante        | Ante            |
| Blind       | Blind           |
| Small Blind | Small Blind     |
| Big Blind   | Big Blind       |
| Boss Blind  | Boss Blind      |
| Stake       | Difficulty Tier |

> 내부 로직/데이터 키는 Ante/Blind/Stake 유지. UI에서도 가능하면 동일 용어를 우선 사용한다.

---

## 2.2 기본 진행 단위

하나의 Ante는 다음 3개의 Blind로 구성된다.

1. Small Blind (Easy)
2. Big Blind (Mid)
3. Boss Blind (Boss)

플레이어는 이 3단계를 순서대로 통과해야 다음 Ante로 진행한다.
Small / Big는 스킵 가능하고 Boss는 스킵 불가다.

---

# 3. Blind(라운드) 규칙

## 3.1 목표 점수

각 Blind에는 목표 점수(Target Score)가 있으며, 플레이어는 제한된 Hands 내에 이를 초과해야 한다.

- 실패 시 런 종료

---

## 3.2 배율 (기본)

| Blind       | 배율               |
| ----------- | ---------------- |
| Small Blind | 1.0 × Base |
| Big Blind   | 1.5 × Base |
| Boss Blind  | 일반적으로 2.0 × Base |

> 일부 Boss는 예외 배율 사용 (예: 4×, 1× 등)

---

## 3.3 보상금

| Blind | 보상  |
| ----- | --- |
| Small | \$3 |
| Big   | \$4 |
| Boss  | \$5 |

> 현재 코드의 `10 + (남은 Hands × 5)` 일괄 보상은 Balatro 원형과 다른 임시 구현이다.

---

## 3.4 스킵 규칙

- Small / Big Blind는 스킵 가능
- 스킵 시 Tag 보상 획득 (프로젝트에서는 추상화 가능)
- Boss Blind는 스킵 불가

---

# 4. Ante(스테이지) 구조

## 4.1 기본 흐름

```text
Ante 1 → Ante 2 → ... → Ante 8
```

- 각 Ante는 3개의 Blind로 구성
- Ante 8 Boss는 **Finisher Blind**

---

## 4.2 Endless

- Ante 8 이후 Endless 진입 가능
- 16, 24, 32 등 특정 구간마다 Finisher Blind 재등장

---

# 5. Hands / Discards / Hand Size

## 5.1 기본 값

- Hands per round: 4
- Discards per round: 3
- Hand Size: 8

---

## 5.2 특수 변경

특정 Boss 또는 Jester 효과에 의해 변경 가능

예:

- Hands 증가
- Discards 감소
- Hand Size 변경

---

# 6. Stake (난이도 단계)

Balatro의 난이도는 Stake 시스템으로 구성된다.

## 6.1 전체 단계

| Tier | 이름     | 효과                     |
| ---- | ------ | ---------------------- |
| 1    | White  | 기본                     |
| 2    | Red    | Small Blind 보상 제거      |
| 3    | Green  | 점수 상승 속도 증가            |
| 4    | Black  | 30% Eternal Sticker    |
| 5    | Blue   | Discard -1             |
| 6    | Purple | 점수 상승 속도 증가            |
| 7    | Orange | 30% Perishable Sticker |
| 8    | Gold   | 30% Rental Sticker     |

---

## 6.2 누적 규칙

- 각 Stake 효과는 누적된다
- 높은 난이도일수록 제약이 증가한다

---

# 7. Boss Blind

## 7.1 역할

Boss Blind는 단순히 점수가 높은 라운드가 아니라, **플레이 스타일을 강제로 바꾸는 제약 조건**을 가진다.

---

## 7.2 예시 효과

- 특정 Suit 무효화
- 특정 핸드 점수 감소
- Discard 제한
- Hands 감소

---

## 7.3 설계 원칙

- 특정 빌드 카운터
- 단일 전략 강제 금지

---

# 8. Seed (시드 시스템)

## 8.1 목적

- 재현성 확보
- 밸런스 테스트
- 유저 공유

---

## 8.2 규칙

동일 결과 조건:

- 동일 Seed
- 동일 Stake
- 동일 Deck
- 동일 입력 순서
- 동일 스킵/상점 선택

---

## 8.3 시드 영향 범위

- 덱 셔플
- 상점 등장
- Boss 선택
- Tag
- Jester 랜덤 효과

---

## 8.4 금지

- 프레임 기반 RNG ❌
- 시간 기반 RNG ❌

---

# 9. 진행 흐름 요약

```text
Ante 시작
→ Small Blind
→ 상점
→ Big Blind
→ 상점
→ Boss Blind
→ 상점
→ 다음 Ante
```

## 9.1 현재 코드와의 불일치

- 현재 코드는 stage 1~5 직진 구조라 Ante/Blind 3단 구분이 없다.
- 현재 코드는 Boss 제약과 스킵 보상이 분리되어 있지 않다.
- 재작성 시 `ante`, `blindType`, `blindReward`, `isSkipped`, `blindModifier` 상태를 분리해야 한다.

---

# 10. 설계 원칙

### 원칙 1

진행 구조는 Balatro 그대로 유지

### 원칙 2

난이도는 점수 증가 + 제약 증가로 구성

### 원칙 3

Boss는 빌드를 흔드는 역할

### 원칙 4

Seed 기반 완전 재현성 유지

---

# 11. 금지사항

- Ante 구조 변경 ❌
- Blind 3단계 구조 제거 ❌
- Stake 제거 ❌
- Seed 제거 ❌

---

# 12. 한 줄 정의

👉 진행은 점점 어려워지고, 규칙은 점점 제한되며, 플레이어는 그 안에서 빌드를 완성한다.
