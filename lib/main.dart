/// 🎴 K-Poker — main.dart
///
/// 앱 엔트리 포인트. Flutter + Riverpod 기반.
library;

import 'dart:async';
import 'package:flutter/foundation.dart' show FlutterError, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/ad_service.dart';
import 'services/update_service.dart';
import 'state/audio_manager.dart';
import 'ui/game_screen.dart';

// 릴리스 빌드에서 화면에 표시할 마지막 예외(흰 화면 대신 보이게).
String? _lastCaughtError;

void main() async {
  // 릴리스 빌드 흰 화면 대신 에러를 화면에 그대로 표시하기 위한 전역 핸들러.
  // Zone 예외 + Flutter 위젯 예외 + 모든 플랫폼 에러를 여기서 캐치.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _lastCaughtError = '${details.exceptionAsString()}\n\n${details.stack}';
      };

      // 위젯 build 예외를 흰 화면 대신 빨간 박스 + 메시지로 표시.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        _lastCaughtError = '${details.exceptionAsString()}\n\n${details.stack}';
        return Material(
          color: const Color(0xFF2A0000),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  'K-Poker 에러\n\n${details.exceptionAsString()}\n\n${details.stack}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        );
      };

      // ⚡ 시스템 UI 설정을 FIRST FRAME 이전에 — hit test 좌표계 정합성 보장.
      // 2026-04-19: 이게 runApp 이후에 있으면 portrait + system bar 포함 상태로
      // 첫 레이아웃/hit test 계산이 고정됐다가, 이후 landscape + immersive 전환 시
      // 시각 위치만 이동하고 hit test는 원래 좌표계에 남아 마우스 좌표가
      // 왼쪽 위로 shift되는 현상이 발생. 빠른 동기 호출이므로 await 비용 <10ms.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // UI 표시 (즉시). AudioManager/AdMob 등 느린 외부 서비스는 runApp 이후 백그라운드.
      runApp(const ProviderScope(child: KPokerApp()));

      _bootServices();
    },
    (error, stack) {
      _lastCaughtError = '$error\n\n$stack';
    },
  );
}

/// 외부 서비스 초기화를 백그라운드로 실행. 실패해도 앱은 계속 동작.
Future<void> _bootServices() async {
  // 오디오 — 최대한 빠르게 BGM 시작하도록 가장 먼저.
  try {
    await AudioManager().init();
    AudioManager().startBgmLoop();
  } catch (e) {
    _lastCaughtError = 'AudioManager 초기화 실패: $e';
  }

  // 외부 네트워크 의존 서비스 — 각각 독립 백그라운드.
  if (!kIsWeb) {
    AdService.init().catchError((Object e, StackTrace s) {
      _lastCaughtError = 'AdService.init 실패: $e';
    });
    UpdateService.checkForUpdate();
  }
}

/// 마지막으로 캐치된 에러(디버그 오버레이용).
String? getLastCaughtError() => _lastCaughtError;

class KPokerApp extends StatelessWidget {
  const KPokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-Poker: Hwatu Roguelike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.notoSansKrTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FACFE),
          secondary: Color(0xFFFF6B35),
          surface: Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
