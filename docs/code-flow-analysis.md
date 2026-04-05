# Flame Template 코드 흐름 분석

이 문서는 현재 프로젝트의 1차 분석본이다.  
목표는 `lib/main.dart`를 시작점으로 앱이 어떻게 올라오고, 어떤 위젯과 게임 객체가 어떤 순서로 연결되는지 빠르게 따라갈 수 있게 정리하는 것이다.

## 1. 프로젝트 구조 요약

이 프로젝트는 크게 4개 층으로 나뉜다.

1. 앱 시작/부트스트랩
   - `lib/main.dart`
   - `lib/app.dart`
2. 라우팅/화면 전환
   - `lib/router.dart`
   - `lib/views/title_view.dart`
   - `lib/views/game_view.dart`
   - `lib/views/setting_view.dart`
3. 게임 코어
   - `lib/game/sample_game.dart`
   - `lib/game/components/*.dart`
4. 공통 서비스
   - `lib/resources/sound_manager.dart`
   - `lib/services/game_settings.dart`
   - `lib/utils/storage_helper.dart`

핵심 구조는 다음과 같다.

```text
Flutter App Shell
├─ main.dart
├─ App(MaterialApp.router)
├─ GoRouter
│  ├─ TitleView
│  ├─ GameView
│  └─ SettingView
└─ GameView 내부
   └─ Flame GameWidget
      └─ SampleGame
         ├─ Backdrop
         │  └─ SpaceBg
         ├─ Viewport
         │  └─ GameHud
         └─ World(FlameGame 기본 world)
            └─ Player
```

## 2. main.dart부터 시작하는 전체 실행 순서

### 2-1. 큰 흐름

```text
main()
├─ WidgetsFlutterBinding.ensureInitialized()
├─ StorageHelper.init()
├─ SoundManager.preload()
├─ _applyKeepScreenOn()
└─ runApp(const App())
   └─ App.build()
      └─ MaterialApp.router(...)
         └─ appRouter
            └─ initialLocation = "/"
               └─ TitleView.build()
                  ├─ _StarryBackground
                  ├─ "게임 시작" -> context.go("/game")
                  │  └─ GameView
                  │     ├─ initState() -> SoundManager.playBgm()
                  │     └─ build()
                  │        └─ GameWidget.controlled()
                  │           └─ gameFactory() -> SampleGame(...)
                  │              └─ SampleGame.onLoad()
                  │                 ├─ SpaceBg
                  │                 ├─ GameHud
                  │                 ├─ World
                  │                 └─ Player
                  └─ "설정" -> context.push("/setting")
                     └─ SettingView
```

### 2-2. 실제 역할 기준 해석

- `main.dart`
  - 앱 시작 전에 필요한 전역 초기화를 끝낸다.
- `app.dart`
  - Flutter 앱 루트 위젯을 구성한다.
- `router.dart`
  - 어떤 경로가 어떤 화면으로 연결되는지 정의한다.
- `title_view.dart`
  - 사용자가 처음 보는 메뉴 화면이다.
- `game_view.dart`
  - Flame 게임을 Flutter 위젯 트리에 마운트하는 다리 역할이다.
- `sample_game.dart`
  - 실제 게임 루프, 입력 처리, 게임 오브젝트 배치를 담당한다.

## 3. 파일별 역할 정리

### 3-1. `lib/main.dart`

앱의 진입점이다.

- Flutter 엔진 초기화
- 로컬 저장소 초기화
- 사운드 프리로드
- 화면 꺼짐 방지 설정 적용
- `App` 실행

즉, 게임 자체를 만드는 파일이 아니라 앱이 돌아갈 환경을 먼저 준비하는 파일이다.

### 3-2. `lib/app.dart`

`MaterialApp.router`를 생성하는 앱 루트다.

- 앱 제목 설정
- 디버그 배너 제거
- 다크 테마 적용
- `appRouter` 주입

### 3-3. `lib/router.dart`

라우팅 테이블이다.

- `/` -> `TitleView`
- `/game` -> `GameView`
- `/setting` -> `SettingView`

여기서 중요한 점은 게임도 하나의 Flutter 화면으로 취급된다는 것이다.  
즉 게임은 앱 전체가 아니라 `GameView` 안에 임베드된다.

### 3-4. `lib/views/title_view.dart`

첫 진입 화면이다.

- 별 배경을 Flutter `CustomPainter`로 렌더링
- 게임 제목 텍스트 출력
- 버튼 2개 제공
  - `게임 시작`
  - `설정`

버튼 동작:

- `게임 시작`
  - 버튼 효과음 재생
  - `context.go('/game')`
- `설정`
  - 버튼 효과음 재생
  - `context.push('/setting')`

### 3-5. `lib/views/game_view.dart`

Flame을 Flutter에 연결하는 핵심 화면이다.

- `initState()`
  - 메인 BGM 재생 시작
- `build()`
  - `GameWidget<SampleGame>.controlled(...)` 생성
  - 여기서 `gameFactory`가 `SampleGame` 인스턴스를 만든다
  - `overlayBuilderMap`으로 `PauseMenu` 오버레이 연결

이 파일은 게임 로직을 직접 처리하지 않고, 게임 객체 생성과 오버레이 UI를 담당한다.

### 3-6. `lib/game/sample_game.dart`

실제 Flame 게임 클래스다.

- `FlameGame` 상속
- 탭 입력 처리
- 키보드 입력 처리
- 프레임별 `update(dt)` 처리
- 일시정지/재개 처리
- 게임 오브젝트 로딩

### 3-7. `lib/game/components/space_bg.dart`

게임 배경 컴포넌트다.

- 우주 배경 그라데이션
- 별 데이터 생성
- 프레임마다 별 반짝임 갱신
- 배경 렌더링

### 3-8. `lib/game/components/game_hud.dart`

HUD 레이어다.

- 일시정지 버튼 생성
- Safe Area 디버그 경계선 렌더링

### 3-9. `lib/game/components/player.dart`

플레이어 원형 오브젝트다.

- 현재 위치 보유
- 터치 이동 시 `MoveToEffect` 사용
- 키보드 이동 시 즉시 위치 갱신
- 현재 템플릿 렌더 기준에 맞춰 Safe Area 경계 보정식을 사용
- 플레이어 중심 디버그 마커를 함께 렌더링

### 3-10. 설정/사운드/저장소

- `game_settings.dart`
  - 설정값 getter/setter 제공
- `sound_manager.dart`
  - BGM / 효과음 재생 제어
- `storage_helper.dart`
  - `GetStorage` 래퍼

즉 저장소에 직접 접근하지 않고:

```text
UI / Game
└─ GameSettings
   └─ StorageHelper
      └─ GetStorage
```

## 4. 게임 화면 진입 뒤 Flame 내부 생성 순서

`GameView`에서 `GameWidget.controlled`가 만들어진 다음, `gameFactory`가 `SampleGame`을 생성한다.  
그 뒤 Flame이 `SampleGame.onLoad()`를 호출한다.

`onLoad()`의 실제 순서는 다음과 같다.

```text
SampleGame.onLoad()
├─ camera.backdrop.add(SpaceBg())
├─ _hud = GameHud(...)
├─ camera.viewport.add(_hud)
├─ _player = Player(position: _initialPlayerPosition(), ...)
├─ world.add(_player)
└─ isPlaying = true
```

해석하면:

1. 배경을 카메라 `backdrop`에 올린다.
2. HUD 레이어를 `viewport`에 올린다.
3. 플레이어를 만든다.
4. 플레이어를 Flame 기본 `world`의 자식으로 붙인다.
5. 게임 진행 상태를 켠다.

여기서 중요한 점:

- Flame 기본 카메라는 월드 원점 `(0, 0)`을 화면 중앙에 두는 방식으로 동작한다.
- 이 템플릿은 이제 world도 카메라 기본 방식대로 "화면 중앙 = 월드 `(0, 0)`"을 사용한다.
- HUD만 화면 고정 좌표계를 사용하고, `Player`는 world 좌표계를 사용한다.
- `backdrop`은 월드 뒤에서 렌더링된다.
- `viewport` 자식은 월드 앞에서 렌더링된다.
- 시작 위치는 현재 이동 가능 영역의 중심과 일치하도록 계산한다.
- 즉 이론적으로 단순한 Safe Area 중심이 아니라, 실제 경계 보정식과 동일한 기준을 쓴다.

현재 구조상 `Player`는 HUD가 아니라 월드 레이어에 속한다.  
즉 트리 구조는 아래와 같다.

```text
SampleGame
├─ camera.backdrop
│  └─ SpaceBg
├─ camera.viewport
│  └─ GameHud
│     ├─ _PauseButton
│     └─ _SafeAreaDebugRect
└─ World(FlameGame 기본 world)
   └─ Player
```

## 5. 좌표계와 경계 계산

이 템플릿은 좌표계를 3개 층으로 나눠서 본다.

```text
1) Screen / Canvas 좌표
   - Flutter 입력 이벤트가 들어오는 화면 좌표
   - 예: event.canvasPosition

2) World 좌표
   - Player, 적, 오브젝트가 존재하는 게임 좌표
   - 현재 기준: 화면 중앙이 world (0, 0)

3) HUD / Viewport 좌표
   - 화면에 고정된 UI 좌표
   - Pause 버튼, Safe Area 디버그 선, 중심 마커가 여기서 그려짐
```

관계는 이렇게 이해하면 된다.

```text
사용자 입력(화면 좌표)
-> camera.globalToLocal(...)
-> world 좌표
-> Player 이동 처리

Player world 좌표
-> camera.localToGlobal(...)
-> 화면 좌표로 변환 가능
-> HUD 또는 Flutter overlay와 연계 가능
```

### 5-1. 왜 이렇게 맞췄는가

이론적으로는 world 좌표계와 Safe Area를 단순 변환해서 경계를 잡는 식이 더 깔끔하다.
하지만 현재 프로젝트에서는 실제 렌더 결과가 더 중요했다.

구체적으로는 아래 요소들을 동시에 맞춰야 했다.

- 노란 Safe Area 디버그 선
- Player 원형 본체
- Player 중심 마커
- 이동 가능한 영역의 중심 마커
- Player 시작 위치

초기에는 수학적으로 단순한 식을 적용했지만, 실제 화면에서는
"경계에 닿는 것처럼 보여야 하는 위치"와 "수식이 말하는 위치"가 어긋났다.
그래서 현재는 다음 원칙을 쓴다.

- 좌표계 기준은 Flame 기본 방식 유지
  - 화면 중앙 = world `(0, 0)`
- 입력은 항상 화면 좌표를 world 좌표로 변환 후 처리
- 경계식은 이론식보다 실제 디버그 마커와 시각 결과가 맞는 보정식을 채택
- 시작 위치도 같은 보정 기준을 따라 이동 가능 영역의 중심과 일치시킴

즉 이 프로젝트의 기준은 "예쁜 수식"보다 "실제 화면에서 일관되게 맞는가"이다.

### 5-2. 현재 경계 수식

현재 Player 경계 계산은 다음과 같다.

```text
safeLeftWorld   = -game.size.x / 2 + safeAreaLeft + radius
safeTopWorld    = -game.size.y / 2 + safeAreaTop + radius
safeRightWorld  =  game.size.x / 2 - safeAreaRight + radius
safeBottomWorld =  game.size.y / 2 - safeAreaBottom + radius

_boundsMin = (safeLeftWorld, safeTopWorld)
_boundsMax = (safeRightWorld, safeBottomWorld)
```

이 식을 쓰는 이유:

- Safe Area 디버그 선과 Player 중심 마커를 같이 봤을 때 가장 일관되게 맞았다.
- 네 방향 모두 같은 보정량을 써야 시각적으로 대칭에 가깝게 동작했다.
- 시작 위치와 이동 가능한 영역 중심도 같은 기준으로 맞출 수 있었다.

### 5-3. 시작 위치 수식

Player 시작 위치는 단순 화면 중심이 아니라, 현재 경계식 기준의 중심을 사용한다.

```text
initialX = (safeAreaLeft - safeAreaRight) / 2 + radius
initialY = (safeAreaTop - safeAreaBottom) / 2 + radius
```

이 식을 쓰는 이유:

- 단순 `Vector2.zero()`는 실제 이동 가능한 영역 중심과 어긋날 수 있다.
- 단순 Safe Area 중심도 현재 보정 경계식과 어긋났다.
- 위 수식을 써야 Player 시작점과 HUD의 중심 마커가 일치했다.

### 5-4. 디버그 마커 의미

현재 화면에는 빨간 마커가 2종류 있다.

```text
1) Player 중심 마커
   - Player 내부에 렌더링
   - 실제 이동/충돌/Clamp 기준이 되는 중심점

2) 이동 가능한 영역 중심 마커
   - HUD의 Safe Area 디버그 사각형 중심에 렌더링
   - Player가 시작해야 하는 목표 기준점
```

이 둘이 겹쳐 보이면:

- 시작 위치 계산이 현재 경계식과 일치한다는 뜻
- 좌표계와 경계 보정이 현재 화면 기준으로 맞는 상태라는 뜻

## 6. 입력 처리 흐름

### 6-1. 터치 입력

```text
사용자 탭
└─ SampleGame.onTapDown(event)
   ├─ isPlaying 검사
   ├─ camera.globalToLocal(event.canvasPosition)
   └─ _player.moveTo(target)
      └─ MoveToEffect 추가
```

특징:

- 화면 좌표를 world 좌표로 변환한 뒤 목표점으로 설정한다.
- 플레이어는 순간이동이 아니라 `MoveToEffect`로 부드럽게 이동한다.

### 6-2. 키보드 입력

```text
키 입력
├─ SampleGame.onKeyEvent()
│  ├─ ESC -> pauseGame()
│  ├─ 방향키/WASD down -> _keysPressed 추가
│  └─ 방향키/WASD up -> _keysPressed 제거
└─ SampleGame.update(dt)
   ├─ _keysPressed 상태 확인
   ├─ dx, dy 계산
   └─ _player.moveByVelocity(dx, dy)
```

특징:

- 키를 누르는 순간 바로 이동하지 않는다.
- 누르고 있는 키 상태를 저장해 두고 매 프레임 `update(dt)`에서 이동량을 계산한다.
- 그래서 연속 이동이 가능하다.

## 7. 일시정지 흐름

```text
Pause 버튼 탭 또는 ESC
└─ SampleGame.pauseGame()
   ├─ isPlaying = false
   ├─ _keysPressed.clear()
   ├─ SoundManager.pauseBgm()
   ├─ pauseEngine()
   └─ overlays.add('PauseMenu')
      └─ GameView.overlayBuilderMap
         └─ _PauseMenuOverlay 표시
```

재개 흐름:

```text
PauseMenu의 "계속하기"
├─ SoundManager.resumeBgm()
└─ widget.game.resumeGame()
   ├─ resumeEngine()
   ├─ overlays.remove('PauseMenu')
   └─ isPlaying = true
```

게임 종료 흐름:

```text
PauseMenu의 "나가기"
├─ 효과음 재생
├─ SoundManager.stopBgm()
└─ context.go('/')
   └─ TitleView로 복귀
```

## 8. `main.dart` 기준 함수 단위 호출 관계 상세

이 섹션은 위의 큰 흐름보다 더 잘게, 함수 단위로 따라가기 위한 상세 버전이다.

### 8-1. 앱 시작 직후

```text
main()
├─ WidgetsFlutterBinding.ensureInitialized()
│  └─ Flutter 엔진과 프레임워크 바인딩 보장
├─ await StorageHelper.init()
│  └─ GetStorage.init()
├─ await SoundManager.preload()
│  ├─ FlameAudio.audioCache.load('sfx/BtnSnd.mp3')
│  └─ FlameAudio.audioCache.load('music/Main_BGM.mp3')
├─ _applyKeepScreenOn()
│  ├─ GameSettings.keepScreenOn
│  │  └─ StorageHelper.readBool('keep_screen_on', defaultValue: true)
│  ├─ true  -> WakelockPlus.enable()
│  └─ false -> WakelockPlus.disable()
└─ runApp(const App())
```

여기서 중요한 포인트:

- `GameSettings`는 자체 상태를 들고 있지 않다.
- 읽을 때마다 `StorageHelper`를 통해 저장소에서 값을 가져온다.
- 그래서 설정값은 사실상 "정적 접근용 저장소 프록시"에 가깝다.

### 8-2. `runApp(const App())` 이후

```text
runApp(const App())
└─ App.build(context)
   └─ MaterialApp.router(
      title: AppConfig.appTitle,
      theme: ThemeData.dark(),
      routerConfig: appRouter,
   )
```

즉 `App.build()` 자체는 복잡하지 않다.  
핵심은 `routerConfig`로 넘긴 `appRouter`가 첫 화면 결정을 담당한다는 점이다.

### 8-3. 첫 화면 결정

```text
appRouter
├─ initialLocation = RoutePaths.title
│  └─ "/"
└─ routes
   ├─ "/"        -> TitleView()
   ├─ "/game"    -> GameView()
   └─ "/setting" -> SettingView()
```

앱 시작 시점에는 `/`가 선택되므로 `TitleView.builder`가 실행된다.

### 8-4. `TitleView.build()` 상세

```text
TitleView.build(context)
└─ Scaffold
   └─ Stack
      ├─ _StarryBackground
      │  ├─ _StarryBackgroundState.initState()
      │  │  └─ AnimationController(...).repeat()
      │  └─ AnimatedBuilder
      │     └─ CustomPaint(_StarPainter)
      └─ SafeArea
         └─ Column
            ├─ 제목/부제목 텍스트
            ├─ _RoundButton("게임 시작")
            └─ _RoundButton("설정")
```

버튼 이벤트는 다음과 같다.

#### 게임 시작 버튼

```text
onPressed()
├─ SoundManager.playSfx(AssetPaths.sfxBtnSnd)
│  ├─ GameSettings.sfxMuted 검사
│  └─ FlameAudio.play(path, volume: GameSettings.sfxVolume)
└─ context.go(RoutePaths.game)
   └─ "/game" 라우트로 교체 이동
```

#### 설정 버튼

```text
onPressed()
├─ SoundManager.playSfx(AssetPaths.sfxBtnSnd)
└─ context.push(RoutePaths.setting)
   └─ "/setting" 화면을 스택 위에 push
```

`go`와 `push`의 차이도 중요하다.

- `go('/game')`
  - 현재 경로를 교체하는 성격
- `push('/setting')`
  - 현재 화면 위에 새 화면을 올리는 성격

그래서 설정은 보통 뒤로 돌아오기 쉬운 보조 화면이고, 게임 시작은 메인 흐름 전환으로 설계되어 있다.

### 8-5. `GameView` 진입 상세

`/game`으로 이동하면 `GameView`가 생성된다.

```text
GameView 생성
├─ _GameViewState.initState()
│  └─ SoundManager.playBgm(AssetPaths.bgmMain)
│     ├─ if (_currentBgm == path) return
│     ├─ stopBgm()
│     ├─ _currentBgm = path
│     ├─ if (GameSettings.bgmMuted) return
│     └─ FlameAudio.bgm.play(path, volume: GameSettings.bgmVolume)
└─ _GameViewState.build(context)
   ├─ MediaQuery.of(context).padding
   └─ GameWidget<SampleGame>.controlled(
      gameFactory: () => SampleGame(...safeArea...),
      overlayBuilderMap: { 'PauseMenu': _buildPauseMenu }
   )
```

핵심 포인트:

- `GameView`는 Safe Area 값을 먼저 구한다.
- 그 값을 `SampleGame` 생성자에 넘긴다.
- 즉 게임 내부 컴포넌트들은 Flutter의 디바이스 여백 정보를 생성 시점에 전달받는다.

### 8-6. `SampleGame` 생성 직후 상세

`gameFactory`는 실제로 `SampleGame` 객체를 반환한다.

```text
SampleGame(...)
├─ safeAreaTop 저장
├─ safeAreaBottom 저장
├─ safeAreaLeft 저장
└─ safeAreaRight 저장
```

객체가 만들어진 뒤 Flame 라이프사이클이 이어진다.

```text
Flame engine
└─ SampleGame.onLoad()
   ├─ camera.backdrop.add(SpaceBg())
   ├─ _hud = GameHud(...)
   ├─ camera.viewport.add(_hud!)
   ├─ _player = Player(position: _initialPlayerPosition(), ...)
   ├─ world.add(_player)
   └─ isPlaying = true
```

### 8-7. `SpaceBg.onLoad()` 상세

```text
SpaceBg.onLoad()
├─ size = game.size
├─ priority = -1
├─ 배경 그라데이션 Paint 생성
└─ _stars = List.generate(_starCount, _createStar)
```

이후 매 프레임:

```text
SpaceBg.update(dt)
└─ 모든 star.time += dt

SpaceBg.render(canvas)
├─ 배경 사각형 렌더링
└─ 각 별의 alpha 계산 후 원 렌더링
```

즉 배경도 단순 정적 이미지가 아니라 Flame 컴포넌트로 계속 업데이트된다.
현재는 `camera.backdrop`에 붙어 있으므로 월드 뒤에서 렌더링된다.

### 8-8. `GameHud.onLoad()` 상세

```text
GameHud.onLoad()
├─ priority = 10
├─ game.size 읽기
├─ 버튼 크기 계산
├─ Safe Area 기준 버튼 위치 계산
├─ add(_PauseButton(...))
└─ add(_SafeAreaDebugRect())
```

여기서 HUD는 단순 UI 컨테이너 역할뿐 아니라 Safe Area 디버깅 보조 렌더링도 함께 갖고 있다.

### 8-8-1. 기본 world 역할

`SampleGame`은 별도 `PositionComponent`를 만드는 대신, `FlameGame`이 기본 제공하는 `world`를 사용해 `Player`를 그 아래에 둔다.

```text
world.add(_player)
```

이 분리로 얻는 의미는 다음과 같다.

- 월드 객체와 HUD 객체를 계층적으로 분리할 수 있다.
- 카메라가 바라보는 대상이 기본 `world`라서 Flame 구조와 맞는다.
- 나중에 카메라 추적이나 월드 스크롤을 넣을 때 `Player`가 자연스럽게 월드 좌표를 따른다.
- HUD는 화면 고정 요소만 담당하게 된다.
- 적, 투사체, 아이템 같은 월드 오브젝트를 `world` 아래에 계속 확장할 수 있다.

### 8-9. `Player` 생성과 이동 함수 상세

경계 수식은 다음 기준을 따른다.

```text
safeLeftWorld   = -game.size.x / 2 + safeAreaLeft + radius
safeTopWorld    = -game.size.y / 2 + safeAreaTop + radius
safeRightWorld  =  game.size.x / 2 - safeAreaRight + radius
safeBottomWorld =  game.size.y / 2 - safeAreaBottom + radius

_boundsMin = (safeLeftWorld, safeTopWorld)
_boundsMax = (safeRightWorld, safeBottomWorld)
```

이 수식은 순수 이론식이라기보다 "현재 템플릿의 실제 렌더 결과와 맞는 보정식"이다.
프로젝트에서 Safe Area 디버그 선과 플레이어 중심 마커를 함께 확인한 결과,
네 방향 모두 `+ radius` 보정이 들어간 식이 시각적으로 가장 일관되게 맞았다.

즉 이 문서에서는 다음 두 가지를 구분한다.

- 이론상 단순한 world-Safe Area 변환식
- 현재 프로젝트에서 실제 화면과 맞는 보정식

현재는 두 번째를 채택하고 있다. 이유는 플레이어 이동 제한이 "수학적으로 예쁜 식"보다
"화면에서 노란 경계와 플레이어가 실제로 어떻게 맞아 보이는가"에 맞춰져 있기 때문이다.

시작 위치는 이동 가능한 영역의 중심을 사용한다.

```text
initialX = (safeAreaLeft - safeAreaRight) / 2 + radius
initialY = (safeAreaTop - safeAreaBottom) / 2 + radius
```

이 역시 같은 이유로 `+ radius` 보정을 포함한다.
시작점을 단순 Safe Area 중심으로 두면 실제 이동 가능 영역의 중심 마커와 어긋났고,
경계식과 같은 보정을 넣어야 플레이어 시작점과 디버그 중심점이 일치했다.

생성 시:

```text
Player(...)
└─ super(
   size: Vector2.all(_radius * 2),
   anchor: Anchor.center,
)
```

즉 `position`은 원의 중심 좌표다.

디버그 렌더링도 함께 들어가 있다.

```text
Player.render()
├─ 원 본체 렌더링
├─ 흰색 외곽선 렌더링
└─ 빨간 중심점 + 십자 마커 렌더링
```

#### 터치 이동

```text
SampleGame.onTapDown()
├─ target = camera.globalToLocal(event.canvasPosition)
└─ _player.moveTo(target)
   ├─ _clamp(target)
   │  ├─ _boundsMin 계산
   │  └─ _boundsMax 계산
   └─ add(MoveToEffect(...))
```

#### 키보드 이동

```text
SampleGame.update(dt)
└─ _player.moveByVelocity(dx, dy)
   ├─ removeAll(children.whereType<MoveToEffect>())
   └─ position = _clamp(position + Vector2(dx, dy))
```

즉:

- 터치 이동은 이펙트 기반
- 키보드 이동은 즉시 위치 갱신 기반

이 둘을 섞어 쓸 수 있게 키보드 이동 시 기존 `MoveToEffect`를 지우고 있다.

### 8-10. Pause 오버레이 연결 상세

게임 일시정지는 Flame과 Flutter가 같이 동작한다.

```text
_PauseButton.onTapUp()
└─ game.pauseGame()
   ├─ isPlaying = false
   ├─ _keysPressed.clear()
   ├─ SoundManager.pauseBgm()
   ├─ pauseEngine()
   └─ overlays.add('PauseMenu')
```

그러면 `GameWidget.controlled`에 등록한 오버레이 빌더가 호출된다.

```text
overlayBuilderMap['PauseMenu']
└─ _buildPauseMenu(context, game)
   └─ _PauseMenuOverlay(game: game)
```

즉 게임은 멈추고, 메뉴 UI는 Flutter 위젯으로 위에 덮인다.

### 8-11. 설정 화면 상세

설정 화면은 게임과 분리된 일반 Flutter 화면이다.

```text
SettingView.initState()
└─ _loadSettings()
   ├─ GameSettings.bgmVolume
   ├─ GameSettings.sfxVolume
   ├─ GameSettings.bgmMuted
   ├─ GameSettings.sfxMuted
   └─ GameSettings.keepScreenOn
```

토글/슬라이더 동작:

- 볼륨 변경
  - `GameSettings.xxx = value`
  - 필요 시 `SoundManager.applyBgmVolume()`
- 음소거 변경
  - `GameSettings.xxxMuted = value`
  - 필요 시 `pauseBgm()` 또는 `playBgmIfUnmuted()`
- 화면 꺼짐 방지 변경
  - `GameSettings.keepScreenOn = value`
  - `_applyKeepScreenOn()`
  - `WakelockPlus.enable()/disable()`

## 8. 따라 읽기 추천 순서

코드를 처음 읽는다면 아래 순서가 가장 효율적이다.

1. `lib/main.dart`
2. `lib/app.dart`
3. `lib/router.dart`
4. `lib/views/title_view.dart`
5. `lib/views/game_view.dart`
6. `lib/game/sample_game.dart`
7. `lib/game/components/player.dart`
8. `lib/game/components/game_hud.dart`
9. `lib/game/components/space_bg.dart`
10. `lib/services/game_settings.dart`
11. `lib/resources/sound_manager.dart`
12. `lib/utils/storage_helper.dart`

## 9. 현재 템플릿의 설계 포인트

- Flutter와 Flame의 책임이 명확히 분리되어 있다.
  - Flutter: 앱, 라우팅, 설정, 메뉴, 오버레이
  - Flame: 게임 월드, 입력, 업데이트, 렌더링
- Flame 내부에서도 월드와 HUD를 분리했다.
  - World: `Player`
  - HUD: 일시정지 버튼, Safe Area 디버그 표시
- 설정값은 전부 `GameSettings`를 통해 읽고 쓴다.
- 오버레이는 Flame 내부 UI가 아니라 Flutter 위젯으로 올린다.
- Safe Area 정보를 Flutter에서 읽고 Flame 생성자에 넘기는 구조다.
- 타이틀 배경은 Flame이 아니라 Flutter `CustomPainter`로 구현되어 있다.

## 10. 다음 확장 포인트

이 템플릿을 확장할 때 먼저 손댈 만한 지점은 다음이다.

- 플레이어 로직 확장
  - `lib/game/components/player.dart`
- 적/오브젝트 추가
  - `lib/game/components/` 아래 신규 컴포넌트
- 게임 규칙 추가
  - `lib/game/sample_game.dart`
- 인게임 HUD 확장
  - `lib/game/components/game_hud.dart`
- 타이틀/설정 UI 확장
  - `lib/views/*.dart`

---

1차 분석 기준 결론:

이 프로젝트는 "Flutter가 껍데기와 화면 전환을 담당하고, `GameView`에 들어가면 Flame 게임이 올라오는 구조"로 이해하면 된다.  
실제로 코드를 따라갈 때는 `main.dart -> App -> Router -> TitleView -> GameView -> SampleGame.onLoad()` 축을 먼저 잡고, 그 다음 `Player`, `HUD`, `SoundManager`, `GameSettings`를 이어서 보는 방식이 가장 빠르다.
