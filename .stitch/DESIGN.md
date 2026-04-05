# Design System: Flame Rummideck MVP

## 1. Visual Theme & Atmosphere

이 프로젝트의 분위기는 "우주 배경 위에 놓인 세로형 아케이드 전략 인터페이스"다.

- 배경은 깊고 차가운 우주 톤
- 정보 패널은 밝게 띄우는 대신 반투명한 어두운 표면 위에 배치
- 핵심 액션은 선명한 청록, 금색, 주황 계열로 강조
- 텍스트는 게임적인 존재감이 있어야 하지만 정보 판독성을 우선한다

키워드:

- cosmic arcade
- compact tactical HUD
- portrait mobile
- bright score emphasis
- readable hand tiles
- roguelike build dashboard

## 2. Color Palette & Roles

- Deep Space Navy (`#08111F`): 전체 배경의 가장 깊은 영역
- Void Blue (`#10233A`): 보조 배경과 패널 그라데이션 시작색
- Electric Cyan (`#3CAEE0`): 기본 주요 액션, 선택 강조, 활성 상태
- Signal Violet (`#7E57C2`): 보조 액션, 설정, 덜 중요한 인터랙션
- Score Gold (`#FFD54F`): 점수, 목표, 승리 기대감을 보여주는 강조색
- Ember Orange (`#E65100`): 강한 대비 그림자, 경고, 고열감 포인트
- Tile Ivory (`#F6E7C8`): 일반 타일 표면 기본색
- Panel Glass White (`#FFFFFF` with low opacity): 반투명 카드/패널 상부 하이라이트
- Danger Coral (`#FF6B6B`): 부족 상태, 실패 위험, 소진 경고
- Success Mint (`#63E6BE`): 클리어 가능 상태, 유효 조합, 성장 표시

## 3. Typography Rules

- 제목과 큰 수치는 아케이드 감성이 있는 굵은 디스플레이 타이포그래피
- 일반 정보 텍스트는 좁은 화면에서도 읽기 쉬운 산세리프 계열
- 점수, 목표 점수, 행동 버튼 라벨은 시각적 우선순위를 높인다
- 작은 정보 텍스트는 지나치게 연하지 않게 유지한다

## 4. Component Stylings

- Buttons: 두껍고 손가락으로 누르기 쉬운 캡슐형 또는 둥근 직사각형. 기본 액션은 청록, 보조 액션은 보라, 위험 액션은 코랄.
- HUD Panels: 반투명한 어두운 유리 패널. 모서리는 넉넉하게 둥글고, 내부는 촘촘하되 숨 막히지 않게 정렬.
- Tiles: 손패 타일은 밝은 아이보리 또는 옅은 단색 베이스 위에 숫자와 색상이 강하게 대비되어야 한다.
- Anomaly Slots: 일반 타일보다 더 기계적이고 에너지 코어 같은 느낌. 각 슬롯은 빌드 엔진처럼 보여야 한다.
- Score Preview: 숫자와 승수는 별도 배지 또는 분리된 블록으로 보여준다.

## 5. Layout Principles

- 화면은 세 구역으로 즉시 분리되어야 한다: 상단 상태, 중단 엔진, 하단 손패/행동
- 상단은 항상 고정형 HUD처럼 보이게 구성
- 중단은 anomaly와 combo preview 중심
- 하단은 엄지 조작에 맞게 submit과 discard를 배치
- 타일 8개는 가로 스크롤보다 2줄 또는 컴팩트 1줄 구성이 우선
- 장식보다 정보 위계를 우선한다

## 6. Design System Notes For Stitch Generation

아래 블록을 Stitch 프롬프트에 그대로 포함한다.

```markdown
**DESIGN SYSTEM (REQUIRED):**
- Platform: Mobile, portrait-first game UI
- Theme: cosmic arcade, high-contrast tactical HUD, readable roguelike score-building interface
- Background: layered deep-space gradient using Deep Space Navy (#08111F) and Void Blue (#10233A)
- Primary Accent: Electric Cyan (#3CAEE0) for main actions, selected state, and active controls
- Secondary Accent: Signal Violet (#7E57C2) for secondary actions and utility controls
- Score Accent: Score Gold (#FFD54F) for current score, target score, and high-value feedback
- Warning Accent: Danger Coral (#FF6B6B) for low resources and failure pressure
- Success Accent: Success Mint (#63E6BE) for valid combo and positive state
- Surfaces: dark translucent glass panels with soft highlights and generous rounded corners
- Buttons: large thumb-friendly capsule or rounded rectangle buttons with bold labels
- Tiles: highly readable ivory tile surfaces with strong number and color contrast
- Anomaly Slots: energy-core-like modules, more premium and mechanical than regular tiles
- Typography: bold arcade display for titles and key numbers, clean sans-serif for support text
- Layout: fixed top HUD, central anomaly/combo zone, bottom hand and action zone
- Mood: strategic, readable, energetic, slightly retro, never cluttered
```
