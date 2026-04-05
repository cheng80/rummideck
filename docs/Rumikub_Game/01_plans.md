# 실행 계획 (요약)

## 역할

이 문서는 **방향만 짧게 적는 자리**다.  
**실제로 무엇을 했는지·무엇이 남았는지**는 저장소 루트의 **`PLAN_CHECKLIST.md`**에서 체크박스로 관리한다.

---

## 현재 기준 방향 (게임성 검증)

1. **로직만으로는 재미를 검증하기 어렵다**는 판단 하에, 계획을 수정했다.  
   **조커(Jester) 없이 가능한 첫 전투부터 1차 보스까지** **한 번의 완전한 순회**가 끊기지 않게 돌아가고, 그 과정에 **딜·드로우·리필·점수 계산** 등 **최소 연출·움직임**이 들어가야 “게임성 검증”으로 친다.

2. **구현 전략**: 현재 게임 로직은 부분 보수보다 **문서 기준 재작성**이 낫다고 판단한다.  
   다음 작업의 기준은 기존 구현 유지가 아니라, **Pure Dart 규칙 코어를 처음부터 다시 세우고 UI는 이후 다시 연결하는 것**이다.

3. **룰 기준 재잠금**: Balatro 원형 기준으로 우선 잠근 기본값은 다음과 같다.  
   `Hand Size 8 / Hands 4 / Discards 3 / Jester Slots 5 / Ante 8 / Small→Shop→Big→Shop→Boss→Shop`  
   현재 코드의 `Hands 5`, `Anomaly`, stage 직진 구조는 임시 구현으로 본다.

4. **시각·레이아웃 참고**: 원작 Balatro 느낌의 화면 구성은 아래 리뷰 글의 **스크린샷**을 참고한다. (구성·정보 배치 목표; 원작 일러스트 무단 복제 금지)  
   - [Balatro(발라트로) — MAIZ 네이버 블로그](https://m.blog.naver.com/madmaiz/223680967644)

5. **MVP·룰**: `80_mvp_checklist.md` + `PLAN_CHECKLIST.md`를 동시에 본다. 룰·수치는 `10`~`60` 번대 문서 우선.

6. **진행 구조**: 장기적으로 `30_progression.md`(Ante/Blind/Stake). 당장은 **한 번의 완전한 순회** 검증을 우선한다.

---

## 링크

| 문서 | 용도 |
|------|------|
| [START_HERE.md](../../START_HERE.md) | **대화·세션 시작 시 최초 문서** → 이후 체크리스트·설계 순서 안내 |
| [PLAN_CHECKLIST.md](../../PLAN_CHECKLIST.md) | **실행 체크리스트 (메인)** — §0·§5.1 (완전 순회·연출) |
| [current-implementation-status.md](../current-implementation-status.md) | 구현/보류 항목 스냅샷 |
| [80_mvp_checklist.md](80_mvp_checklist.md) | MVP 범위 정의 |

---

## 한 줄

**체크리스트를 갱신하는 것이 곧 계획을 갱신하는 것이다.**
