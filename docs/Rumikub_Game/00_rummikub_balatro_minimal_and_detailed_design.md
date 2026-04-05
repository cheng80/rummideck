# 루미큐브 기반 로그라이크 점수 빌딩 게임 — 최소·상세 설계 (MVP 기준)

> 본 문서는 **요약 설계서**다. 세부 룰·수치·금지 사항은 아래 문서가 우선한다.  
> **작업 세션 진입**: 저장소 루트 `START_HERE.md` → `PLAN_CHECKLIST.md` → 필요 시 본 폴더 문서 순서.  
> `10_game_rules.md` → `20_score_system.md` → `21_anomaly_system.md` → `30_progression.md` → `40_shop_system.md` → `50_architecture.md` → `60_content_rules.md`

---

## 한 줄 정의

**Balatro의 규칙·점수·진행을 유지하고, 카드 대신 타일(1~13 × 4색)로 플레이하며, 조커는 Jester(변칙 타일)로 부르는 게임이다.**

(표현은 포커/발라트로에 가깝고, 입력만 타일 시스템이다.)

---

## 1. 핵심 설정

| 항목 | 값 |
|------|-----|
| 손패 크기 | 8 |
| 라운드당 Hands (플레이) | 4 |
| 라운드당 Discards (버리기) | 3 |
| 족보 판정 | Balatro/포커 기준 (5장 핸드) |
| 점수 | `Final = Chips × Mult × XMult` (순서 고정) |
| 변칙 타일 | Jester, **슬롯 5** (Negative 에디션 등으로 확장 가능) |
| 상점 | **Jester 전용** (Tarot/Planet/Voucher/Booster 등 제거) |

---

## 2. 타일 시스템

- **덱**: 숫자 1~13 × 색 4 = **52타일** (표준 52매 대응).
- **색상**: Red / Blue / Yellow / Black — 표기 예: R7, B5, Y10, K2.
- **Rank 매핑**: 1→Ace, 11→J, 12→Q, 13→K, 그 외 Number.
- **Suit 매핑**: Red→♥, Blue→♠, Yellow→♦, Black→♣.

모든 타일은 구현상 **number + color**와 함께 **rank + suit**를 동시에 갖는다 (Jester 조건·점수 파이프라인에 필요).

---

## 3. 족보 (핸드)

내부 규칙은 **Balatro와 동일** (포커 족보). 높은 족보가 낮은 족보를 덮으며, 포함 관계·Straight에서 A의 양쪽 사용 등은 `10_game_rules.md` 따름.

### 3.1 일반 족보 (요약)

| Hand | 조건 요약 |
|------|-----------|
| High Card | 유효 조합 없음 |
| Pair | 같은 숫자 2개 |
| Two Pair | Pair 2종 |
| Three of a Kind | 같은 숫자 3개 |
| Straight | 연속 5개 |
| Flush | 같은 색 5개 |
| Full House | Three + Pair |
| Four of a Kind | 같은 숫자 4개 |
| Straight Flush | 같은 색 + 연속 5개 |
| Royal Flush | 같은 색 10~A |

### 3.2 비밀 족보

Five of a Kind, Flush House, Flush Five 등 — 전부 `10_game_rules.md` 기준.

---

## 4. 점수 구조

### 4.1 공식

`Final Score = Chips × Mult × XMult`

- **Mult**: 전부 **합산**
- **XMult**: 전부 **곱연산**
- 계산 **순서는 변경 불가** (`20_score_system.md`, `60_content_rules.md`)

### 4.2 계산 파이프라인 (요약)

1. 핸드 판정  
2. 핸드 기본 Chips / Mult  
3. 타일(카드) Chips 가산  
4. Jester Chips  
5. Mult 합산  
6. XMult 곱연산  
7. 최종 점수  

### 4.3 핸드 기본 점수 (Level 1 예시)

| Hand | Chips | Mult |
|------|------:|-----:|
| High Card | 5 | 1 |
| Pair | 10 | 2 |
| Two Pair | 20 | 2 |
| Three of a Kind | 30 | 3 |
| Straight | 30 | 4 |
| Flush | 35 | 4 |
| Full House | 40 | 4 |
| Four of a Kind | 60 | 7 |
| Straight Flush | 100 | 8 |
| Royal Flush | 100 | 8 |
| Five of a Kind | 120 | 12 |
| Flush House | 140 | 14 |
| Flush Five | 160 | 16 |

핸드 레벨 상승 시 Chips/Mult 증가 — 상세는 `20_score_system.md`.

---

## 5. Jester (변칙 타일)

- Balatro **Joker를 1:1 이식**하는 것을 목표로 하며, 프로젝트에서는 **Jester**라 부른다 (`21_anomaly_system.md`).
- **희귀도·가격·에디션·스티커·트리거(When Scored 등)** 는 해당 문서 및 데이터(JSON)를 따른다.
- 효과는 **Chips / Mult / XMult / 규칙 변형** 중 역할이 분명해야 하며, 조건 없는 XMult·전 핸드 만능 버프 등은 금지 (`60_content_rules.md`).

### 데이터 위치

개별 Jester 정의는 문서가 아니라 **JSON**으로 관리한다 (`22_jester_catalog.md`).  
예: 저장소 내 `data/common/jesters_common.json`.

---

## 6. 진행 구조

- **Ante(스테이지 티어)** × **Blind 3종** (Small / Big / Boss 대응) — `30_progression.md`.
- Easy/Mid는 **스킵 가능**, Boss는 **필수**.
- 각 Blind마다 **목표 점수**와 보상 골드가 있으며, Blind별 배율·보상 표는 진행 문서 따름.
- **Stake(난이도)**·**Seed**로 재현성 확보 — 시간/프레임 기반 RNG 금지.

구 예시로만 쓰이던 단순 식 `TargetScore(n) = 100 × (1.6^n)` 는 **폐기**한다. 실제 목표 점수·Ante 스케일은 Balatro식 블라인드 구조를 따른다.

---

## 7. 상점

- 라운드 종료 후 상점 진입.
- 본 프로젝트에서는 **Jester만** 판매 (나머지 소비재 슬롯은 제거).
- 리롤: 기본 **$5** 시작, 리롤마다 **+$1**, 상점 진입 시 비용 초기화 등 — `40_shop_system.md`.
- 구매가·판매가·슬롯 상한(보유 **최대 5**)은 상점·Jester 문서 따름.

---

## 8. 아키텍처·구현 원칙 (요약)

- **Flutter + Flame**: UI는 위젯/Flame, 게임 규칙·점수는 **Pure Dart**.
- **RunContext / SeededRng**: 모든 RNG는 시드 기반 단일 경로 (`50_architecture.md`).
- **이벤트 기반** Jester 트리거 (onHandPlayed, onCardScored 등).
- UI: 세로 한 화면·스크롤 없이 핵심 정보 동시 표시 목표 (`50_architecture.md` 11절).

---

## 9. 제거·비활성 시스템

Tarot, Planet, Spectral, Voucher, Booster Pack 등 — `10_game_rules.md` 제거 목록과 동일. MVP 범위는 `80_mvp_checklist.md`.

---

## 10. 설계 핵심 요약

| 축 | 내용 |
|----|------|
| 입력 | 타일 (색 + 숫자, Rank/Suit 병행) |
| 족보 | 포커/Balatro 핸드 그대로 |
| 점수 | Chips → Mult → XMult |
| 성장 | Jester + 상점 + 진행(Ante/Blind/Stake) |
| 재현 | Seed 고정 RNG |

---

## 11. 문서 맵 (상세 룰)

| 문서 | 내용 |
|------|------|
| `01_plans.md` | 방향 요약 (실행 체크는 루트 `PLAN_CHECKLIST.md`) |
| `10_game_rules.md` | 족보·턴·스테이지·Jester·금지 |
| `20_score_system.md` | 점수 순서·핸드 표·Mult/XMult |
| `21_anomaly_system.md` | Jester 희귀도·에디션·트리거 |
| `30_progression.md` | Ante/Blind/Stake/Seed |
| `40_shop_system.md` | 상점·리롤·경제 |
| `50_architecture.md` | RunContext·이벤트·UI |
| `60_content_rules.md` | 밸런스·금지 (최우선 제약) |
| `22_jester_catalog.md` | Jester 인덱스·JSON 규약 |
| `70_playtest.md` / `80_mvp_checklist.md` | 검증·체크리스트 |

---

## 12. 한 줄 정의 (반복)

**포커처럼 읽히고, Balatro처럼 돌아가며, 타일로 제출하고, Jester로 빌드를 완성하는 게임이다.**
