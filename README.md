# rummideck

Flame 게임 템플릿. 터치/키보드로 플레이어를 이동시키는 샘플 게임 포함.

**개발 작업을 이어갈 때**: 루트 [`START_HERE.md`](START_HERE.md) → [`PLAN_CHECKLIST.md`](PLAN_CHECKLIST.md) 순으로 본다.

## 템플릿 구조

```
lib/
├── main.dart           # 앱 진입점 (GameSettings, SoundManager 초기화)
├── app.dart            # MaterialApp.router 루트
├── app_config.dart     # 앱 상수 (제목, 라우트 경로)
├── router.dart         # go_router 라우트 정의
│
├── game/               # 게임 로직
│   ├── sample_game.dart      # 샘플 게임 메인 (SampleGame)
│   └── components/
│       ├── player.dart       # 원형 플레이어
│       ├── space_bg.dart     # 우주 배경 (별 반짝임)
│       └── game_hud.dart     # HUD (일시정지 버튼, Safe Area 디버그선)
│
├── views/              # 화면
│   ├── title_view.dart       # 타이틀 화면
│   ├── game_view.dart        # 게임 화면 (SampleGame 마운트)
│   └── setting_view.dart     # 설정 화면
│
├── resources/          # 리소스
│   ├── asset_paths.dart      # 에셋 경로 상수
│   └── sound_manager.dart    # BGM/효과음 관리
│
└── services/           # 서비스
    └── game_settings.dart    # 게임 설정 (볼륨, 음소거 등)
```

## 샘플 게임 설명

### 조작
- **터치**: 화면을 터치하면 원형 플레이어가 해당 위치로 이동
- **키보드**: 방향키 또는 WASD로 이동 (에뮬레이터/데스크톱)

### 구성 요소
| 컴포넌트 | 설명 |
|---------|------|
| **SpaceBg** | 우주 배경. 그라데이션 + 120개 랜덤 별(반짝임) |
| **GameHud** | 일시정지 버튼, Safe Area 경계선(노란선, 디버그용) |
| **Player** | 원형 플레이어. 터치/키보드로 이동, Safe Area 내 경계 제한 |

### 좌표계
- 모두 **Viewport** 좌표계 사용 (0,0=좌상단)
- Safe Area(노치, 홈 인디케이터) 반영

### 경계 동작
- **좌/상**: 원 가장자리가 경계에 닿을 때까지
- **우/하**: 원 중심이 경계선까지 (우측은 절반 더 나감)

### 의존성
- `flame` - 게임 엔진
- `flame_audio` - BGM/효과음
- `go_router` - 라우팅
- `get_storage` - 설정 저장
- `wakelock_plus` - 화면 켜짐 유지

## Getting Started

```bash
flutter pub get
flutter run
```

- [Flame 문서](https://docs.flame-engine.org/)
- [Flutter 문서](https://docs.flutter.dev/)
