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

      // 오디오 초기화 — SharedPreferences 로드 + onPlayerComplete 리스너 등록 (BGM 순환 재생 필수)
      await AudioManager().init();
      // 앱 시작 시 BGM 루프 시작 — 타이틀 화면부터 음악 재생 (await 없이 비동기 호출, 앱 시작 차단하지 않음)
      AudioManager().startBgmLoop();

      // Android: AdMob 초기화 + 인앱 업데이트 체크
      if (!kIsWeb) {
        await AdService.init();
        UpdateService.checkForUpdate(); // 비동기 — 게임 시작 차단하지 않음
      }

      // 모바일: 가로 모드 우선 + 상태바/네비게이션 숨기기
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      runApp(const ProviderScope(child: KPokerApp()));
    },
    (error, stack) {
      _lastCaughtError = '$error\n\n$stack';
    },
  );
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
