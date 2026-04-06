# 50_architecture.md

## 1. 목적
이 문서는 Flutter + Flame 기반으로 Balatro 구조를 그대로 구현하기 위한 **전체 아키텍처 설계**를 정의한다.

👉 목표:
- Balatro의 이벤트 기반 구조 유지
- Seed 기반 재현성 보장
- UI / 로직 완전 분리

---

# 2. 전체 아키텍처

## 2.1 레이어 구조

```
UI Layer (Flutter Widgets)
↓
Game Layer (Flame)
↓
Logic Layer (Pure Dart)
↓
Data Layer (Config / Seed / State)
```

---

## 2.2 핵심 원칙

### 원칙 1
로직은 UI를 모른다

### 원칙 2
모든 계산은 턴 단위

### 원칙 3
모든 랜덤은 Seed 기반

---

# 3. 핵심 상태 구조

## 3.1 RunContext

```dart
class RunContext {
  final int seed;
  final SeededRng rng;

  PlayerState player;
  BlindState blind;
  ShopState? shop;
}
```

---

## 3.2 PlayerState

```dart
class PlayerState {
  List<Tile> hand;
  List<Jester> jesters;

  int handsLeft;
  int discardsLeft;

  int gold;
}
```

---

## 3.3 StageState

```dart
class StageState {
  int ante;
  BlindType blindType;

  int targetScore;
  int currentScore;
}
```

> 현재 코드의 `stageIndex` 단일 상태는 임시 구현이며, 재작성 목표는 `ante + blindType` 분리다.

---

# 4. 타일 모델

```dart
class Tile {
  final int number;
  final TileColor color;
  final Suit suit;
  final Rank rank;
}
```

---

# 5. Jester 모델

```dart
class Jester {
  final String id;
  final Rarity rarity;

  int cost;

  void onScore(...);
  void onPlay(...);
  void onDiscard(...);
}
```

---

# 6. 이벤트 시스템 (핵심)

Balatro는 이벤트 기반 구조다.

## 이벤트 목록

- onBlindSelected
- onHandPlayed
- onCardScored
- onHandScored
- onDiscard
- onRoundEnd
- onShopEnter

👉 모든 Jester는 이벤트에 반응한다

---

# 7. 게임 루프

```
Start Run
→ Select Blind
→ Deal Hand
→ Player Action
→ Evaluate Hand
→ Calculate Score
→ Apply Jester Effects
→ Update Score
→ Check Clear
→ Repeat
→ Enter Shop
```

---

# 8. 점수 처리 흐름

```dart
ScoreBreakdown calculateScore(...) {
  // 1. hand
  // 2. chips
  // 3. jester chips
  // 4. mult
  // 5. xmult
}
```

---

# 9. RNG 시스템

## 9.1 Seeded RNG

```dart
class SeededRng {
  final Random _r;

  SeededRng(int seed) : _r = Random(seed);

  int nextInt(int max);
  double nextDouble();
}
```

## 9.2 규칙

- Random() 직접 사용 금지
- 모든 랜덤은 여기서

---

# 10. 상점 구조

```dart
class ShopState {
  List<Jester> offers;
  int rerollCost;
}
```

---

# 11. UI 구조 (세로 / 아이폰 한 화면 고정)

이 프로젝트의 세로형 UI는 **스크롤 없이 한 화면에 모든 핵심 정보와 입력을 동시에 표시**하는 것을 목표로 한다.

## 11.1 전제
- Portrait 고정
- 스크롤 금지
- 한 화면에 HUD + Jester + Hand + Action 모두 표시

## 11.2 화면 구역 분할

### 상단 (HUD)
- Ante / Blind
- 현재 점수 / 목표 점수
- 남은 Hands / Discards
- Gold
- Run Info / Options

### 중단 (엔진/해석 영역)
- Jester 슬롯 (항상 표시)
- 현재 선택 핸드 이름
- 예상 점수 프리뷰
- Boss 제약 요약

### 하단 (입력 영역)
- 손패 8~16개 (1줄 또는 2줄)
- 제출 버튼
- 버리기 버튼
- 선택 해제 버튼

## 11.3 배치 원칙
- 상단: 상태/정보
- 중단: 빌드/효과 해석
- 하단: 조작

## 11.4 손패 표시 규칙
- 8장을 **스크롤 없이** 모두 표시
- 9~16장은 2줄 압축 배치 허용
- 1줄 또는 2줄 압축 배치 허용
- 선택 상태는 색상/테두리/확대로 명확히 표시

## 11.5 Jester 표시 규칙
- 모든 Jester는 항상 보인다
- 길게 누르기 → 상세 설명
- 핵심 효과는 요약 태그로 표시

## 11.6 액션 버튼 규칙
- 엄지 도달 가능한 하단 고정
- 제출 전 예상 점수 표시 필수

## 11.7 금지
- 스크롤 UI ❌
- 손패 일부가 화면 밖으로 나가는 구조 ❌
- Jester를 별도 화면에서만 확인 ❌
- 점수/HUD와 손패가 동시에 보이지 않는 구조 ❌

## 11.8 상점 오버레이 (구현, 2026-04)

- 전투 레이아웃(§11.2)과 **별도**: 상점은 `ShopModalOverlay`로 **전체 프레임을 덮는** 모달(기존 상단 스트립 포함). 본문은 **상단 약 1/3** 보유·골드·제스터, **하단 약 2/3** 구매 목록(리스트 스크롤)·리롤·다음 스테이지.
- 상점에서만 손패/HUD가 가려지는 것은 의도된 예외(상점 전용 화면).
- 디버그: `kDebugMode`에서만 `DBG·상점`으로 상점 UI 즉시 호출(릴리스 미포함).

# 12. 성능 원칙

- 프레임 계산 금지
- 이벤트 기반 처리
- 상태 캐싱

---

# 13. 설계 원칙

### 원칙 1
이벤트 기반 구조 유지

### 원칙 2
Seed 재현성 보장

### 원칙 3
로직 / UI 완전 분리

---

# 14. 금지사항

- UI에서 로직 계산 ❌
- Random 직접 호출 ❌
- 프레임 기반 점수 계산 ❌

---

# 15. 한 줄 정의

👉 이 구조는 Balatro의 이벤트 기반 엔진을 Flutter + Flame으로 재현하기 위한 최소 구조다.
