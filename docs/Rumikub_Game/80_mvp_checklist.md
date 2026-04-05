# 80_mvp_checklist.md

## 1. 목적
이 문서는 **Flutter + Flame 기반 MVP를 실제로 구현하기 위한 실행 체크리스트**를 정의한다.

👉 목표:
- 최소 기능으로 1런 플레이 가능
- Seed 기반 재현성 확보
- Jester 중심 빌드가 작동하는지 검증

---

# 2. MVP 범위 (고정)

## 포함
- 타일 덱 (52: 1~13 × 4색)
- 손패 8
- Hands 4 / Discards 3
- 포커 족보 판정 (타일 매핑)
- 점수 시스템 (Chips × Mult × XMult)
- Jester 슬롯 5
- 상점 (Jester만)
- Ante/Blind 진행 (1~5단계로 축소 가능)
- Seed 입력/표시

## 제외 (보류)
- Tarot / Planet / Spectral
- Voucher / Booster Pack
- 메타 업그레이드
- 챌린지/데일리
- 고급 애니메이션/사운드

---

# 3. 개발 순서 (Phase)

## Phase 1 — Core Logic (Pure Dart)
- [ ] Tile 모델 (number/color/rank/suit)
- [ ] HandEvaluator (Pair~Straight Flush)
- [ ] ScoreCalculator (정해진 순서)
- [ ] SeededRng 구현

**Done when**
- 콘솔에서 핸드 판정/점수 계산 검증
- 동일 Seed 재현

---

## Phase 2 — Run Loop
- [ ] RunContext / PlayerState / StageState
- [ ] 손패 보충 (8 유지)
- [ ] Hands/Discards 처리
- [ ] Blind 진행 / 목표 점수 체크

**Done when**
- UI 없이 1~5 Stage 시뮬레이션 가능

---

## Phase 3 — Jester System
- [ ] Jester 데이터(최소 8~12종) 로드
- [ ] 트리거 이벤트(onHandPlayed 등) 연결
- [ ] Chips/Mult/XMult 효과 적용
- [ ] 슬롯 5 관리 / 교체

**Done when**
- Jester 선택에 따라 점수 결과가 달라짐

---

## Phase 4 — Shop
- [ ] Jester 2~3개 제시
- [ ] 가격/구매/판매
- [ ] 리롤(기본 $5, +$1 증가)
- [ ] 다음 라운드로 복귀

**Done when**
- 상점 선택이 빌드 방향을 바꿈

---

## Phase 5 — Flame UI (세로 한 화면)
- [ ] 상단 HUD (점수/목표/Hands/Gold/Seed)
- [ ] 중단 Jester 슬롯 + 핸드 프리뷰
- [ ] 하단 손패 8 + 제출/버리기 버튼
- [ ] 선택 상태/예상 점수 표시

**Done when**
- 스크롤 없이 한 화면에서 1런 플레이 가능

---

## Phase 6 — Playtest 연결
- [ ] Seed 입력/복사
- [ ] 로그 출력(Seed/Stage/Score/Jesters)
- [ ] 10~20 런 수동 테스트

**Done when**
- 동일 Seed 재현 확인
- PLAYTEST.md 기준 4/6 이상 충족

---

# 4. 데이터/설정 파일

- [ ] hand_table.json (핸드 기본 Chips/Mult)
- [ ] jester_catalog.json (최소 세트)
- [ ] shop_config.json (가격/리롤)
- [ ] progression_config.json (Ante/Blind 배율)

---

# 5. 코드 구조 (요약)

- core/
  - models/ (Tile, Jester, State)
  - systems/ (Evaluator, Scoring, RNG)
- game/
  - run_context.dart
  - shop_state.dart
- ui/
  - hud/
  - hand/
  - jester_bar/

---

# 6. 체크리스트 (기능)

- [ ] Pair/Two Pair/Three/Straight/Flush/Full House/Four/Straight Flush 판정
- [ ] 점수 계산 순서 정확
- [ ] Jester 효과 적용 위치 정확
- [ ] 리롤 비용 증가/리셋 동작
- [ ] Hands/Discards 감소 및 종료 조건
- [ ] 동일 Seed 동일 결과

---

# 7. UX 체크리스트

- [ ] 손패 8개가 한눈에 보임 (스크롤 없음)
- [ ] 선택 타일 강조 표시
- [ ] 족보 이름 즉시 표시
- [ ] 제출 전 예상 점수 표시
- [ ] Jester 효과 요약 태그 표시

---

# 8. Done (MVP 완료 기준)

다음 조건을 모두 만족하면 MVP 완료:

1. 세로 한 화면에서 1런 플레이 가능
2. Ante 1~5 진행 가능
3. Jester 최소 8종 동작
4. 상점 구매/리롤 동작
5. Seed 재현 100%
6. PLAYTEST 기준 통과

---

# 9. 이후 단계

## 9.1 1차 확장 원칙

현재 프로젝트의 다음 단계는 **제거된 시스템을 먼저 설계하는 것**이 아니라,
**원본 Balatro의 Jester 150종을 전부 데이터로 가져오는 것**을 우선한다.

즉, 순서는 다음과 같다.

1. Jester 150종 전체 카탈로그 확보
2. 각 Jester의 효과 / 가격 / 희귀도 / 트리거 / 해금 조건 정리
3. 타일 시스템에 맞지 않는 요소 식별
4. 그 이후에만 변형 / 제거 / 대체 여부 결정

---

## 9.2 금지

- Jester 전체를 가져오기 전에 임의 삭제 ❌
- 타일 시스템에 맞지 않는다고 즉시 변형 ❌
- 원본 데이터 확인 없이 대체 설계 진행 ❌

---

## 9.3 이후 순서

- `22_jester_catalog.md` 작성 (150종 전체)
- 필요 시 `23_jester_compatibility.md` 작성
- 그 다음에만 제거된 시스템(Tarot/Planet 등)과의 충돌 검토
- 마지막에 대체 설계 문서 작성

---

# 10. 한 줄 정의

👉 **가장 적은 기능으로 Balatro의 핵심 재미(조합 + Jester + 점수 폭발)를 재현하는 것이 MVP의 목표다.**

