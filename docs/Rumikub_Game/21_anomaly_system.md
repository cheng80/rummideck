# 21_anomaly_system.md

## 1. 목적
이 문서는 Balatro의 **Joker 시스템을 1:1로 이식**하여, 프로젝트에서 사용하는 **Jester**의 규칙·용어·가격·희귀도·에디션·스티커·트리거를 정의한다.

> 원칙: **이름만 바꾸고(조커 → Jester), 구조와 수치는 최대한 유지한다.**

---

## 2. 용어 매핑

| 원본 용어 | 프로젝트 용어 |
|---|---|
| Joker | Jester |
| Suit (♣♦♥♠) | Tile Color → Suit 매핑 유지 |
| Rank (A,J,Q,K) | Tile Number → Rank 매핑 유지 |
| Edition | Edition (동일) |
| Sticker | Sticker (동일) |

---

## 3. 기본 구조

### 3.1 슬롯
- 기본 슬롯 수: **5** (원본과 동일)
- Negative 에디션을 통해 슬롯 +1 증가 가능

### 3.2 보유/교체
- 상점에서 구매
- 기존 Jester 판매 후 교체
- 판매가는 `floor(구매가 / 2)`, 최소 $1

---

## 4. 희귀도 (Rarity)

| 등급 | 비율(기본) |
|---|---|
| Common | 70% |
| Uncommon | 25% |
| Rare | 5% |
| Legendary | 일반 풀에서 직접 등장하지 않음 |

> Legendary는 특정 이벤트(예: The Soul)로만 획득

---

## 5. 가격 (Base Cost)

원본 범위 기준(개별 카드에 따라 상이):

| 등급 | 가격 범위 |
|---|---|
| Common | $1 ~ $6 |
| Uncommon | $4 ~ $8 |
| Rare | $7 ~ $10 |
| Legendary | $20 (직접 등장 제한) |

---

## 6. 에디션 (Edition)

각 Jester는 추가 속성(Edition)을 가질 수 있다.

| Edition | 효과 | 추가 비용 |
|---|---|---|
| Foil | +50 Chips | +$2 |
| Holographic | +10 Mult | +$3 |
| Polychrome | X1.5 Mult | +$5 |
| Negative | 슬롯 +1 | +$5 |

---

## 7. 스티커 (Sticker) — 고난도 전용

| Sticker | 효과 |
|---|---|
| Eternal | 판매/파괴 불가 |
| Perishable | 5 라운드 후 비활성화 |
| Rental | 라운드당 유지비, 구매가 $1 |

> 스테이크(난이도)에 따라 확률적으로 부여

---

## 8. 트리거 용어 (중요)

원본 Balatro의 조커 설명은 다음 트리거 키워드를 사용한다.

- **When Scored**: 점수 계산 시
- **When Played**: 핸드 제출 시
- **On Held**: 손패에 들고 있을 때
- **On Discard**: 버릴 때
- **On Blind Selected**: 라운드 시작 시
- **Contains**: 특정 핸드를 포함할 때
- **Is**: 정확히 해당 핸드일 때
- **In Deck**: 덱에 존재할 때
- **Create / Destroy / Add / Gains / Retrigger**: 상태 변경/이벤트

> 구현 시 이 키워드를 **이벤트 시스템으로 그대로 반영**해야 한다.

---

## 9. 효과 분류 (역할 기준)

모든 Jester 효과는 아래 4가지 중 하나로 귀속된다.

### 9.1 Chips 계열
- 기본 점수 증가
- 예: "+50 Chips"

### 9.2 Mult 계열
- 합산 배수 증가
- 예: "+10 Mult"

### 9.3 XMult 계열
- 곱연산 배수
- 예: "X2"

### 9.4 규칙 변형 계열
- 게임 규칙 자체 변경
- 예: "4장으로 Straight 가능", "다른 조커 복사"

---

## 10. Suit / Rank 호환 (타일 시스템 필수 조건)

### 10.1 Suit 매핑
- Red → Heart (♥)
- Blue → Spade (♠)
- Yellow → Diamond (♦)
- Black → Club (♣)

### 10.2 Rank 매핑
- 1 → Ace
- 11 → Jack
- 12 → Queen
- 13 → King

> 이 매핑이 있어야 **Suit 기반 조커 / Face Card 조커가 정상 동작**한다.

---

## 11. Jester 데이터 모델 (권장)

```dart
class JesterDefinition {
  final String id;
  final String name;
  final String originalName;

  final Rarity rarity;
  final int baseCost;

  final Edition? edition;
  final StickerSet stickers;

  final TriggerType trigger;
  final EffectPayload effect;
}
```

---

## 12. 구현 원칙

### 원칙 1
원본 조커 효과를 **임의로 단순화하지 않는다**

### 원칙 2
Suit / Rank 조건은 **타일 매핑으로 그대로 유지**

### 원칙 3
Jester 효과는 점수 계산 파이프라인의 각 단계에 정확히 삽입

### 원칙 4
Jester는 핸드보다 후반 영향력이 커야 한다

---

## 13. 금지사항

- 조건 없는 XMult ❌
- 모든 핸드에 동일 적용 ❌
- 조커 효과 임의 수정 ❌
- RNG 경로 외 효과 발생 ❌

---

## 14. 한 줄 정의

👉 **Jester는 점수를 더하는 시스템이 아니라, 점수 계산 규칙을 바꾸는 엔진이다.**
