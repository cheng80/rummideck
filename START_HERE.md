# 작업 세션 시작 — 여기부터 읽기

> **역할**: 새 대화(또는 작업 재개)를 열 때 **가장 먼저** 열 문서다.  
> 코딩 규칙은 `CURSOR.md` / `AGENTS.md`에 두고, **무엇을 하다 멈췄는지·다음에 무엇을 할지**는 이 문서가 안내한다.

---

## 대화 시작 시 한 줄

**「`START_HERE.md` → `PLAN_CHECKLIST.md`를 보고 다음 작업을 이어가자.」**

---

## 1. 필수 순서 (짧게)

| 순서 | 문서 | 할 일 |
|:---:|:---|:---|
| 1 | **이 파일** (`START_HERE.md`) | 아래 §2 흐름만 확인 |
| 2 | [`PLAN_CHECKLIST.md`](PLAN_CHECKLIST.md) | 체크 안 된 항목 중 **다음에 할 일** 확정 |
| 3 | [`docs/current-implementation-status.md`](docs/current-implementation-status.md) | 구현/보류 스냅샷이 체크리스트와 맞는지 |
| 4 | [`docs/Rumikub_Game/01_plans.md`](docs/Rumikub_Game/01_plans.md) | 방향 요약·게임성 검증 목표 상기 |

작업 내용이 **룰·수치·Jester**에 닿으면 `docs/Rumikub_Game/` 아래 문서를 **필요한 만큼만** 연다. 우선순위는 설계 요약 [`00_rummikub_balatro_minimal_and_detailed_design.md`](docs/Rumikub_Game/00_rummikub_balatro_minimal_and_detailed_design.md)의 문서 맵 표를 따른다.

현재 아키텍처 상태:
- **Riverpod 리팩토링 완료** (2026-04-06): `game_view.dart`를 7개 독립 파일로 분리, 모든 게임 위젯을 `ConsumerWidget`/`ConsumerStatefulWidget`으로 전환. controller prop 전달 완전 제거. 상세: `docs/refactoring-plan.md`
- **UI 코드 품질 개선 완료** (2026-04-06): `AppColors` 71색상 중앙 집중, `SubPanelSurface` 공통 위젯, build 메서드 분리, 타입 안전화, 미사용 필드/파라미터 제거
- **iPad/iPhone 반응형 레이아웃 완료** (2026-04-06): `FittedBox` 스케일링으로 동일 비율 렌더링. iPhone은 화면 전체 사용, iPad는 기준 해상도(402×778) 스케일링
- 드로우 애니메이션 중에는 최상단 투명 입력 차단 레이어가 동작한다. 제출/점수/클리어 연출도 같은 락 구조를 쓰고 있다.
- `Play Hand` 후 흐름은 `제출 -> 점수 연출 -> 최종 점수 반영 -> (리필 또는 상점/게임오버)` 순서.
- 점수 연출은 **제출된 실제 중앙 타일 스냅샷** 위에 하이라이트 박스와 숫자 팝업을 얹는 구조.
- 현재 가장 많이 남은 UI 과제는 **점수 팝업 위치/타이밍/Jester 반응** 튜닝이다.

다음 작업 우선순위:
1. 점수 연출 마감: 카드별 숫자 팝업 위치, 속도, 최종 점수 표시 타이밍 튜닝
2. Jester 반응 추가: 점수 기여 Jester 하이라이트/점멸
3. 완전 순회 검증: 첫 전투 ~ 1차 보스까지 실제 플레이 감각 점검

---

## 2. 설계·룰 문서 읽는 순서 (충돌 시)

숫자가 작을수록 우선 (`00` 설계 요약에 표 있음).

1. `10_game_rules.md` — 족보·턴·진행
2. `20_score_system.md` — 점수 순서·핸드 표
3. `21_anomaly_system.md` — Jester(변칙)
4. `30_progression.md` — Ante/Blind/Seed
5. 그 외 `40`~`80`, `22_jester_catalog.md` — 상점·아키텍처·MVP·데이터

---

## 3. 코딩 규칙 (에이전트·에디터)

- 저장소 루트에 **`CURSOR.md`** / **`AGENTS.md`**가 있으면 **같은 규칙 집합**으로 유지하고, 작업 전에 함께 본다.
- 없으면 이 저장소에서는 **`PLAN_CHECKLIST.md` + 본 문서 + `docs/Rumikub_Game/`** 를 기준으로 한다.

---

## 4. 세션을 끝낼 때 (다음 대화를 위해)

1. **`PLAN_CHECKLIST.md`** 에서 끝낸 항목은 `- [x]`로 갱신한다.
2. 구조가 바뀌었으면 **`docs/current-implementation-status.md`** 를 한 줄이라도 업데이트한다.
3. 룰/수치를 바꿨으면 해당 번호 문서(`10` 등)를 수정한다.

이렇게 해 두면 **다음 대화에서도** `PLAN_CHECKLIST.md`만 보면 이어갈 수 있다.

---

## 5. 한 줄 요약

**시작할 때는 이 파일로 입장하고, 항상 `PLAN_CHECKLIST.md`로 다음 작업을 잡는다.**
