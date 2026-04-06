import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rummideck/app.dart';
import 'package:rummideck/services/game_settings.dart';
import 'package:rummideck/utils/storage_helper.dart';
import 'package:rummideck/views/game_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Directory('build/unit_test_assets/shaders').createSync(recursive: true);
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return Directory.systemTemp.path;
        });

    final jesterJson = File('data/common/jesters_common.json');
    if (jesterJson.existsSync()) {
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'data/common/jesters_common.json') {
            return ByteData.sublistView(
              Uint8List.fromList(utf8.encode(jesterJson.readAsStringSync())),
            );
          }
          return null;
        },
      );
    }

    await StorageHelper.init();
    GameSettings.bgmMuted = true;
    GameSettings.sfxMuted = true;
  });

  testWidgets('앱이 타이틀 화면을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Rummi'), findsOneWidget);
    expect(find.text('deck'), findsOneWidget);
    expect(find.text('게임 시작'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('게임 화면이 새 전투 레이아웃으로 빌드된다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: GameView()));
    // _initAsync calls rootBundle.loadString asynchronously
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    await tester.pump();

    expect(find.text('Play Hand'), findsOneWidget);
    expect(find.text('Discard'), findsWidgets);
    expect(find.text('Jesters'), findsOneWidget);
    expect(find.text('Run Info'), findsOneWidget);
    expect(find.text('Options'), findsOneWidget);
  });
}
