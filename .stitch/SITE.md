# SITE.md

## 1. Project Vision

문서 기반으로 설계된 `Rummikub x Balatro` 계열 MVP를 모바일 세로 화면 UI로 정리한다.

이 파일의 목적은 Stitch 화면 생성 범위를 고정하는 것이다.

- 프로젝트 성격: 모바일 게임 UI
- 엔진 연결: Flutter + Flame
- 사용 목적: 실제 구현 전 화면 구조 검증

## 2. Product Summary

- 손패 8개로 조합을 만든다
- 변칙 타일 3개로 점수를 증폭한다
- Stage 1~5를 돌파하는 로그라이크 런을 구성한다

## 3. Non-Negotiables

- 세로형 모바일 전용
- 상단 HUD / 중단 anomaly / 하단 손패 구조 유지
- 조합 이해도와 점수 가독성이 장식보다 우선
- 현재 코드 골격은 `title`, `game`, `setting` 라우트를 유지
- 실제 로직은 Pure Dart 중심이며, Stitch 산출물은 UI 참조용이다

## 4. Sitemap

- [ ] `game_mvp` : 메인 런 플레이 화면
- [ ] `shop_mvp` : 스테이지 클리어 후 상점 화면
- [ ] `title_mvp` : 시작 화면
- [ ] `pause_overlay` : 게임 중단 오버레이
- [ ] `seed_entry` : 시드 입력 또는 재시작 화면

## 5. Roadmap

1. `game_mvp` 생성
2. `shop_mvp` 생성
3. `title_mvp` 생성
4. `pause_overlay` 생성
5. 필요시 `seed_entry` 생성

## 6. Screen Notes

### `game_mvp`

- MVP 핵심 검증 화면
- Stage, score, target, plays, discards, gold, seed 모두 노출
- anomaly 3칸, combo preview, score preview 포함
- 손패 8개와 submit/discard 버튼 반드시 포함

### `shop_mvp`

- Gold와 현재 anomaly 보유 상태를 같이 보여준다
- 제안 슬롯은 3개
- reroll과 leave 액션이 분명해야 한다

### `title_mvp`

- 현재 우주/아케이드 분위기 유지
- game start의 명확한 CTA 필요

## 7. Creative Freedom

- 우주 배경의 별/먼지/광원 표현은 허용
- anomaly 슬롯의 시각 언어는 에너지 코어나 장치 느낌으로 과감하게 표현 가능
- 타일은 지나치게 현실 카드처럼 만들지 말고 게임 보드 오브젝트처럼 보이게 유지
