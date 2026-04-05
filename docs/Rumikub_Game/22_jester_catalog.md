# 22_jester_catalog.md

## 1. 목적

이 문서는 Balatro의 **Jester 150종 전체를 관리하기 위한 카탈로그 인덱스 문서**다.

이 문서의 역할은 다음과 같다.

- Jester 데이터 구조를 정의한다.
- Jester 분류 체계를 정의한다.
- 현재 기준 데이터 파일 위치를 명시한다.
- 문서/코드/데이터 간 참조 기준을 고정한다.

> 원칙: **설명은 문서에 두고, 실제 개별 Jester 데이터는 JSON 파일로 분리한다.**

---

## 2. 왜 JSON 분리 구조를 쓰는가

Jester 150종 전체를 문서 하나에 전부 넣으면 다음 문제가 생긴다.

- 토큰 사용량 과다
- 수정/검수 난이도 상승
- Codex/Cursor 활용성 저하
- 특정 카드 1장만 수정하기 어려움
- diff 관리 불편

따라서 설명은 문서에 두고, 실제 데이터는 JSON으로 분리한다.

현재 작업 방식은 아래와 같다.

```plaintext
docs/
  22_jester_catalog.md

current_data/
  jesters_common.json

future_target/
  data/
    jesters/
      common.json
      uncommon.json
      rare.json
      legendary.json

schemas/
  jester.schema.json
```

> 현재는 **`jesters_common.json` 하나로 Common 61개를 모아둔 상태**이며,
> 이후 전체 구조가 정리되면 최종 경로를 다시 잡는다.

---

## 3. 전체 분류

원본 Balatro 기준:

- Common: 61
- Uncommon: 64
- Rare: 20
- Legendary: 5
- Total: 150

---

## 4. 현재 데이터 파일 운영 규칙

### 4.1 현재 상태
- `jesters_common.json`
  - Common Jester 61종을 1차 확정하여 모아둔 파일

### 4.2 이후 예정
추후 경로와 파일 체계가 정리되면 아래처럼 확장한다.

- `common.json`
- `uncommon.json`
- `rare.json`
- `legendary.json`

### 4.3 현재 문서의 기준
이 문서는 **현재 기준 파일명인 `jesters_common.json`을 우선 기준**으로 본다.

---

## 5. Jester 데이터 필드 정의

모든 Jester는 아래 필드를 가진다.

```json
{
  "id": "unique_string_id",
  "name": "Original Jester Name",
  "displayName": "Project Display Name",
  "rarity": "common | uncommon | rare | legendary",
  "baseCost": 0,
  "effectText": "Original effect text",
  "trigger": "onScore | onPlay | onDiscard | passive | onBlindSelected | etc",
  "editionAllowed": true,
  "stickersAllowed": true,
  "unlockCondition": "text or null",
  "notes": "additional implementation notes"
}
```

---

## 6. 권장 확장 필드

원본 효과를 코드와 연결하기 위해 아래 필드를 추가할 수 있다.

```json
{
  "effectType": "chips_bonus | mult_bonus | xmult_bonus | rule_modifier | economy | copy | retrigger",
  "conditionType": "pair | flush | straight | suit_scored | face_card | held_card | blind_selected | none",
  "conditionValue": "optional detail",
  "value": 0,
  "xValue": 1.0
}
```

> `effectText`는 원문 보존용이고, 구조화 필드는 구현용이다.

---

## 7. Suit / Rank 호환 규칙

Jester 중 상당수는 Suit / Rank / Face Card / Number Card 조건을 사용한다.

따라서 JSON 데이터는 아래 전제를 따른다.

### Suit 매핑
- Red → Heart
- Blue → Spade
- Yellow → Diamond
- Black → Club

### Rank 매핑
- 1 → Ace
- 11 → Jack
- 12 → Queen
- 13 → King

즉, JSON의 조건은 **원본 카드 기준으로 기록**하고, 실제 게임 구현 단계에서 타일 시스템으로 해석한다.

---

## 8. 문서와 데이터의 역할 분리

### 8.1 21_anomaly_system.md
- Jester 시스템 규칙 설명
- 희귀도/가격/에디션/스티커/트리거 정의

### 8.2 22_jester_catalog.md
- 전체 분류
- 데이터 구조
- 현재 기준 파일 위치
- 관리 규칙

### 8.3 현재 데이터 파일
- `jesters_common.json`
  - 현재 검수 완료된 Common 61종 데이터

### 8.4 이후 데이터 파일
- `data/jesters/*.json`
  - 최종 디렉토리 구조 확정 후 이동 예정

---

## 9. 작성 순서

현재 단계의 작업 순서는 아래와 같다.

1. `jester.schema.json` 정의
2. Common 데이터 수집
3. Common 데이터 검수
4. `jesters_common.json`으로 Common 61종 1차 확정
5. 이후 uncommon / rare / legendary 작업 진행
6. 전체 경로 재정리 및 최종 병합

---

## 10. 검수 원칙

### 원칙 1
원본 이름과 효과 문구는 최대한 보존한다.

### 원칙 2
효과를 임의로 요약/축약하지 않는다.

### 원칙 3
Jester 전체를 확보하기 전에는 변형/제거를 논의하지 않는다.

### 원칙 4
문서와 데이터가 충돌하면 데이터 파일을 우선 수정한다.

---

## 11. 금지사항

- 150종 전체를 이 문서 본문에 직접 나열 ❌
- 원본 효과 문구 임의 단순화 ❌
- JSON 없이 문서만으로 관리 ❌
- 전체 확보 전 임의 삭제/변형 ❌

---

## 12. 다음 단계

현재 기준 다음 작업은 아래 순서를 따른다.

1. `jesters_common.json` 유지
2. uncommon 데이터 수집 및 검수
3. rare / legendary 데이터 수집 및 검수
4. 전체 디렉토리 구조 재정리
5. 최종 파일명/경로 확정

---

## 13. 한 줄 정의

👉 **이 문서는 Jester 150종 전체를 효율적으로 보존·검수·구현하기 위한 인덱스 문서다.**
