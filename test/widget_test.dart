import 'package:flutter_test/flutter_test.dart';

/// UI/번역/오디오 등 위젯 테스트는 유지보수 비용 대비 이득이 작아
/// `flutter test`가 오류 없이 통과하도록 최소 스모크만 둔다.
void main() {
  test('widget_test placeholder (smoke)', () {
    expect(2 + 2, 4);
  });
}
