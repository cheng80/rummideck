/// UI 연출용 타임라인(점수 연출·정산 지연 등).
///
/// [isPaused]가 true인 동안 [delay]의 경과 시간은 쌓이지 않는다.
/// 옵션/런 정보로 멈출 때의 플래그와 지연 로직을 한곳에서 맞춘다.
/// Flame 엔진·BGM과는 별개다.
class GamePresentationClock {
  bool _paused = false;

  bool get isPaused => _paused;

  /// 일시정지 여부를 바꾼다. 값이 바뀌었으면 true (호출부에서 notify 등).
  bool setPaused(bool value) {
    if (_paused == value) {
      return false;
    }
    _paused = value;
    return true;
  }

  /// 새 런 등에서 플래그만 초기화.
  void reset() {
    _paused = false;
  }

  /// 멈춘 동안은 실제 경과가 증가하지 않는다.
  Future<void> delay(Duration target) async {
    var accumulated = Duration.zero;
    const step = Duration(milliseconds: 16);
    while (accumulated < target) {
      await Future<void>.delayed(step);
      if (!_paused) {
        accumulated += step;
      }
    }
  }
}
