# UI·상태 리팩토링 — 진행 안내

> **갱신**: 2026-04-09 — 완료된 상세 플랜은 `docs/archive/refactoring/`에 두고, 본 파일을 단일 진입점으로 한다. 게임 진행·플레이북·상점 로직 갱신은 `PLAN_CHECKLIST.md` / `current-implementation-status.md`를 본다.

## 요약

Riverpod 도입, `game_view` 모듈 분리, 게임 위젯 `ConsumerWidget` 전환, `battle_theme`·전투/모달 위젯 파일 분리, 반응형 레이아웃 등 **주요 UI 리팩토링 물결은 완료**다. 단계별 체크리스트·변경 이력·분리 위젯 목록은 아래 아카이브 원문을 본다.

## 아카이브 (완료 플랜)

| 문서 | 내용 |
|------|------|
| [`archive/refactoring/refactoring-plan.md`](archive/refactoring/refactoring-plan.md) | Riverpod·part→import·Consumer 전환·테마·반응형·남은 선택 과제(Provider 세분화) |
| [`archive/refactoring/ui_widget_extraction_plan.md`](archive/refactoring/ui_widget_extraction_plan.md) | 모달·전투 중앙·손패·씬 조립 등 위젯 분리 Phase 1–7 및 검증 기록 |

## 선택 과제 (미착수)

- **Provider 세분화** (`gameSessionProvider` 파생·`select` 등): 리빌드 비용이 실측상 문제일 때만. 상세는 아카이브 `refactoring-plan.md`의 Phase 4.

게임 **다음 구현 우선순위**는 리팩토링이 아니라 [`START_HERE.md`](../START_HERE.md) → [`PLAN_CHECKLIST.md`](../PLAN_CHECKLIST.md) → [`current-implementation-status.md`](current-implementation-status.md) 순으로 잡는다.
